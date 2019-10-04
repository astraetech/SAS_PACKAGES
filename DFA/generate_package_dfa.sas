
%include "C:\SAS_PACKAGES\generatePackage.sas";

ods html;
%generatePackge(filesLocation=C:\SAS_PACKAGES\DFA)


/*
 * filename reference "packages" and "package" are keywords;
 * the first one should be used to point folder with packages;
 * the second is used internaly by macros;

filename packages "C:\SAS_PACKAGES";
%include packages(loadpackage.sas);

dm 'log;clear';
%loadpackage(DFA)

%helpPackage(DFA)
%helpPackage(DFA,*)

%unloadPackage(DFA)
*/
