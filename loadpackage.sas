/*** HELP START ***/

/**###################################################################**/
/*                                                                     */
/*  Copyright Bartosz Jablonski, July 2019.                            */
/*                                                                     */
/*  Code is free and open source. If you want - you can use it.        */
/*  I tested it the best I could                                       */
/*  but it comes with absolutely no warranty whatsoever.               */
/*  If you cause any damage or something - it will be your own fault.  */
/*  You have been warned! You are using it on your own risk.           */
/*  However, if you decide to use it remember to mention author.       */
/*  Bartosz Jablonski (yabwon@gmail.com)                               */
/*                                                                     */
/**###################################################################**/

/* Macros to load or to unload SAS packages */
/* A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embeaded inside the zip).
*/
/*
TODO:
- makro do listowania dostepnych pakietow ze wskazanego folderu
*/
/*** HELP END ***/

/*** HELP START ***/

%macro loadPackage(
  packageName                         /* name of a package, e.g. myPackageFile.zip, not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, by default it looks for location of "packages" library */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, null by default */
)/secure;
/*** HELP END ***/
  filename package ZIP 
  /* put location of package myPackageFile.zip here */
    "&path./&packageName..zip" %unquote(&options.)
  ;
  %if %sysfunc(fexist(package)) %then
    %do;
      %include package(packagemetadata.sas) / &source2.;
      filename package clear;
      filename package ZIP 
        "&path./&packageName..zip" %unquote(&options.)  
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %include package(load.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist;
  filename package clear;
%mend loadPackage;

/*** HELP START ***/

%macro unloadPackage(
  packageName                         /* name of a package, e.g. myPackageFile.zip, not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, by default it looks for location of "packages" library */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, null by default */
)/secure;
/*** HELP END ***/
  filename package ZIP 
  /* put location of package myPackageFile.zip here */
    "&path./&packageName..zip" %unquote(&options.)
  ;
  %if %sysfunc(fexist(package)) %then
    %do;
      %include package(packagemetadata.sas) / &source2.;
      filename package clear;
      filename package ZIP 
        "&path./&packageName..zip" %unquote(&options.)  
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %include package(unload.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist;
  filename package clear;
%mend unloadPackage;

/*** HELP START ***/

%macro helpPackage(
  packageName                         /* name of a package, e.g. myPackageFile.zip, not null  */
, helpKeyword                         /* phrase to search, * means print all help */
, path = %sysfunc(pathname(packages)) /* location of a package, by default it looks for location of "packages" library */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, null by default */
)/secure;
/*** HELP END ***/
  filename package ZIP 
  /* put location of package myPackageFile.zip here */
    "&path./&packageName..zip" %unquote(&options.)
  ;
  %if %sysfunc(fexist(package)) %then
    %do;
      %include package(packagemetadata.sas) / &source2.;
      filename package clear;
      filename package ZIP 
        "&path./&packageName..zip" %unquote(&options.) 
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %include package(help.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist;
  filename package clear;
%mend helpPackage;


/*** HELP START ***/

/* use example: 
   assuming that _THIS_FILE_ and a macroarray.zip package 
   are located in the "C:/SAS_PACKAGES/" folder 
   coppy the following code int autoexec.sas
   or run it in your SAS session
*/
/*
libname packages "C:/SAS_PACKAGES/";
%include "%sysfunc(pathname(packages))/loadpackage.sas";

%loadPackage(macroarray)
%helpPackage(macroarray)
%unloadPackage(macroarray)

OR

filename packages "C:/SAS_PACKAGES";
%include packages(loadpackage.sas);

%loadpackage(macroarray)
%helpPackage(macroarray)
%unloadPackage(macroarray)

*/
/*** HELP END ***/
