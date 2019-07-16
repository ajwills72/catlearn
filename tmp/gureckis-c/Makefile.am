# vim:tw=78
## $Id: Makefile.am,v 1.7 2002/08/17 23:18:21 gureckis Exp $
##
## Process this file with automake to create Makefile.in
##
##
## Copyright (C) 2002 - Anthony Ventimiglia
## 
## This file is part of Cognition, an audio editing application, 
## 
## Cognition is free software; you can redistribute it and/or modify it under the
## terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
## 
## Cognition is distributed in the hope that it will be useful, but WITHOUT ANY
## WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
## A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License along with
## this program; if not, write to the Free Software Foundation, Inc., 59 Temple
## Place - Suite 330, Boston, MA  02111-1307, USA

## If you need an explanation of these macros, refer to cog/Makefile.am or 
## demo/Makefile.am
## the mpich header directory also has to be set in configure. so this is
## just something to make things work for now.
INCLUDES=-I$(top_srcdir)/cog -I$(top_srcdir)/config 
LDFLAGS=@LDFLAGS@ -all-static

## This is where you should list header files that are dependant on the build, 
## but not meant to be installed
noinst_HEADERS=\
		SUSTAINCatUnit.h \
		SUSTAINCluster.h \
		SUSTAINDimension.h \
                SUSTAINModel.h \
		SUSTAINNetwork.h 

bin_PROGRAMS=sustain
sustain_SOURCES= \
		SUSTAINCatUnit.cpp \
		SUSTAINCluster.cpp \
		SUSTAINDimension.cpp \
                SUSTAINModel.cpp \
		SUSTAINNetwork.cpp \
		main.cpp


sustain_LDADD=$(top_builddir)/cog/libcogc++.la
