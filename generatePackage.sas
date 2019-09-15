/*** HELP START ***/

/**###################################################################**/
/*                                                                     */
/*  Copyright Bartosz Jablonski, September 2019.                       */
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

/* Macros to generte SAS packages */
/* A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embeaded inside the zip).
*/

/*** HELP END ***/


/*** HELP START ***/
%macro GeneratePackge(
 filesLocation=%sysfunc(pathname(work))/%lowcase(&packageName.) /* place for packages' files */
)/secure;
/*** HELP END ***/
%local zipReferrence filesWithCodes _DESCR_ _RC_;
%let   zipReferrence = _%sysfunc(datetime(), hex6.)_;
%let   filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;
%let   _DESCR_ = _%sysfunc(datetime(), hex6.)c;

/* collect package metadata from the description .sas file */
filename &_DESCR_. "&filesLocation./description.sas" lrecl = 256;

%if %sysfunc(fexist(&_DESCR_.)) %then 
  %do;
    %put NOTE: Creating package%str(%')s metadata; 

    %local packageName       /* name of the package, required */  
           packageVersion    /* version of the package, required */
           packageTitle      /* title of the package, required*/
           packageAuthor     /* required */
           packageMaintainer /* required */
           ;
    data _null_;
      infile &_DESCR_.;
      input;
    
      select;
        when(upcase(scan(_INFILE_, 1, ":")) = "PACKAGE")    call symputX("packageName",       scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "VERSION")    call symputX("packageVersion",    scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "AUTHOR")     call symputX("packageAuthor",     scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "MAINTAINER") call symputX("packageMaintainer", scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "TITLE")      call symputX("packageTitle",      scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "ENCODING")   call symputX("packageEncoding",   scan(_INFILE_, 2, ":"),"L");
        
        /* stop at the begining of description */
        when(upcase(scan(_INFILE_, 1, ":")) = "DESCRIPTION START") stop;
        otherwise;
      end;
    run;
 
    /* test for required descriptors */
    %if (%nrbquote(&packageName.) = )
     or (%nrbquote(&packageVersion.) = )
     or (%nrbquote(&packageAuthor.) = )
     or (%nrbquote(&packageMaintainer.) = )
     or (%nrbquote(&packageTitle.) = )
     or (%nrbquote(&packageEncoding.) = )
      %then
        %do;
          %put ERROR: At least one of descriptors is missing!;
          %put ERROR- They are required to create package.;
          %put ERROR- &=packageName.;
          %put ERROR- &=packageTitle.;
          %put ERROR- &=packageVersion.;
          %put ERROR- &=packageAuthor.;
          %put ERROR- &=packageMaintainer.;
          %put ERROR- &=packageEncoding.;          
          %put ERROR- ;
          %abort;
        %end;
  %end;
%else
  %do;
    %put ERROR: The description.sas file is missing!;
    %put ERROR- The file is required to create package%str(%')s metadata;
    %abort;
  %end;

/* create or replace the ZIP file for package  */
filename &zipReferrence. ZIP "&filesLocation./%lowcase(&packageName.).zip";

%if %sysfunc(fexist(&zipReferrence.)) %then 
  %do;
    %put NOTE: Deleting file "&filesLocation./%lowcase(&packageName.).zip";
    %let _RC_ = %sysfunc(fdelete(&zipReferrence.));
  %end;

/*** HELP START ***/
/* 
  Locate all files with code in base folder (i.e. at filesLocation directory) 
*/
/*
  Remember to prepare description.sas file with
  the following obligatory information:
--------------------------------------------------------------------------------------------
Type: Package
Package: ShortPackageName                                
Title: A title/brief info for log note about your packages                 
Version: X.Y                                    
Author: Firstname1 Lastname1 (xxxxxx1@yyyyy.com), Firstname2 Lastname2 (xxxxxx2@yyyyy.com)     
Maintainer: Firstname Lastname (xxxxxx@yyyyy.com)
License: GPL2
Encoding: UTF8                                  

DESCRIPTION START:
  Xxxxxxxxxxx xxxxxxx xxxxxx xxxxxxxx xxxxxxxx. Xxxxxxx
  xxxx xxxxxxxxxxxx xx xxxxxxxxxxx xxxxxx. Xxxxxxx xxx
  xxxx xxxxxx. Xxxxxxxxxxxxx xxxxxxxxxx xxxxxxx.
DESCRIPTION END:
--------------------------------------------------------------------------------------------

  Name of the 'type' of folder and files.sas inside must be in low case letters.

  If order of loading is important, the 'sequential number'
  can be used to order multiple types in the wey you wish.

  The "tree structure" of the folder could be for example as follows:

--------------------------------------------------------------------------------------------
  ..
   |
   +-000_libname [one file one libname]
   |
   +-001_macro [one file one macro]
   |
   +-002_function [one file one function]
   |
   +-003_format [one file one format]
   |
   +-004_data [one file one dataset]
   |
   +-005_exec [content of the files will be printed to the log before execution]
   |
   +-006_format [if codes are dependent you can order them in folders, 
   |             e.g. 003 will be executed before 006]
   |
   +-007_function
   |
   +-<sequential number>_<type [in lowcase]>
   |
   +-...
   |
   +-00n_clean [if you need to clean something up after exec file execution]
   |
   +-...
   |
   ...
--------------------------------------------------------------------------------------------

*/
/*** HELP END ***/

/* collect the data */
data &filesWithCodes.;
  base = "&filesLocation.";
  length folder file lowcase_name $ 256 folderRef fileRef $ 8; 
  drop lowcase_name;

  folderRef = "_%sysfunc(datetime(), hex6.)0";

  rc=filename(folderRef, base);
  folderid=dopen(folderRef);

  do i=1 to dnum(folderId); drop i;
    folder = dread(folderId, i); 
    if folder NE lowcase(folder) then
      do;
        put 'ERROR: Folder should be named ONLY with low case letters.';
        put 'ERROR- Current value is: ' folder;
        lowcase_name = lowcase(folder);
        put 'ERROR- Try: ' lowcase_name;
        put;
        abort;
      end;
    order = scan(folder, 1, "_");
    type  = scan(folder,-1, "_");

    fileRef = "_%sysfunc(datetime(), hex6.)1";
    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    file = ' ';
    if fileId then 
      do j = 1 to dnum(fileId); drop j;
        file = dread(fileId, j);
            if file NE lowcase(file) then
              do;
                put 'ERROR: File with code should be named ONLY with low case letters.';
                put 'ERROR- Current value is: ' file;
                lowcase_name = lowcase(file);
                put 'ERROR- Try: ' lowcase_name;
                put;
                abort;
              end;
        fileshort = substr(file, 1, length(file) - 4); /* filename.sas -> filename */
        output;
      end;
    rc = dclose(fileId);
    rc = filename(fileRef);
  end;

  rc = dclose(folderid);
  rc = filename(folderRef);
  stop;
run;
proc sort data = &filesWithCodes.;
  by order type file;
run;
/*
proc contents data = &filesWithCodes.;
run;
*/
title1 "Package's location: &filesLocation.";
title2 "List of files for &packageName., version &packageVersion.";
title3 "Datetime: %qsysfunc(datetime(), datetime19.), SAS version: &sysvlong.";
title4 "Package's encoding: '&packageEncoding.', session's encoding: '&sysencoding.'.";
proc print data = &filesWithCodes.(drop=base);
run;
title;

/* packages's description */
data _null_;
  infile &_DESCR_.;
  file &zipReferrence.(description.sas);
  input; 
  put _INFILE_;
run;

/* package's metadata */
data _null_;
  if 0 then set &filesWithCodes. nobs=NOBS;
  if NOBS = 0 then
    do;
      putlog "WARNING:[&sysmacroname.] No files to create package.";
      stop;
    end;
  file &zipReferrence.(packagemetadata.sas);

  put ' data _null_; '; /* simple "%local" returns error while loading package */
  put ' call symputX("packageName",       " ", "L");';
  put ' call symputX("packageVersion",    " ", "L");';
  put ' call symputX("packageTitle",      " ", "L");';  
  put ' call symputX("packageAuthor",     " ", "L");';
  put ' call symputX("packageMaintainer", " ", "L");';
  put ' call symputX("packageEncoding",   " ", "L");'; 
  put ' run; ';

  put ' %let packageName       =' "&packageName.;";
  put ' %let packageVersion    =' "&packageVersion.;";
  put ' %let packageTitle      =' "&packageTitle.;";
  put ' %let packageAuthor     =' "&packageAuthor.;";
  put ' %let packageMaintainer =' "&packageMaintainer.;";
  put ' %let packageEncoding   =' "&packageEncoding.;";

  put ' ; ';

  stop;
run;

/* loading package's files */
data _null_;
  if NOBS = 0 then stop;

  file &zipReferrence.(load.sas);
 
  put 'filename package list;' /;
  put ' %put NOTE- ;'; 
  put ' %put NOTE: ' @; put "Loading package &packageName., version &packageVersion.; ";
  put ' %put NOTE: ' @; put "*** &packageTitle. ***; ";
  put ' %put NOTE- ' @; put "Generated: %sysfunc(datetime(), datetime18.); ";
  put ' %put NOTE- ' @; put "Author(s): &packageAuthor.; ";
  put ' %put NOTE- ' @; put "Maintainer(s): &packageMaintainer.; ";
  put ' %put NOTE- ;';
  put ' %put NOTE- Write %nrstr(%%)helpPackage(' "&packageName." ') for the description;';
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***; ' /;

  put '%include package(packagemetadata.sas) / nosource2;' /; /* <- copied also to loadPackage macro */
  isFunction = 0;
  isFormat   = 0;

  do until(eof);
    set &filesWithCodes. end = EOF nobs=NOBS;
    if (upcase(type)=:'CLEAN') then continue; /* cleaning files are only included in unload.sas */
    put '%put NOTE- ;';
    put '%put NOTE- Element of type ' type 'from the file "' file +(-1) '" will be included;' /;

    if upcase(type)=:'EXEC' then
    do;
      put '%put NOTE- ;';
      put '%put NOTE- Executing the following code: ;';
      put '%put NOTE- *****************************;';
      put 'data _null_;';
      put '  infile package(_' folder +(-1) "." file +(-1) ') lrecl=32767;';
      put '  input;';
      put '  putlog "*> " _infile_;';
      put 'run;' /;
      put '%put NOTE- *****************************;';
      put '%put NOTE- ;';
    end;

    put '%include package(_' folder +(-1) "." file +(-1) ') / nosource2;' /;

    isFunction + (upcase(type)=:'FUNCTION');
    isFormat   + (upcase(type)=:'FORMAT'); 
  
    /* add the link to the functions' dataset, only for the first occurence */
    if 1 = isFunction and (upcase(type)=:'FUNCTION') then
      do;
        put "options APPEND=(cmplib = work.%lowcase(&packageName.));";
        put '%put NOTE- ;';
        put '%put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
      end;

    /* add the link to the formats' catalog, only for the first occurence  */
    if 1 = isFormat and (upcase(type)=:'FORMAT') then
      do;
        put "options INSERT=( fmtsearch = work.%lowcase(&packageName.) );";
        put '%put NOTE- ;';
        put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));'/;
      end;
  end;

  put '%put NOTE- ;';
  put '%put NOTE: '"Loading package &packageName., version &packageVersion.;";
  put '%put NOTE- *** END ***;' /;
  put "/* load.sas end */" /;
  stop;
