/* This is the description file for the package.         */
/* The collon (:) is a field separator and is restricted */
/* in lines of the header part.                          */

/* **HEADER** */
Type: Package                                    :/*required, not null, constant value*/
Package: SQLinDS                                 :/*required, not null, nameing restrictions like for a dataset name! */
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
the macro-function-sanwich concept introduced in: 
"Use the Full Power of SAS in Your Function-Style Macros"
the article by Mike Rhoads, Westat, Rockville, MD

Copy of the article can be found at:
https://support.sas.com/resources/papers/proceedings12/004-2012.pdf

SQLinDS package provides following components:
 1) %dsSQL_inner() macro 
 2) dsSQL() function
 3) %SQL() macro

Library DSSQL is created in a subdirectory of the WORK library.

Data set DSSQL.SQLINDS_EXAMPLE is created as a test example.

DESCRIPTION END:
