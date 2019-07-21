
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


%macro packageprototype_formats();

%local _fmtsearch_;
%let _fmtsearch_ = %sysfunc(getoption(fmtsearch));
%put NOTE:[&sysmacroname.] *&=_fmtsearch_*;

PROC FORMAT LIBRARY=WORK.PACKAGEPROTOTYPE_FORMATS;
value frmt1_
  low  - 3 = "small3"
  3 - high = "big3"
;

value frmt2_
  low  - 4 = "small4"
  4 - high = "big4"
;

value frmt3_
  low  - 5 = "small5"
  5 - high = "big5"
;
RUN;

options INSERT=(fmtsearch = WORK.PACKAGEPROTOTYPE_FORMATS) ;
%let _fmtsearch_ = %sysfunc(getoption(fmtsearch));
%put NOTE:[&sysmacroname.] *&=_fmtsearch_*;


%mend packageprototype_formats;
%packageprototype_formats()

/* delete macro packageprototype_formats since it is not needed */
proc sql;
  create table _%sysfunc(datetime(), hex16.)_ as
  select memname, objname
  from dictionary.catalogs
  where 
    objname = upcase('PACKAGEPROTOTYPE_FORMATS')
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
    y = put(x, frmt1_.);
    z = put(x, frmt2_.);
    t = put(x, frmt3_.);

    put _all_;
  end;
run;
*/