run;

/* unloading package's objects */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence.(unload.sas);

  put 'filename package list;' /;
  put '%put NOTE: '"Unloading package &packageName., version &packageVersion.;";
  put '%put NOTE- *** START ***;' /;

  /* include "cleaning" files */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF nobs = NOBS;
    if not (upcase(type)=:'CLEAN') then continue;
    put '%put NOTE- Code of type ' type 'generated from the file "' file +(-1) '" will be executed;';
    put '%put NOTE- ;' /;
    put '%put NOTE- Executing the following code: ;';
    put '%put NOTE- *****************************;';
    put 'data _null_;';
    put '  infile package(_' folder +(-1) "." file +(-1) ') lrecl=32767;';
    put '  input;';
    put '  putlog "*> " _infile_;';
    put 'run;' /;
    put '%put NOTE- *****************************;';
    put '%put NOTE- ;' /;

    put '%include package(_' folder +(-1) "." file +(-1) ') / nosource2;' /;
  end;

  /* delete macros and formats */
  put 'proc sql;';
  put '  create table _%sysfunc(datetime(), hex16.)_ as';
  put '  select memname, objname, objtype';
  put '  from dictionary.catalogs';
  put '  where ';
  put '  (';
  put '   objname in ("*"' /;
  /* list of macros */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF nobs = NOBS;
    if not (upcase(type)=:'MACRO') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put ',"' fileshort upcase32. '"';
  end;
  /**/
  put '  )';
  put '  and objtype = "MACRO"';
  put '  and libname  = "WORK"';
  put '  )';
  put '  or';
  put '  (';
  put '   objname in ("*"' /;
  /* list of formats */
  isFormat = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FORMAT') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put ',"' fileshort upcase32. '"';
    isFormat + 1;
  end;
  put '  )';
  put '  and objtype in ("FORMAT" "FORMATC" "INFMT" "INFMTC")';
  put '  and libname  = "WORK"';
  put "  and memname = '%upcase(&packageName.)'";
  put '  )';

  put '  order by objtype, memname, objname';
  put '  ;';
  put 'quit;';

  put 'data _null_;';
  put '  do until(last.memname);';
  put '    set _last_;';
  put '    by objtype memname;';
  put '    if first.memname then call execute("proc catalog cat = work." !! strip(memname) !! " force;");';
  put '    call execute("delete " !! strip(objname) !! " /  et =" !! objtype !! "; run;");';
  put '  end;';
  put '  call execute("quit;");';
  put 'run;';
  put 'proc delete data = _last_;';
  put 'run;';

  /* delete the link to the formats catalog */
  if isFormat then
    do;
      put "proc delete data = work.%lowcase(&packageName.)(mtype = catalog);";
      put 'run;';
      put 'options fmtsearch = (%unquote(%sysfunc(tranwrd(
       %lowcase(%sysfunc(getoption(fmtsearch)))
      ,%str(' "work.%lowcase(&packageName.)" '), %str() ))));';
      put 'options fmtsearch = (%unquote(%sysfunc(compress(
       %sysfunc(getoption(fmtsearch))
      , %str(()) ))));';
      put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));' /;
    end;

  /* delete functions */
  put "proc fcmp outlib = work.%lowcase(&packageName.).package;";
  isFunction = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FUNCTION') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put 'deletefunc ' fileshort ';';
    isFunction + 1;
  end;
  put "run;" /;

  /* delete the link to the functions dataset */
  if isFunction then
    do;
      put 'options cmplib = (%unquote(%sysfunc(tranwrd(
       %lowcase(%sysfunc(getoption(cmplib)))
      ,%str(' "work.%lowcase(&packageName.)" '), %str() ))));';
      put 'options cmplib = (%unquote(%sysfunc(compress(
       %sysfunc(getoption(cmplib))
      ,%str(()) ))));';
      put '%put; %put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
    end;
   
  /* delete datasets */
  put "proc sql noprint;";
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'DATA') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put 'drop table ' fileshort ';';
  end;
  put "quit;" /;

  /* delete libraries */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'LIBNAME') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be cleared;';
    put '%put NOTE- ;' /;
    put 'libname ' fileshort ' clear;';
  end;
  put "run;" /;
 
  put '%put NOTE: '"Unloading package &packageName., version &packageVersion.;";
  put '%put NOTE- *** END ***;';
  put '%put NOTE- ;';
 
  put "/* unload.sas end */";
  stop;
