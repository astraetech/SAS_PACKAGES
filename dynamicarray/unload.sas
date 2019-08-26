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
      'CRDFARRAY2',
      'CRDHARRAY',
      'CRDHSTACK',
      'CRDHQUEUE',
      'CRDHORDSTACK',
      'CRDHPRTQUEUE'
      ;
    put "NOTE- " macroname;
  end;
  put "NOTE- " / " "; 
  put 'NOTE: The following functions are to be deleted:' /;
  length macroname $ 32;
  do functionname = 
      'CALL DYNARRAYN()',
      'CALL DYNARRAYC() /* $ 256 */',
      
      'CALL STACKN()',
      'CALL STACKC() /* $ 256 */',
     
      'CALL FIFON()',
      'CALL FIFOC() /* $ 256 */',

      'CALL ASCSTACKN',
      'CALL DESCSTACKN',
      'CALL ASCSTACKC() /* $ 256 */',
      'CALL DESCSTACKC() /* $ 256 */',

      'CALL PRTPQUEUEN()',
      'CALL PRTPQUEUEC() /* $ 256 */',
      'CALL PRTNQUEUEN()',
      'CALL PRTNQUEUEC() /* $ 256 */'
      ;
    put "NOTE- " functionname;
  end;
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
      'CRDFARRAY2',
      'CRDHARRAY',
      'CRDHSTACK',
      'CRDHQUEUE',
      'CRDHORDSTACK',
      'CRDHPRTQUEUE'
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



/* delete functions */
PROC FCMP OUTLIB = work.DynamicFunctionArray.package;
  DELETEFUNC DYNARRAYN;
  DELETEFUNC DYNARRAYC;

  DELETEFUNC STACKN;
  DELETEFUNC STACKC;

  DELETEFUNC FIFON;
  DELETEFUNC FIFOC;

  DELETEFUNC ASCSTACKN;
  DELETEFUNC DESCSTACKN;
  DELETEFUNC ASCSTACKC;
  DELETEFUNC DESCSTACKC;

  DELETEFUNC PRTPQUEUEN;
  DELETEFUNC PRTPQUEUEC;
  DELETEFUNC PRTNQUEUEN;
  DELETEFUNC PRTNQUEUEC; 
run;

/* delete the link to the functions' dataset */
options cmplib = (
%unquote(
%sysfunc(tranwrd(
 %sysfunc(getoption(cmplib))
,%str(WORK.DYNAMICFUNCTIONARRAY)
,%str()
))
));



%put NOTE: unloading package dynamicArray END;



