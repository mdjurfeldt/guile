/* classes: h_files */

#ifndef READH
#define READH
/*	Copyright (C) 1995,1996 Free Software Foundation, Inc.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * As a special exception, the Free Software Foundation gives permission
 * for additional uses of the text contained in its release of GUILE.
 *
 * The exception is that, if you link the GUILE library with other files
 * to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the GUILE library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the
 * Free Software Foundation under the name GUILE.  If you copy
 * code from other Free Software Foundation releases into a copy of
 * GUILE, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for GUILE, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.  
 */


#include "__scm.h"



/* SCM_LINE_INCREMENTORS are the characters which cause the line count to
 * be incremented for the purposes of error reporting.  This feature
 * is only used for scheme code loaded from files.
 *
 * SCM_WHITE_SPACES are other characters which should be treated like spaces
 * in programs.
 */

#define SCM_LINE_INCREMENTORS  '\n'

#ifdef MSDOS
# define SCM_SINGLE_SPACES  ' ':case '\r':case '\f': case 26
#else
# define SCM_SINGLE_SPACES  ' ':case '\r':case '\f'
#endif

#define SCM_WHITE_SPACES  SCM_SINGLE_SPACES: case '\t'

#ifdef READER_EXTENSIONS
extern scm_option scm_read_opts[];

#define RECORD_POSITIONS scm_read_opts[0].val
#define COPY_SOURCE      scm_read_opts[1].val
#define N_READ_OPTIONS 2
#endif



#ifdef __STDC__
extern SCM scm_read_options (SCM new_values);
extern SCM scm_read (SCM port, SCM casep, SCM sharp);
extern char * scm_grow_tok_buf (SCM * tok_buf);
extern int scm_flush_ws (SCM port, char *eoferr);
extern int scm_casei_streq (char * s1, char * s2);
extern SCM scm_lreadr (SCM * tok_buf, SCM port, int case_i, SCM sharp);
extern scm_sizet scm_read_token (int ic, SCM * tok_buf, SCM port, int case_i, int weird);
extern SCM scm_lreadparen (SCM * tok_buf, SCM port, char *name, int case_i, SCM sharp);
extern void scm_init_read (void);

#else /* STDC */
extern SCM scm_read_options ();
extern SCM scm_read ();
extern char * scm_grow_tok_buf ();
extern int scm_flush_ws ();
extern int scm_casei_streq ();
extern SCM scm_lreadr ();
extern scm_sizet scm_read_token ();
extern SCM scm_lreadparen ();
extern void scm_init_read ();

#endif /* STDC */


#endif  /* READH */