run;

/* package's help */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence.(help.sas);
  length strX $ 32767;

  put 'filename package list;' /;
  put ' %put NOTE- ;';
  put ' %put NOTE: '"Help for package &packageName., version &packageVersion.;";
  put ' %put NOTE: ' @; put "*** &packageTitle. ***; ";
  put ' %put NOTE- ' @; put "Generated: %sysfunc(datetime(), datetime18.); ";
  put ' %put NOTE- ' @; put "Author(s): &packageAuthor.; ";
  put ' %put NOTE- ' @; put "Maintainer(s): &packageMaintainer.; ";
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***;' /;
  
  /* Use helpKeyword macrovariable to search for content (filename and type) */
  /* put '%local ls_tmp ps_tmp notes_tmp source_tmp;                       ';*/
  put '%let ls_tmp     = %sysfunc(getoption(ls));         ';
  put '%let ps_tmp     = %sysfunc(getoption(ps));         ';
  put '%let notes_tmp  = %sysfunc(getoption(notes));      ';
  put '%let source_tmp = %sysfunc(getoption(source));     ';
  put 'options ls = MAX ps = MAX nonotes nosource;        ';
  put '%include package(packagemetadata.sas) / nosource2; ' /;

  put 'data _null_;                                                              ';
  put '  if strip(symget("helpKeyword")) = " " then                              ';
  put '    do until (EOF);                                                       ';
  put '      infile package(description.sas) end = EOF;                          ';
  put '      input;                                                              ';
  put '      if upcase(strip(_infile_)) = "DESCRIPTION END:" then printer = 0;   ';
  put '      if printer then put "*> " _infile_;                                 ';
  put '      if upcase(strip(_infile_)) = "DESCRIPTION START:" then printer = 1; ';
  put '    end;                                                                  ';
  put '  else stop;                                                              ';
  put 'run;                                                                      ' /;

  put 'data _%sysfunc(datetime(), hex16.)_;                           ';
  put 'infile cards4 dlm = "/";                                       ';
  put 'input @;                                                       ';
  put 'if 0 then output;                                              ';
  put 'length helpKeyword $ 64;                                       ';
  put 'retain helpKeyword "*";                                        ';
  put 'drop helpKeyword;                                              ';
  put 'if _N_ = 1 then helpKeyword = strip(symget("helpKeyword"));    ';
  put 'if FIND(_INFILE_, helpKeyword, "it") or helpKeyword = "*" then '; 
  put ' do;                                                           ';
  put '   input (folder order type file fileshort) (: $ 256.);        ';
  put '   output;                                                     ';
  put ' end;                                                          ';
  put 'cards4;                                                        ';

  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS nobs = NOBS;
    select;
      when (upcase(type) = "DATA")     fileshort2 = fileshort;
      when (upcase(type) = "MACRO")    fileshort2 = cats('%',fileshort,'()');
      when (upcase(type) = "FUNCTION") fileshort2 = cats(fileshort,'()');
      when (upcase(type) = "FORMAT")   fileshort2 = cats('$',fileshort);
      otherwise fileshort2 = fileshort;
    end;
    strX = catx('/', folder, order, type, file, fileshort, fileshort2);
    put strX;
  end;

  put ";;;;";
  put "run;" /;
