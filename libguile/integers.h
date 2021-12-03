#ifndef SCM_INTEGERS_H
#define SCM_INTEGERS_H

/* Copyright 2021 Free Software Foundation, Inc.

   This file is part of Guile.

   Guile is free software: you can redistribute it and/or modify it
   under the terms of the GNU Lesser General Public License as published
   by the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Guile is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
   License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with Guile.  If not, see
   <https://www.gnu.org/licenses/>.  */



#include "libguile/numbers.h"

SCM_INTERNAL int scm_is_integer_odd_i (scm_t_inum i);
SCM_INTERNAL int scm_is_integer_odd_z (SCM z);



#endif  /* SCM_INTEGERS_H */
