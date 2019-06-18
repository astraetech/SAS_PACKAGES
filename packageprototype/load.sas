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

%include package(examplemacro1.sas) ;

%include package(examplemacro2.sas) ;

%include package(examplefunctions.sas) ;

%include package(exampleformats.sas) ;

%put NOTE: loading package packagePrototype END;
