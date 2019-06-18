
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

/* OPTIONS MPRINT; */
%macro examplemacro1( 
arg1,
arg2,
arg3
);

%put *&=arg1*&=arg2*&=arg3*;

%mend examplemacro1;


/* examples and usecases */
/*
%examplemacro1("A", "BB", "CCC")
*/
