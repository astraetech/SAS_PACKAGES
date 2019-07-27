/* unload.sas */
/**###################################################################**/
/*                                                                     */
/*  Copyright Bartosz Jablonski, June 2019.                            */
/*                                                                     */
/*  Code is free and open source. If you want - you can use it.        */
/*  But it comes with absolutely no warranty whatsoever.               */
/*  If you cause any damage or something - it will be your own fault.  */
/*  You've been warned! You are using it on your own risk.             */
/*  However, if you decide to use it don't forget to mention author.   */
/*  Bartosz Jablonski (yabwon@gmail.com)                               */
/*                                                                     */
/**###################################################################**/

filename package list;

%put NOTE: unloading package dynamicArray START;

data _null_;
  put "NOTE- " / ;
  put 'NOTE: The following macros are to be deleted:' /;
  length macroname $ 32;
  do macroname = 
      'DYNARRAY',
      'APPENDTO',
      'APPENDBEFORE',
      'LOOPOVER',
      'LOOPEND',
      'GETVAL',
      'PUTVAL',
      'RANGEOF',
      '',
      'CRDFARRAY',
      'CRDHARRAY',
      'CRDHSTACK',
      'CRDHFIFO',
      'CRDHORDSTACK'
      ;
    put "NOTE- " macroname;
  end;
  put "NOTE- " / " "; 
  put "NOTE- " / " ";
run;

/* delete macros and formats */
proc sql;
  create table _%sysfunc(datetime(), hex16.)_ as
  select memname, objname, objtype
  from dictionary.catalogs
  where 
    (
    objname in (
      'DYNARRAY',
      'APPENDTO',
      'APPENDBEFORE',
      'LOOPOVER',
      'LOOPEND',
      'GETVAL',
      'PUTVAL',
      'RANGEOF',
      'CRDFARRAY',
      'CRDHARRAY',
      'CRDHSTACK',
      'CRDHFIFO',
      'CRDHORDSTACK'
      )
    and objtype = 'MACRO'
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

%put NOTE: unloading package dynamicArray END;
