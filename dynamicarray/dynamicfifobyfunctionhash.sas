/* dynamicfifobyfunctionhash.sas */
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
   dynamicaly alocated "first in first out" queue 
*/

%macro crDHQueue(fifoName, type=8, debug=0, outlib = work.DynamicFunctionArray.package);
proc fcmp outlib = &outlib.;
  subroutine &fifoName.(
      IO $     /* CHARACTER
                * steering argument:
                * O,o = Output    - pop/get/output the data from a fifo
                * I,i = Input     - push/put/insert the data into a fifo
                * C,c = Clear     - reduce a fifo to an empty one
                */
    , value %qsysfunc(compress(&type., $, k)) 
               /* NUMERIC/CHARACTER  
                * for O it holds a value popped from a fifo
                * for I it holds a value to be pushed into a fifo
                * for C ignored
                * othervise does not modify value
                */
    );
    outargs value;

    length position 8 value &type. valueTMP &type.;
    declare hash H(ordered:"A", duplicate:"R");
    _RC_ = H.defineKey("position");
    _RC_ = H.defineData("position");
    _RC_ = H.defineData("value");
    _RC_ = H.defineDone();
    declare hiter I("H"); 
    
    /* Output - get the data from a queue */
    if IO = 'O' or IO = 'o' then
      do;
        call missing(value);
        _RC_ = I.first();
        _RC_ = I.prev();
        _RC_ = H.remove();
        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&fifoName.] Debug O:" "dim(TEMP)=" _T_ "TEMP[position]=" value;
        %end;
        return;
      end;
    
    /* Input - insert the data into a queue */
    if IO = 'I' or IO = 'i' then
      do;   
        valueTMP = value;
        _RC_ = I.last();
        _RC_ = I.next();
        position = sum(position, 1);
        value = valueTMP;
        _RC_ = H.replace();

        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&fifoName.] Debug I:" "dim(TEMP)=" _T_ "value=" value "position=" position;
        %end;
        return;
      end;

    /* Clear - reduce a queue to an empty one */
    if IO = 'C' or IO = 'c' then
      do;
         _RC_ = H.clear();
        return;
      end;

    put "NOTE:IO parameter value" IO "is unknown. Use: O, I, or C.";
    return;
  endsub;
run;
%mend crDHQueue;

/*
%crDHQueue(FifoABC, type = $ 12, debug = 1); 
options cmplib = work.DynamicFunctionArray; %* default location *; 
 
%let zeros = 1; 
data _null_1; 
 
  t = time(); 
  do _I_ = 1 to 1e&zeros.; 
    _X_ = put(_I_*10, z12.); 
    call FifoABC("I", _X_); 
  end; 
  t = time() - t; 
  put t= / _X_= /; 
 
  t = time(); 
  do _I_ = 1 to 1e&zeros. + 3; 
    call FifoABC('O', _X_); 
    put _all_;
    output;  
  end; 
  t = time() - t; 
  put t= / _X_= /; 
  
  %* clear for further reuse *; 
  call FifoABC('C','');  
  call FifoABC('D','');  
run; 
*/
