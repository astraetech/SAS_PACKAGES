/* dynamicpriorityqueuebyfunctionhash.sas */
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

/* dynamicpriorityqueuebyfunctionhash is a FCMP based approach to create 
   dynamicaly alocated priority queue 
*/

%macro crDHPrtQueue(queueName, type=8, newOnTop=+ /*+ or -*/, debug=0, outlib = work.DynamicFunctionArray.package, hexp=8);

%if %bquote(&newOnTop.) ne %str(-) %then %let newOnTop=+;

proc fcmp outlib = &outlib.;
  subroutine &queueName.(
      IO $     /* CHARACTER
                * steering argument:
                * T,t = Output Top    - pop/get/output the data from a queue's top
                * B,b = Output Bottom - pop/get/output the data from a queue's bottom
                * I,i = Input         - push/put/insert the data into a stack
                * C,c = Clear         - reduce a stack to an empty one
                * P,p = Peek Top      - peek the data from a queue's top and NOT removes it
                * Q,q = Peek Bottom   - peek the data from a queue's bottom and NOT removes it
                * S,s = Summary       - calculate basic summary,
                *                       for numeric: 1=Sum, 2=Average, 5=NumberOfNonMissing, 6=QueueHeight
                *                       for character: only queue height
                */
    , priority /* NUMERIC, reflects added element's priority in the queue
                * for T and B it holds a priority level of value popped from a queue
                * for I it holds a priority level of value to be pushed into a queue 
                * for S returns calculated summary value for character
                */
    , value %qsysfunc(compress(&type., $, k)) 
               /* NUMERIC/CHARACTER  
                * for T and B it holds a value popped from a queue
                * for I it holds a value to be pushed into a queue
                * for C ignored
                * for S ignored
                * othervise does not modify value
                */
    );
    outargs value, priority;

    length position positionTMP priority 8 value &type.;
    static position 0;
    declare hash H(ordered:"D", duplicate:"R", hashexp:&hexp.);
    _RC_ = H.defineKey("priority");
    _RC_ = H.defineKey("position");
    _RC_ = H.defineKey("value");
    _RC_ = H.defineDone();
    declare hiter I("H"); 

    static _sum_ .;
    static _cnt_ .;
 
    /* Output from Top or Bottom - get the data from a queue */
    if IO = 'T' or IO = 'B' or IO = 'b' or IO = 't' then
      do;
        positionTMP = position;
        call missing(value, position);
        
        if IO = 'B' or IO = 'b' then
          do;
            _RC_ = I.last();
            _RC_ = I.next();
          end;
        else
          do;
            _RC_ = I.first();
            _RC_ = I.prev();
          end;

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
        position = positionTMP;

        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&queueName.] Debug O:" "dim(TEMP)=" _T_ "value=" value "position=" position;
        %end;
        return;
      end;
    
    /* Input - insert the data into a stack */
    if IO = 'I' or IO = 'i' then
      do;      
        position = position + (&newOnTop.1);
        priority = coalesce(priority, 0);
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
          put "NOTE:[&queueName.] Debug I:" "dim(TEMP)=" _T_ "value=" value "position=" position;
        %end;
        return;
      end;

    /* Peek Top - peeks the data from a queue's top without removing */
    if IO = 'P' or IO = 'p' then
      do;
        call missing(value, priority);
        _RC_ = I.first();
        _RC_ = I.prev();
        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&queueName.] Debug" "dim(TEMP)=" _T_ "TEMP[position]=" value;
        %end;
        return;
      end;

    /* Peek Bottom - peeks the data from a queue's bottom without removing */
    if IO = 'Q' or IO = 'q' then
      do;
        call missing(value, priority);
        _RC_ = I.last();
        _RC_ = I.next();
        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&queueName.] Debug" "dim(TEMP)=" _T_ "TEMP[position]=" value;
        %end;
        return;
      end;

    /* Clear - reduce a stack to an empty one */
    if IO = 'C' or IO = 'c' then
      do;
        _RC_ = H.clear();
        position = 0;
        positionTMP = 0;
        _sum_ = .;
        _cnt_ = .;
        return;
      end;

    /* Statistic - returns selected statistic */
    if IO = 'S' or IO = 's' then
      do;
        %if %qsysfunc(compress(&type., $, k))=$ %then /* character type */
          %do; 
            priority = H.num_items(); 
            value = " ";
          %end;
        %else /* numeric type */
          %do; 
            _tmp_ = value;
            select(_tmp_);
              when (1) value = if H.num_items() then _sum_ else .; /* Sum */
              when (2) value = divide(_sum_, _cnt_); /* Average */
              when (5) value = _cnt_; /* NonMiss */
              when (6) value = H.num_items(); /* QueueLength */
              otherwise value = .;
            end;
            priority = value;
          %end;
        return;
      end;

    put "NOTE:IO parameter value" IO "is unknown. Use: T, B, I, P, Q, S, or C.";
    return;
  endsub;
run;
%mend crDHPrtQueue;

/*
%crDHPrtQueue(PriorityQueueABC, type = $ 12, debug=1, newOnTop=+); 
options cmplib = work.DynamicFunctionArray; %* default location *; 
 
%let zeros = 1; 
data _null_1; 
 
  t = time(); 
  _I_ = 0
  do _X_ = "A","B","C","A","B","C";
    _I_ + 1; 
    call PriorityQueueABC("I", mod(_I_, 3), _X_); 
  end; 
  t = time() - t; 
  put t= / _X_= /; 
 
  length s $ 8 SS 8;
  call PriorityQueueABC('S', SS, S); 
  put SS=;

  t = time(); 
  do until(_X_ = " "); 
    call PriorityQueueABC('T', _I_, _X_); 
    output;  
  end; 
  t = time() - t; 
  put t= / _X_= /; 
  
  %* clear for further reuse *; 

  call PriorityQueueABC('C',.,'');  
  call PriorityQueueABC('D',.,'');  
run; 


%crDHOrdStack(StackABN, order=D); 
options cmplib = work.DynamicFunctionArray; %* default location *; 
 
%let zeros = 1; 
data _null_1; 
 
  t = time(); 
  do _X_ = 1,6,2,.,5,3,4; 
    call StackABN("I", _X_); 
    Sum = 1;
    call StackABN('S', Sum);
    Avg = 2;
    call StackABN('S', Avg);
    Min = 3; 
    call StackABN('S', Min);
    Max = 4; 
    call StackABN('S', Max);
    Nnm = 5;
    call StackABN('S', Nnm);
    Cnt = 6;
    call StackABN('S', Cnt);
    put (_ALL_) (=);  
  end; 
  t = time() - t; 
  put t= / _X_= /; 
 
  P = 1;
  call StackABN('P', P); 
  put P=;  

  t = time(); 
  do _I_ = 1 to Cnt; 
    call StackABN('O', _X_); 
    if _X_ > .z then output; 
  end; 
  t = time() - t; 
  put t= / _X_= /; 
 
  P = 1;
  call StackABN('P', P); 
  put P=;
 
  %* clear for further reuse *; 
  Sum = 1;
  call StackABN('S', Sum);
  Avg = 2;
  call StackABN('S', Avg);
  Min = 3; 
  call StackABN('S', Min);
  Max = 4; 
  call StackABN('S', Max);
  Nnm = 5;
  call StackABN('S', Nnm);
  Cnt = 6;
  call StackABN('S', Cnt);
  put (_ALL_) (=);  
  call StackABN('C',.);  
  call StackABN('D',.);  
run; 
*/
