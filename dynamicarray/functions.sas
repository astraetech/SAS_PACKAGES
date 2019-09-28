/* functions.sas */
/**###################################################################**/
/*                                                                     */
/*  Copyright Bartosz Jablonski, July 2019.                            */
/*                                                                     */
/*  Code is free and open source. If you want - you can use it.        */
/*  But it comes with absolutely no warranty whatsoever.               */
/*  If you cause any damage or something - it will be your own fault.  */
/*  You've been warned! You are using it on your own risk.             */
/*  However, if you decide to use it don't forget to mention author.   */
/*  Bartosz Jablonski (yabwon@gmail.com)                               */
/*                                                                     */
/**###################################################################**/

%macro DynamicFunctionArray_functions();

%local _cmplib_;
options APPEND=(cmplib = WORK.DYNAMICFUNCTIONARRAY) ;
%let _cmplib_ = %sysfunc(getoption(cmplib));
%put NOTE:[&sysmacroname.] *&=_cmplib_*;

options cmplib = _null_;

/*numeric and character dynamic array*/
%crDFArray2(DYNARRAYN, debug=0, resizefactor=4999, outlib = work.DynamicFunctionArray.package);
%crDHArray(DYNARRAYC, type=$ 256, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);

/*numeric and character dynamic stack*/
%crDHStack(STACKN, type=8, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);
%crDHStack(STACKC, type=$ 256, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);

/*numeric and character dynamic queue (fifo)*/
%crDHQueue(FIFON, type=8, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);
%crDHQueue(FIFOC, type=$ 256, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);

/*numeric and character dynamic ordered stack*/
%crDHOrdStack(ASCSTACKN, type=8, order=A /*A or D*/, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);
%crDHOrdStack(DESCSTACKN, type=8, order=D /*A or D*/, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);
%crDHOrdStack(ASCSTACKC, type=$ 256, order=A /*A or D*/, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);
%crDHOrdStack(DESCSTACKC, type=$ 256, order=D /*A or D*/, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);

/*numeric and character dynamic priority queue, for the same priority latest returned first*/
%crDHPrtQueue(PRTPQUEUEN, type=8, newOnTop=+ /*+ or -*/, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);
%crDHPrtQueue(PRTPQUEUEC, type=$ 256, newOnTop=+ /*+ or -*/, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);

/*numeric and character dynamic priority queue, for the same priority latest returned last*/
%crDHPrtQueue(PRTNQUEUEN, type=8, newOnTop=- /*+ or -*/, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);
%crDHPrtQueue(PRTNQUEUEC, type=$ 256, newOnTop=- /*+ or -*/, debug=0, outlib = work.DynamicFunctionArray.package, hexp=13);

options cmplib = &_cmplib_.;
%let _cmplib_ = %sysfunc(getoption(cmplib));
%put NOTE:[&sysmacroname.] *&=_cmplib_*;

%mend DynamicFunctionArray_functions;
%DynamicFunctionArray_functions()

/* delete macro DynamicFunctionArray_functions since it is not needed anymore*/
proc sql;
  create table _%sysfunc(datetime(), hex16.)_ as
  select memname, objname
  from dictionary.catalogs
  where 
    objname = upcase('DYNAMICFUNCTIONARRAY_FUNCTIONS')
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
