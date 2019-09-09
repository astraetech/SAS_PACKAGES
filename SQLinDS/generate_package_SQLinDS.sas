
%include "C:\SAS_PACKAGES\generatePackage.sas";

ods html;
%generatePackge(filesLocation=C:\SAS_PACKAGES\SQLinDS)


/*

filename packages "C:\SAS_PACKAGES";
%include packages(loadpackage.sas);

dm 'log;clear';
%loadpackage(SQLinDS)

%helpPackage(SQLinDS)
%unloadPackage(SQLinDS)
*/

/*
 SQLinDS
,1.0
,Bartosz Jablonski
,yabwon@gmail.com



,packageDescription=%NRSTR(

The SQLinDS package is implementation of the concept intrduced in: 
"Use the Full Power of SAS in Your Function-Style Macros"
the article by Mike Rhoads, Westat, Rockville, MD

Copy of the article can be found at:
https://support.sas.com/resources/papers/proceedings12/004-2012.pdf

SQLinDS package provides following components:
- dsSQL_inner macro 
- dsSQL function
- SQL macro

Library DSSQL is created in a subdirectory of the WORK library.

Data set DSSQL.SQLINDS_EXAMPLE is created as a test example.

)

*/
