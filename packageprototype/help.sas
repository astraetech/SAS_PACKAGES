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

%put NOTE: HELP to package packagePrototype START;

data _null_;
  put "NOTE- " / ;
  put 'NOTE: The following macros are elements of the packagePrototype package:' /;
  length macroname $ 32;
  do macroname = 
      'EXAMPLEMACRO1 ',
      'EXAMPLEMACRO2 ';
    put "NOTE- " macroname;
  end;
  put "NOTE- " / " "; 
  put "NOTE- " / ;
  put 'NOTE: The following formats are elements of the packagePrototype package:' /;
  length formatname $ 32;
  do formatname = 
      'FRMT1_ ',
      'FRMT2_ ',
      'FRMT3_ ';
    put "NOTE- " formatname;
  end;
  put "NOTE- " / " "; 
  put 'NOTE: The following functions are elements of the packagePrototype package:' /;
  length functionname $ 32;
  do functionname = 
      'F',
      'G',
      'H';
    put "NOTE- " functionname;
  end;
  put "NOTE- " / " "; 

run;

data _%sysfunc(datetime(), hex16.)_;
 length ps ls $ 32;
 ps = getoption("ps");
 ls = getoption("ls");;
 call execute ('options ps = max ls = max;');
run;

data _null_;
  infile cards4 dsd dlm = '0A0D'x;
  input ;
  putlog "NOTE-" _infile_;
cards4;
/* packagePrototype package - an example of use */ 
here are examples and documentation details
;;;;
run;


data _null_;
 set _last_ indsname = indsname;
 call execute (catx(" ", 'options ps = ', ps, ' ls = ', ls, ';') );
 call execute ('proc delete data = ' !! indsname !! '; run;');
run;


%put NOTE: HELP to package packagePrototype END;