/*
  put 'proc print;';
  put 'run;';
*/
  /* loop through content found and print info to the log */
  put 'data _null_;                                                                                                        ';
  put 'if strip(symget("helpKeyword")) = "" then do; stop; end;                                                            ';
  put 'if NOBS = 0 then do; ' /
        'put; put '' *> No help info found. Try %helpPackage(packageName,*) to display all.''; put; stop; ' / 
      'end; ';
  put '  do until(EOFDS);                                                                                                  ';
  put '    set _last_ end = EOFDS nobs = NOBS;                                                                             ';
  put '    length memberX $ 1024;                                                                                          ';
  put '    memberX = cats("_",folder,".",file);                                                                            ';
  /* inner datastep in call execute to read each embedaded file */
  put '    call execute("data _null_;                                                                                   ");';
  put '    call execute("infile package(" || strip(memberX) || ") end = EOF;                                            ");';
  put '    call execute("    printer = 0;                                                                               ");';
  put '    call execute("    do until(EOF);                                                                             ");';
  put '    call execute("      input;                                                                                   ");';
  put '    call execute("      if strip(_infile_) = cat(""/"",""*** "",""HELP END"","" ***"",""/"") then printer = 0;   ");';
  put '    call execute("      if printer then put ""*> "" _infile_;                                                    ");';
  put '    call execute("      if strip(_infile_) = cat(""/"",""*** "",""HELP START"","" ***"",""/"") then printer = 1; ");';
  put '    call execute("    end;                                                                                       ");';
  put '    call execute("  put ""*> "" / ""*> "";                                                                       ");';
  put '    call execute("  stop;                                                                                        ");';
  put '    call execute("run;                                                                                           ");';
  put '    if lowcase(type) =: "data" then                                                                                 ';
  put '      do;                                                                                                           ';
  put '        call execute("title ""Dataset " || strip(fileshort) || " from package &packageName. "";                  ");';
  put '        call execute("proc contents data = " || strip(fileshort) || "; run; title;                               ");';
  put '      end;                                                                                                          ';
  /**/
  put "  end; ";
  put "  stop; ";
  put "run; ";
  
  /* cleanup */
  put "proc delete data = _last_; ";
  put "run; ";
  put 'options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.; ' /;
 
  put '%put NOTE: '"Help for package &packageName., version &packageVersion.;";
  put '%put NOTE- *** END ***;' /; 
  put "/* help.sas end */";

  stop;
