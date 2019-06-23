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

filename package list;

%put NOTE: unloading package packageprototype START;

/* delete macros and formats */
proc sql;
  create table _%sysfunc(datetime(), hex16.)_ as
  select memname, objname, objtype
  from dictionary.catalogs
  where 
    (
    objname in (
      'EXAMPLEMACRO1 ',
      'EXAMPLEMACRO2 '
      )
    and objtype = 'MACRO'
    and libname  = 'WORK'
    )
    or
    (
    objname in (
      'FRMT1_ ',
      'FRMT2_ ',
      'FRMT3_ '
      )
    and objtype = 'FORMAT'
    and libname  = 'WORK'
    )

  order by memname, objname
  ;
quit;
data _null_;
  do until(last.memname);
    set _last_;
    by memname;

    if first.memname then call execute('proc catalog cat = work.' !! strip(memname) !! ' force;');
    call execute('delete ' !! strip(objname) !! ' /  et =' !! objtype !! '; run;');
  end;
  call execute('quit;');
run;
proc delete data = _last_;
run;

/* delete functions */
PROC FCMP outlib = work.packageprototype.functions;
  DELETEFUNC f;
  DELETEFUNC g; 
  DELETEFUNC h; 
run;

%put NOTE: unloading package packageprototype END;