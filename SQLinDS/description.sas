/* This is the description file for the package.            */
/* The collon (:) is a field separator and is restricted    */
/* in lines other than lines of the description part.       */

packageName: SQLinDS                   :/*required, not null*/
packageVersion: 1.0                    :/*required, not null*/
packageAuthor: Bartosz Jablonski       :/*required, not null*/
packageAuthorContact: yabwon@gmail.com :/*required, not null*/

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
