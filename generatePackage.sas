/*** HELP START ***/
%macro GeneratePackge(
 packageName          /* name of the package, required */  
,packageVersion       /* version of the package, required */
,packageAuthor        /* required */
,packageAuthorContact /* required */
,filesLocation=%sysfunc(pathname(work))/%lowcase(&packageName.) /* place for packages'files*/
)/secure;
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

/*** HELP START ***/
/* locate files with codes in base folder (i.e. at filesLocation directory) */
/*
the "tree structure" of the folder 
could be for example:
base
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
   +-005_exec 
   |
   +-006_format [if codes are dependent you can order them in folders]
   |
   +-007_function
   |
   +-<sequential number>_<type [in lowcase]>
   |
   +-...
   |
   ...
*/
/*** HELP END ***/

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
    type  = scan(folder,-1, "_");

    fileRef = "_%sysfunc(datetime(), hex6.)1";
    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    file = ' ';
    if fileId then 
      do j = 1 to dnum(fileId); drop j;
        file = dread(fileId, j);
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
title "List of files for &packageName., version &packageVersion.";
title2 "%qsysfunc(datetime(), datetime21.)";
proc print data = &filesWithCodes.;
run;
title;

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
  put ' call symputX("packageName",          " ", "L");';
  put ' call symputX("packageVersion",       " ", "L");';
  put ' call symputX("packageAuthor",        " ", "L");';
  put ' call symputX("packageAuthorContact", " ", "L");';
  put ' run; ';

  put ' %let packageName          =' "&packageName.;";
  put ' %let packageVersion       =' "&packageVersion.;";
  put ' %let packageAuthor        =' "&packageAuthor.;";
  put ' %let packageAuthorContact =' "&packageAuthorContact.;";
  put ' ; ';

  stop;
run;

/* loading package's files */
data _null_;
  if NOBS = 0 then stop;

  file &zipReferrence.(load.sas);
 
  put 'filename package list;' /;
  put ' %put NOTE: ' @; put "Loading package &packageName., version &packageVersion.; ";
  put ' %put NOTE: ' @; put "Generated: %sysfunc(datetime(), datetime18.); ";
  put ' %put NOTE- ' @; put "Author(s): &packageAuthor.; ";
  put ' %put NOTE- ' @; put "Contact(s) at: &packageAuthorContact.; ";

  put ' %put NOTE- *** START ***; ' /;

  put '%include package(packagemetadata.sas) / nosource2;' /;
  isFunction = 0;
  isFormat   = 0;

  do until(eof);
    set &filesWithCodes. end = EOF nobs=NOBS;
    put '%put NOTE- Element of type ' type +(-1) 'from the file "' file +(-1) '" will be included;' /;
    if upcase(type)=:'EXEC' then
    do;
      put '%put NOTE- Executing the following code: ;';
      put '%put NOTE- *****************************;';
      put 'data _null_;';
      put '  infile package(_' folder +(-1) "." file +(-1) ') lrecl=32767;';
      put '  input;';
      put '  putlog "*> " _infile_;';
      put 'run;' /;
      put '%put NOTE- *****************************;';
    end;

    put '%include package(_' folder +(-1) "." file +(-1) ') / nosource2;' /;
    isFunction + (upcase(type)=:'FUNCTION');
    isFormat   + (upcase(type)=:'FORMAT');
  end;
  
  /* add the link to the functions' dataset */
  if isFunction then
    do;
      put "options APPEND=(cmplib = work.%lowcase(&packageName.));";
      put '%put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
    end;

  /* add the link to the formats' catalog */
  if isFormat then
    do;
      put "options INSERT=( fmtsearch = work.%lowcase(&packageName.) );";
      put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));' /;
    end;

  put / '%put NOTE: '"Loading package &packageName., version &packageVersion.;";
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
    put '%put NOTE- Element of type ' type +(-1) 'generated from the file "' file +(-1) '" will be deleted;' /;
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
    put '%put NOTE- Element of type ' type +(-1) 'generated from the file "' file +(-1) '" will be deleted;' ;
    put ',"' fileshort upcase32. '"';
    isFormat + 1;
  end;
  put '  )';
  put '  and objtype in ("FORMAT" "INFORMAT")';
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
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;' ;
    put 'deletefunc ' fileshort ';';
    isFunction + 1;
  end;
  put "run;" /;

  /* delete the link to the functions' dataset */
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
    
  put '%put NOTE: '"Unloading package &packageName., version &packageVersion.;";
  put '%put NOTE- *** END ***;' /; 
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
  put '%put NOTE: '"Help for package &packageName., version &packageVersion.;";
  put '%put NOTE- *** START ***;' /;
  
  /* Use helpKeyword macrovariable to search for content (filename and type) */
  /*put '%local ls_tmp ps_tmp notes_tmp source_tmp;                     ';*/
  put '%let ls_tmp     = %sysfunc(getoption(ls));                     ';
  put '%let ps_tmp     = %sysfunc(getoption(ps));                     ';
  put '%let notes_tmp  = %sysfunc(getoption(notes));                  ';
  put '%let source_tmp = %sysfunc(getoption(source));                 ';
  put 'options ls = MAX ps = MAX nonotes nosource;                    ';
  put '%include package(packagemetadata.sas) / nosource2;             ' /;
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
    strX = catx('/', folder, order, type, file, fileshort);
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

- opcjonalne sortowanie nazw folderow(<numer>_<typ>)

- wewnętrzna nazwaz zmiennej z nazwa pakietu (na potrzeby kompilacji) [v]

- weryfikacja srodaowiska

- weryfikacja "niepustosci" obowiazkowych argumentow

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
