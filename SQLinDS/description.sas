/* This is the description file for the package.         */
/* The collon (:) is a field separator and is restricted */
/* in lines of the header part.                          */

/* **HEADER** */
Type: Package                                    :/*required, not null, constant value*/
Package: SQLinDS                                 :/*required, not null, up to 24 characters, naming restrictions like for a dataset name! */
Title: SQL queries in Data Step                  :/*required, not null*/
Version: 1.0                                     :/*required, not null*/
Author: Bartosz Jablonski (yabwon@gmail.com)     :/*required, not null*/
Maintainer: Bartosz Jablonski (yabwon@gmail.com) :/*required, not null*/
License: MIT                                     :/*required, not null, values: MIT, GPL2, BSD, etc.*/
Encoding: UTF8                                   :/*required, not null, values: UTF8, WLATIN1, LATIN2, etc. */

/* **DESCRIPTION** */
/* All the text below will be used in help */
DESCRIPTION START:

The SQLinDS package is an implementation of  
the macro-function-sandwich concept introduced in: 
"Use the Full Power of SAS in Your Function-Style Macros"
the article by Mike Rhoads, Westat, Rockville, MD

Copy of the article can be found at:
https://support.sas.com/resources/papers/proceedings12/004-2012.pdf

SQLinDS package provides following components:
 1) %dsSQL_inner() macro 
 2) dsSQL() function
 3) %SQL() macro

Library DSSQL is created in a subdirectory of the WORK library.

*****************************************************************************
License:
Copyright (c) 2019 Bartosz Jablonski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*****************************************************************************

DESCRIPTION END:
