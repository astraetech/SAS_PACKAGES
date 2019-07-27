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

/* dynamicfunctionarray is a FCMP based approach to create 
   dynamicaly alocated ordered stack 
*/

%macro crDHOrdStack(stackName, type=8, order=A, debug=0, outlib = work.DynamicFunctionArray.package);
proc fcmp outlib = &outlib.;
  subroutine &stackName.(
      IO $     /* CHARACTER
                * steering argument:
                * O,o = Output    - pop/get/output the data from a stack
                * I,i = Input     - push/put/insert the data into a stack
                * C,c = Clear     - reduce a stack to an empty one
                */
    , value %qsysfunc(compress(&type., $, k)) 
               /* NUMERIC/CHARACTER  
                * for O it holds a value popped from a stack
                * for I it holds a value to be pushed into a stack
                * for C ignored
                * othervise does not modify value
                */
    );
    outargs value;

    length position positionTMP 8 value &type.;
    static position 0;
    declare hash H(ordered:"&order.", duplicate:"R");
    _RC_ = H.defineKey("value");
    _RC_ = H.defineKey("position");
    _RC_ = H.defineDone();
    declare hiter I("H"); 
    
    /* Output - get the data from a stack */
    if IO = 'O' or IO = 'o' then
      do;
        positionTMP = position;
        call missing(value,position);
        
        _RC_ = I.last();
        _RC_ = I.next();
        _RC_ = H.remove();
        position = positionTMP;

        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&stackName.] Debug O:" "dim(TEMP)=" _T_ "value=" value "position=" position;
        %end;
        return;
      end;
    
    /* Input - insert the data into a stack */
    if IO = 'I' or IO = 'i' then
      do;      
        position = position + 1;
        _RC_ = H.replace();

        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&stackName.] Debug I:" "dim(TEMP)=" _T_ "value=" value "position=" position;
        %end;
        return;
      end;

    /* Clear - reduce a stack to an empty one */
    if IO = 'C' or IO = 'c' then
      do;
         _RC_ = H.clear();
         position = 0;
         positionTMP = 0;
        return;
      end;

    put "NOTE:IO parameter value" IO "is unknown. Use: O, I, or C.";
    return;
  endsub;
run;
%mend crDHOrdStack;

/*
%crDHOrdStack(StackABC, type = $ 12, debug=1, order=D); 
options cmplib = work.DynamicFunctionArray; %* default location *; 
 
%let zeros = 1; 
data _null_1; 
 
  t = time(); 
  do _X_ = "A","B","C","A","B","C"; 
    call StackABC("I", _X_); 
  end; 
  t = time() - t; 
  put t= / _X_= /; 
 
  t = time(); 
  do until(_X_ = " "); 
    call StackABC('O', _X_); 
    output;  
  end; 
  t = time() - t; 
  put t= / _X_= /; 
  
  %* clear for further reuse *; 
  call StackABC('C','');  
  call StackABC('D','');  
run; 
*/
