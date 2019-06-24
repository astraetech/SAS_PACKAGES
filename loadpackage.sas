/**###################################################################**/
/*                                                                     */
/*  Copyright Bartosz Jablonski, July 2019.                            */
/*                                                                     */
/*  Code is free and open source. If you want - you can use it.        */
/*  I tested it the best I could                                       */
/*  but it comes with absolutely no warranty whatsoever.               */
/*  If you cause any damage or something - it will be your own fault.  */
/*  You've been warned! You are using it on your own risk.             */
/*  However, if you decide to use it don't forget to mention author.   */
/*  Bartosz Jablonski (yabwon@gmail.com)                               */
/*                                                                     */
/**###################################################################**/

/* Macros to load or to unload SAS packages */
/* A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embeaded inside the zip).
*/


%macro loadPackage(
  packageName                                     /* name of a package, e.g. myPackageFile.zip, not null  */
, path = %sysfunc(pathname(packages))             /* location of a package, by default it looks for location of "packages" library */
, options = %str(LOWCASE_MEMNAME ENCODING = utf8) /* possible options for ZIP filename */
, source2 = /*source2*/                           /* option to print out details, null by default */
);
  filename package ZIP 
  /* put location of package myPackageFile.zip here */
    "&path./&packageName..zip" %unquote(&options.)
  ;
  %if %sysfunc(fexist(package)) %then
    %do;
      %include package(load.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist;
  filename package clear;
%mend loadPackage;

%macro unloadPackage(
  packageName                                     /* name of a package, e.g. myPackageFile.zip, not null  */
, path = %sysfunc(pathname(packages))             /* location of a package, by default it looks for location of "packages" library */
, options = %str(LOWCASE_MEMNAME ENCODING = utf8) /* possible options for ZIP filename */
, source2 = /*source2*/                           /* option to print out details, null by default */
);
  filename package ZIP 
  /* put location of package myPackageFile.zip here */
    "&path./&packageName..zip" %unquote(&options.)
  ;
  %if %sysfunc(fexist(package)) %then
    %do;
      %include package(unload.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist;
  filename package clear;
%mend unloadPackage;

%macro helpPackage(
  packageName                                     /* name of a package, e.g. myPackageFile.zip, not null  */
, path = %sysfunc(pathname(packages))             /* location of a package, by default it looks for location of "packages" library */
, options = %str(LOWCASE_MEMNAME ENCODING = utf8) /* possible options for ZIP filename */
, source2 = /*source2*/                           /* option to print out details, null by default */
);
  filename package ZIP 
  /* put location of package myPackageFile.zip here */
    "&path./&packageName..zip" %unquote(&options.)
  ;
  %if %sysfunc(fexist(package)) %then
    %do;
      %include package(help.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist;
  filename package clear;
%mend unloadPackage;



/* use example: 
   assuming that _THIS_FILE_ and a macroarray.zip package 
   are located in the 'C:/SAS_PACKAGES/' folder 
   coppy the following code int autoexec.sas
   or run it in your SAS session
*/
/*
libname packages "C:/SAS_PACKAGES/";
%include "%sysfunc(pathname(packages))/loadpackage.sas";

%loadPackage(macroarray)

%helpPackage(macroarray)

%unloadPackage(macroarray)
*/
