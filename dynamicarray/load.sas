/* load.sas */
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

%put NOTE: loading package dynamicArray START;

data _null_;
  put "NOTE- " / ;
  put 'NOTE: The dynamicArray package, version 0.20190821' /;
  put 'NOTE: The following macros are to be compiled:' /;
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
  put 'NOTE: The following functions are to be compiled:' /;
  length functionname $ 32;
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
  put 'NOTE- Write %helpPackage(dynamicarray) for help.' / " ";
  put "NOTE- " / " ";
run;

%include package(dynamicarray.sas) ;

%include package(dynamicarraybyfunction.sas) ;

%include package(dynamicarraybyfunction2.sas) ;

%include package(dynamicarraybyfunctionhash.sas) ;

%include package(dynamicstackbyfunctionhash.sas) ;

%include package(dynamicfifobyfunctionhash.sas) ;

%include package(dynamicorderedstackbyfunctionhash.sas) ;

%include package(dynamicpriorityqueuebyfunctionhash.sas) ;

%include package(functions.sas);

%put NOTE: loading package dynamicArray END;
