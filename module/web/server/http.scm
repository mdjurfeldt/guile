;;; Web I/O: HTTP

;; Copyright (C)  2010 Free Software Foundation, Inc.

;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 3 of the License, or (at your option) any later version.
;;
;; This library is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public
;; License along with this library; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301 USA

;;; Code:

(define-module (web server http)
  #:use-module ((srfi srfi-1) #:select (fold))
  #:use-module (srfi srfi-9)
  #:use-module (rnrs bytevectors)
  #:use-module (web request)
  #:use-module (web response)
  #:use-module (web server)
  #:use-module (ice-9 poll)
  #:use-module (system repl error-handling))


(define (make-default-socket family addr port)
  (let ((sock (socket PF_INET SOCK_STREAM 0)))
    (setsockopt sock SOL_SOCKET SO_REUSEADDR 1)
    (bind sock family addr port)
    sock))

(define-record-type <http-server>
  (make-http-server socket poll-idx poll-set)
  http-server?
  (socket http-socket)
  (poll-idx http-poll-idx set-http-poll-idx!)
  (poll-set http-poll-set))

(define *error-events* (logior POLLHUP POLLERR))
(define *read-events* POLLIN)
(define *events* (logior *error-events* *read-events*))

;; -> server
(define* (http-open #:key
                    (host #f)
                    (family AF_INET)
                    (addr (if host
                              (inet-pton family host)
                              INADDR_LOOPBACK))
                    (port 8080)
                    (socket (make-default-socket family addr port)))
  (listen socket 5)
  (sigaction SIGPIPE SIG_IGN)
  (let ((poll-set (make-empty-poll-set)))
    (poll-set-add! poll-set socket *events*)
    (make-http-server socket 1 poll-set)))

;; -> (client request body | #f #f #f)
(define (http-read server)
  (let* ((poll-set (http-poll-set server)))
    (let lp ((idx (http-poll-idx server)))
      (cond
       ((not (< idx (poll-set-nfds poll-set)))
        (poll poll-set)
        (lp 0))
       (else
        (let ((revents (poll-set-revents poll-set idx)))
          (cond
           ((zero? revents)
            ;; Nothing on this port.
            (lp (1+ idx)))
           ((zero? idx)
            ;; The server socket.
            (if (not (zero? (logand revents *error-events*)))
                ;; An error.
                (throw 'interrupt)
                ;; Otherwise, we have a new client. Add to set, then
                ;; find another client that is ready to read.
                ;;
                ;; FIXME: preserve meta-info.
                (let ((client (accept (poll-set-port poll-set idx))))
                  ;; Set line buffering while reading the request.
                  (setvbuf (car client) _IOLBF)
                  (poll-set-add! poll-set (car client) *events*)
                  (lp (1+ idx)))))
           ;; Otherwise, a client socket with some activity on
           ;; it. Remove it from the poll set.
           (else
            (let ((port (poll-set-remove! poll-set idx)))
              (cond
               ((or (not (zero? (logand revents *error-events*)))
                    (eof-object? (peek-char port)))
                ;; The socket was shut down or had an error. See
                ;; http://www.greenend.org.uk/rjk/2001/06/poll.html
                ;; for an interesting discussion.
                (close-port port)
                (lp idx))
               (else
                ;; Otherwise, try to read a request from this port.
                ;; Next time we start with this index.
                (set-http-poll-idx! server idx)
                (call-with-error-handling
                 (lambda ()
                   (let ((req (read-request port)))
                     ;; Block buffering for reading body and writing response.
                     (setvbuf port _IOFBF)
                     (values port
                             req
                             (read-request-body/latin-1 req))))
                 #:pass-keys '(quit interrupt)
                 #:on-error (if (batch-mode?) 'pass 'debug)
                 #:post-error
                 (lambda (k . args)
                   (warn "Error while reading request" k args)
                   (values #f #f #f))))))))))))))

(define (keep-alive? response)
  (let ((v (response-version response)))
    (case (car v)
      ((1)
       (case (cdr v)
         ((1) #t)
         ((0) (memq 'keep-alive (response-connection response)))))
      (else #f))))

;; -> 0 values
(define (http-write server client response body)
  (let* ((response (write-response response client))
         (port (response-port response)))
    (cond
     ((not body))                       ; pass
     ((string? body)
      (write-response-body/latin-1 response body))
     ((bytevector? body)
      (write-response-body/bytevector response body))
     (else
      (error "Expected a string or bytevector for body" body)))
    (cond
     ((keep-alive? response)
      (force-output port)
      ;; back to line buffered
      (setvbuf port _IOLBF)
      (poll-set-add! (http-poll-set server) port *events*))
     (else
      (close-port port)))
    (values)))

;; -> unspecified values
(define (http-close server)
  (let ((poll-set (http-poll-set server)))
    (let lp ((n (poll-set-nfds poll-set)))
      (if (positive? n)
          (begin
            (close-port (poll-set-remove! poll-set (1- n)))
            (lp (1- n)))))))

(define-server-impl http
  http-open
  http-read
  http-write
  http-close)