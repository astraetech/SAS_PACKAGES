
/**###################################################################**/
/*                                                                     */
/*  Copyright Xxxxxxx Yyyyyyyyy, Month Year.                           */
/*                                                                     */
/*  Code is free and open source. If you want - you can use it.        */
/*  But it comes with absolutely no warranty whatsoever.               */
/*  If you cause any damage or something - it will be your own fault.  */
/*  You've been warned! You are using it on your own risk.             */
/*  However, if you decide to use it don't forget to mention author.   */
/*  Xxxxxxx Yyyyyyyyy (xxxxxx@yyyyy.zzz)                               */
/*                                                                     */
/**###################################################################**/


%macro packageprototype_functions();

%local _cmplib_;
%let _cmplib_ = %sysfunc(compress(%sysfunc(getoption(cmplib)),%str(%(%))));
%put NOTE:[&sysmacroname.] *&=_cmplib_*;

options cmplib = _null_;

PROC FCMP outlib = work.packageprototype.functions;
  function f(x);
    return( x ** 2 );
  endsub;

  function g(x);
    return( x ** 3 );
  endsub;

  function h(x);
    return( x ** 4 );
  endsub;
run;

options cmplib = (%unquote(%sysfunc(tranwrd(&_cmplib_.,%str(work.packageprototype),%str()))) work.packageprototype);
%let _cmplib_ = %sysfunc(getoption(cmplib));
%put NOTE:[&sysmacroname.] *&=_cmplib_*;


%mend packageprototype_functions;
%packageprototype_functions()

/* delete macro packageprototype_functions since it is not needed */
proc sql;
  create table _%sysfunc(datetime(), hex16.)_ as
  select memname, objname
  from dictionary.catalogs
  where 
    objname = 'PACKAGEPROTOTYPE_FUNCTIONS'
    and objtype = 'MACRO'
    and libname  = 'WORK'
  order by memname, objname
  ;
quit;
data _null_;
  set _last_;
  call execute('proc catalog cat = work.' !! strip(memname) !! ' et = macro force;');
  call execute('delete ' !! strip(objname) !! '; run;');
  call execute('quit;');
run;
proc delete data = _last_;
run;


/*
data test;
  do x = 2, 3, 5, 7;
    y = f(x);
    z = g(x);
    t = h(x);

    put _all_;
  end;
run;
*/