run;

/* create package's content */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  set &filesWithCodes. nobs = NOBS;

  call execute(cat ('filename _IN_ "', catx('/', base, folder, file), '";'));
  call execute(cats("filename _OUT_ ZIP '", base, "/%lowcase(&packageName.).zip' member='_", folder, ".", file, "';") );
  call execute('data _null_;');
  call execute('  rc = fcopy("_IN_", "_OUT_");');
  call execute('run;');
  call execute('filename _IN_  clear;');
  call execute('filename _OUT_ clear;');
run;

proc sql;
  drop table &filesWithCodes.;
quit;
filename &zipReferrence. clear;
%mend GeneratePackge;


/*

options mprint;
ods html;
%GeneratePackge(
 testowyPackageName
,0.01
,author
,contact
,filesLocation=E:\SAS_WORK_5400\testyGeneratePackage
)

*/

/*
TODO:
- modyfikacja helpa, sprawdzanie kodu danje funkcji/makra/typu [v]

- opcjonalne sortowanie nazw folderow(<numer>_<typ>) [v]

- wewnętrzna nazwaz zmiennej z nazwa pakietu (na potrzeby kompilacji) [v]

- weryfikacja srodaowiska

- weryfikacja "niepustosci" obowiazkowych argumentow   [v]

- dodac typ "clear" do czyszczenia po plikach 'exec'

- doadc sprawdzanie liczby wywołan procedury fcmp, format i slowa '%macro(' w plikach z kodami

- syspackages - makrozmienna z lista zaladowanych pakietow
*/

/*

%include "C:\SAS_PACKAGES\generatePackage.sas";

ods html;
%generatePackge(filesLocation=C:\SAS_PACKAGES\SQLinDS)
*/

/*
*"C:\SAS_PACKAGES\testyGeneratoraPakietow";

libname  packages "E:\SAS_WORK_5400\testyGeneratePackage";
filename packages "E:\SAS_WORK_5400\testyGeneratePackage";

%include packages(loadpackage.sas);

dm 'log;clear';
%loadpackage(testowypackagename)


*/
/*

%let helpKeyword=*;
%helpPackage(testowypackagename)
%unloadPackage(testowypackagename)

                     
filename package ZIP "E:\SAS_WORK_5400\testyGeneratePackage\testowypackagename.zip";

%put %sysfunc(pathname(package));

%include package(load.sas);
%help()???
%include package(unload.sas);

filename package ZIP "C:\SAS_PACKAGES\testowypackagename.zip";
%include package(load.sas);
%include package(unload.sas);

filename package ZIP "C:\SAS_PACKAGES\macroarray.zip";
%include package(load.sas);
%include package(unload.sas);
*/
