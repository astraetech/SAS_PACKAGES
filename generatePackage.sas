/*** HELP START ***/
%macro GeneratePackge(
 packageName
,packageVersion
,packageAuthor
,packageAuthorContact
,filesLocation=%sysfunc(pathname(work))/%lowcase(&packageName.)
);
/*** HELP END ***/
%local zipReferrence filesWithCodes _RC_;
%let   zipReferrence = _%sysfunc(datetime(), hex6.)_;
%let   filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;

filename &zipReferrence. ZIP "&filesLocation./%lowcase(&packageName.).zip";

%if %sysfunc(fexist(&zipReferrence.)) %then 
%do;
%put NOTE: Deleting file "&filesLocation./%lowcase(&packageName.).zip";
%let _RC_ = %sysfunc(fdelete(&zipReferrence.));
%end;

/* locate files with codes in base folder */
/*
the "tree structure" of the folder 
could be for example:
base
   |
   +-001_macro [one file one macro]
   |
   +-002_function [one file one function]
   |
   +-003_format [one file one format]
   |
   +-004_data [one file one dataset]
   |
   +-005_exec 
   |
   +-006_format
   |
   +-007_function
   |
   +-<sequential number>_<type in lowcase>
   |
   +-...
   |
   ...
*/
/* collect the data */
data &filesWithCodes.;
  base = "&filesLocation.";
  length folder file $ 256 folderRef fileRef $ 8;

  folderRef = "_%sysfunc(datetime(), hex6.)0";

  rc=filename(folderRef, base);
  folderid=dopen(folderRef);

  do i=1 to dnum(folderId); drop i;
    folder = dread(folderId, i);
    order = scan(folder, 1, "_");
    type = scan(folder, 2, "_");

    fileRef = "_%sysfunc(datetime(), hex6.)1";
    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    file = ' ';
    if fileId then 
      do j = 1 to dnum(fileId); drop j;
        file = dread(fileId, j);
        fileshort = scan(file, 1, ".");
        output;
      end;
    rc = dclose(fileId);
    rc = filename(fileRef);
  end;

  rc = dclose(folderid);
  rc = filename(folderRef);
  stop;
run;
title "List of files for &packageName., version &packageVersion.";
proc print data = &filesWithCodes.;
run;
title;

data _null_;
  file &zipReferrence.(load.sas);
  
  put 'filename package list;' /;
  put ' %put NOTE: ' @; put "Loading package &packageName., version &packageVersion.; ";
  put ' %put NOTE- ' @; put "Author(s): &packageAuthor.; ";
  put ' %put NOTE- ' @; put "Contact at: &packageAuthorContact.; ";

  put ' %put NOTE- *** START ***; ' /;

  isFunction = 0;
  isFormat   = 0;

  do until(eof);
    set &filesWithCodes. end = EOF;
    put '%put NOTE- Element of type ' type 'from the file "' file '" will be included;' ;
    put '%include package(_' folder +(-1) "." file ') / nosource2;' /;
    isFunction + (upcase(type)=:'FUNCTION');
    isFormat   + (upcase(type)=:'FORMAT');
  end;
  
  /* add the link to the functions' dataset */
  if isFunction then
    do;
      put "options APPEND=(cmplib = work.%lowcase(&packageName.));";
      put '%put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));';
    end;

  /* add the link to the formats' catalog */
  if isFormat then
    do;
      put "options insert=(fmtsearch = work.%lowcase(&packageName.));";
      put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));';
    end;

  put '%put NOTE: '"Loading package &packageName., version &packageVersion.;";
  put '%put NOTE- *** END ***;' /;
  put "/* load.sas end */" /;
  stop;
run;

data _null_;
  file &zipReferrence.(unload.sas);

  put 'filename package list;' /;
  put '%put NOTE: '"Unloading package &packageName., version &packageVersion.;";
  put '%put NOTE- *** START ***;' /;

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
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'MACRO') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file '" will be deleted;' ;
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
    put '%put NOTE- Element of type ' type 'generated from the file "' file '" will be deleted;' ;
    put ',"' fileshort upcase32. '"';
    isFormat + 1;
  end;
  put '  )';
  put '  and objtype = "FORMAT"';
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

  /* delete the link to the formats' catalog */
  if isFormat then
    do;
      put "proc delete data = work.%lowcase(&packageName.)(MTYPE = CATALOG);";
      put 'run;';
      put 'options fmtsearch = (%unquote(%sysfunc(tranwrd(
       %sysfunc(getoption(fmtsearch))
      ,%str(' "work.%lowcase(&packageName.)" '), %str() ))));';
      put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));' /;
    end;

  /* delete functions */
  put "PROC FCMP OUTLIB = work.%lowcase(&packageName.).package;";
  isFunction = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FUNCTION') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file '" will be deleted;' ;
    put 'DELETEFUNC ' fileshort ';';
    isFunction + 1;
  end;
  put "RUN;" /;

  /* delete the link to the functions' dataset */
  if isFunction then
    do;
      put 'options cmplib = (%unquote(%sysfunc(tranwrd(
       %sysfunc(getoption(cmplib))
      ,%str(' "work.%lowcase(&packageName.)" '), %str() ))));';
      put '%put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
    end;
    
  put '%put NOTE: '"Unloading package &packageName., version &packageVersion.;";
  put '%put NOTE- *** END ***;' /; 
  put "/* unload.sas end */";
  stop;
run;

filename _DUMMY_ TEMP;
data _null_;
  file &zipReferrence.(help.sas);
  
  if _N_ = 1 then 
    do;
      put 'filename package list;' /;
      put '%put NOTE: '"Unloading package &packageName., version &packageVersion.;";
      put '%put NOTE- *** START ***;' /;
      
      put 'options ls = MAX ps = MAX;';
      put 'data _null_;';
      put 'infile cards4;';
      put 'input;';
      put 'putlog "*> " _INFILE_;';
      put 'cards4;';
    end;
  
  set &filesWithCodes. end = EOFDS;
  
  length strX $ 32767;
  strX = catx('/', base, folder, file);
  infile _DUMMY_ FILEVAR = strX end = EOF;

  printer = 0;
  do until(EOF);
    input;

    if _infile_ = "/*** HELP START ***/" then printer = 1;  
    if printer then put _infile_;
    if _infile_ = "/*** HELP END ***/" then 
      do; 
        printer = 0; 
        put " "; 
      end;
  end;

  if EOFDS then 
  do;
    put ";;;;";
    put "run;" /;
    put '%put NOTE: '"Unloading package &packageName., version &packageVersion.;";
    put '%put NOTE- *** END ***;' /; 
    put "/* unload.sas end */";
    put "/* help.sas end */";
  end;
run;
filename _DUMMY_ clear;

data _null_;
  set &filesWithCodes.;

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

options mprint;
%GeneratePackge(
 testowyPackageName
,0.01
,author
,contact
,filesLocation=E:\SAS_WORK_5400\testyGeneratePackage
)


filename packages "E:\SAS_WORK_5400\testyGeneratePackage";
%include packages(loadpackage.sas);

%loadpackage(testowypackagename)

/*
%helpPackage(testowypackagename)
%unloadPackage(testowypackagename)
*/
