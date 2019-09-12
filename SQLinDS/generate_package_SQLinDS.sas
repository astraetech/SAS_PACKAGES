
%include "C:\SAS_PACKAGES\generatePackage.sas";

ods html;
%generatePackge(filesLocation=C:\SAS_PACKAGES\SQLinDS)


/*
 filename packages "C:\SAS_PACKAGES";
%include packages(loadpackage.sas);

dm 'log;clear';
%loadpackage(SQLinDS)

%helpPackage(SQLinDS)
%helpPackage(SQLinDS,*)

%unloadPackage(SQLinDS)
*/
