/*
 *  libfb - FreeBASIC's runtime library
 *	Copyright (C) 2004-2005 Andre V. T. Vicentini (av1ctor@yahoo.com.br) and others.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * sys_chain.c -- chain function for Windows
 *
 * chng: jan/2005 written [v1ctor]
 *
 */

#include <malloc.h>
#include <string.h>
#include <process.h>
#include "fb.h"

#ifdef TARGET_CYGWIN
#define _spawnl spawnl
#endif

/*:::::*/
FBCALL int fb_Chain ( FBSTRING *program )
{
    char	buffer[MAX_PATH+1];
    char 	arg0[] = "";
    int		res = 0;

	FB_STRLOCK();

	if( (program != NULL) && (program->data != NULL) )
	{
		res = _spawnl( _P_WAIT, fb_hGetShortPath( program->data, buffer, MAX_PATH ), arg0, NULL );
	}

	/* del if temp */
	fb_hStrDelTemp( program );

	FB_STRUNLOCK();

	return res;
}
