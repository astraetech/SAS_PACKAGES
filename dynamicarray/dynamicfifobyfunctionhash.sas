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

%macro crDHQueue(fifoName, type=8, debug=0, outlib = work.DynamicFunctionArray.package, hexp=8);
proc fcmp outlib = &outlib.;
  subroutine &fifoName.(
      IO $     /* CHARACTER
                * steering argument:
                * O,o = Output    - pop/get/output/dequeue the data from a fifo
                * I,i = Input     - push/put/insert/enqueue the data into a fifo
                * C,c = Clear     - reduce a fifo to an empty one
                * P,p = Peek      - peek the data from a queue and NOT removes it
                * S,s = Summary   - calculate basic summary,
                *                   for numeric: 1=Sum, 2=Average, 5=NumberOfNonMissing, 6=QueueLength
                *                   for character: only queue length
                */
    , value %qsysfunc(compress(&type., $, k)) 
               /* NUMERIC/CHARACTER  
                * for O it holds a value popped from a fifo
                * for I it holds a value to be pushed into a fifo
                * for C ignored
                * for P it holds a value peeked from a stack
                * for S returns calculated summary value
                * othervise does not modify value
                */
    );
    outargs value;

    length position 8 value &type. valueTMP &type.;
    declare hash H(ordered:"A", duplicate:"R", hashexp:&hexp.);
    _RC_ = H.defineKey("position");
    _RC_ = H.defineData("position");
    _RC_ = H.defineData("value");
    _RC_ = H.defineDone();
    declare hiter I("H"); 

    static _sum_ .;
    static _cnt_ .;
    /* TODO: figure out smart way for min and max */
    /*
    static _min_ .;
    static _max_ .;
    */
 
    /* Output - get the data from a queue */
    if IO = 'O' or IO = 'o' then
      do;
        call missing(value);
        _RC_ = I.first();
        _RC_ = I.prev();

        %if %qsysfunc(compress(&type., $, k))=$ %then /* character type */
          %do; 
            /* since value is a character type then do nothing */
          %end;
        %else /* numeric type */
          %do;
            _sum_ = sum(_sum_, -(value));
            _cnt_ = sum(_cnt_, -(value > .z));
          %end;

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

        %if %qsysfunc(compress(&type., $, k))=$ %then /* character type */
          %do; 
            /* since value is a character type then do nothing */
          %end;
        %else /* numeric type */
          %do; 
            _sum_ = sum(_sum_, (value));
            _cnt_ = sum(_cnt_, (value > .z));
          %end;

        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&fifoName.] Debug I:" "dim(TEMP)=" _T_ "value=" value "position=" position;
        %end;
        return;
      end;

    /* Peek - peeks the data from a stack without removing */
    if IO = 'P' or IO = 'p' then
      do;
        call missing(value);
        _RC_ = I.first();
        _RC_ = I.prev();
        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&fifoName.] Debug O:" "dim(TEMP)=" _T_ "TEMP[position]=" value;
        %end;
        return;
      end;

    /* Clear - reduce a queue to an empty one */
    if IO = 'C' or IO = 'c' then
      do;
        _RC_ = H.clear();
        _sum_ = .;
        _cnt_ = .;
        return;
      end;

    /* Statistic - returns selected statistic */
    if IO = 'S' or IO = 's' then
      do;
        %if %qsysfunc(compress(&type., $, k))=$ %then /* character type */
          %do; 
            value = put(H.num_items(), best32.); 
          %end;
        %else /* numeric type */
          %do; 
            _tmp_ = value;
            select(_tmp_);
              when (1) value = if H.num_items() then _sum_ else .; /* Sum */
              when (2) value = divide(_sum_, _cnt_); /* Average */
              when (5) value = _cnt_; /* NonMiss */
              when (6) value = H.num_items(); /* StackHeight */
              otherwise value = .;
            end;
          %end;
        return;
      end;

    put "NOTE:IO parameter value" IO "is unknown. Use: O, I, P, S, or C.";
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
