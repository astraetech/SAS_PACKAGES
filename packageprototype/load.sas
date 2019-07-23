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

%put NOTE: loading package packagePrototype START;

data _null_;
  put "NOTE- " / ;
  put 'NOTE: The packagePrototype package, version 3.14' /;
  put 'NOTE: The following macros are to be compiled:' /;
  length macroname $ 32;
  do macroname = 
      'EXAMPLEMACRO1',
      'EXAMPLEMACRO2'
      ;
    put "NOTE- " macroname;
  end;
  put "NOTE- " / " "; 
  
  put 'NOTE: The following functions are to be compiled:' /;
  length functionname $ 32;
  do functionname = 
      'F',
      'G',
      'H'
      ;
    put "NOTE- " functionname;
  end;
  put "NOTE- " / " ";

  put 'NOTE: The following formats are to be compiled:' /;
  length formatname $ 32;
  do formatname = 
      'FRMT1_',
      'FRMT2_',
      'FRMT3_'
      ;
    put "NOTE- " formatname;
  end;
  put "NOTE- " / " ";

  put 'NOTE- Write %helpPackage(dynamicarray) for help.' / " ";
  put "NOTE- " / " ";
run;


%include package(examplemacro1.sas) ;

%include package(examplemacro2.sas) ;

%include package(examplefunctions.sas) ;

%include package(exampleformats.sas) ;

%put NOTE: loading package packagePrototype END;
