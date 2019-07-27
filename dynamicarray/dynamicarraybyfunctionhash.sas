/* dynamicarraybyfunctionhash.sas */
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
   dynamicaly alocated numerical array 
*/

%macro crDHArray(arrayName, type=8, debug=0, outlib = work.DynamicFunctionArray.package);
proc fcmp outlib = &outlib.;
  subroutine &arrayName.(
      IO $     /* CHARACTER
                * steering argument:
                * O,o = Output    - get the data from an array
                * I,i = Input     - insert the data into an array
                * C,c = Clear     - reduce an array to an empty one
                * L,l,H,h = Dimentions - return minimal and maximal poistion of index
                */
    , position /* NUMERIC
                * for O(I) it is an array's index from(into) which data is get(put)
                * for C ignored
                * for L returns first position of index
                * for H returns last position of index
                * othervise does not modify value
                */
    , value %qsysfunc(compress(&type., $, k)) 
               /* NUMERIC/CHARACTER  
                * for O it holds value retrieved from an array on a given position
                * for I gets maxposition info (i.e. maximal position of the arrays's index occured)
                * for C ignored
                * for L returns first value of index
                * for H returns last value of index
                * othervise does not modify value
                */
    );
    outargs position, value;

    length position 8 value &type.;
    declare hash H(ordered:"A", duplicate:"R");
    _RC_ = H.defineKey("position");
    _RC_ = H.defineData("position");
    _RC_ = H.defineData("value");
    _RC_ = H.defineDone();
    declare hiter I("H");
  
    
    /* Output - get the data from an array */
    if IO = 'O' or IO = 'o' then
      do;
        if H.find() then call missing(value);
        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&arrayName.] Debug" "dim(TEMP)=" _T_ "TEMP[position]=" value;
        %end;
        return;
      end;
    
    /* Input - insert the data into an array */
    if IO = 'I' or IO = 'i' then
      do;   
        _RC_ = H.replace();
        %if &debug %then %do;
          _T_ = H.num_items();

          put "NOTE:[&arrayName.] Debug" "dim(TEMP)=" _T_ "value=" value "position=" position;
        %end;
        return;
      end;

    /* Clear - reduce an array to a single empty cell */
    if IO = 'C' or IO = 'c' then
      do;
         _RC_ = H.clear();
        return;
      end;

    /* Dimention - returns minimal and maximal index 
     */
    if IO = 'L' or IO = 'l'  then
      do;
        _RC_ = I.first();
        _RC_ = I.prev();
        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&arrayName.] Debug" "dim(TEMP)=" _T_;
        %end;
        return;
      end;

      if IO = 'H' or IO = 'h'  then
      do;
        _RC_ = I.last();
        _RC_ = I.next();
        %if &debug %then %do;
          _T_ = H.num_items();
          put "NOTE:[&arrayName.] Debug" "dim(TEMP)=" _T_;
        %end;
        return;
      end;

    put "NOTE:IO parameter value" IO "is unknown. Use: O, I, C, L, or H.";
    return;
  endsub;
run;
%mend crDHArray;

/*
%crDHArray(ArrayABC, type = $ 12); 
options cmplib = work.DynamicFunctionArray; %* default location *; 
 
%let zeros = 6; 
data _null_1; 
 
  t = time(); 
  do _I_ = -1e&zeros. to 1e&zeros.; 
    _X_ = put(_I_*10, z12.); 
    call ArrayABC("I", _I_, _X_); 
  end; 
  t = time() - t; 
  put t= / _X_= /; 
 
  %* get the size info *; 
  LB = 0; HB = 0; 
  drop LB HB; 
  call ArrayABC('L', LB, _X_); 
  call ArrayABC('H', HB, _X_); 
  put LB= HB= /; 
 
  t = time(); 
  do _I_ = HB+1 to LB-1 by -1; 
    call ArrayABC('O', _I_, _X_); 
    output;  
  end; 
  t = time() - t; 
  put t= / _X_= /; 
 
  _N_ = sleep(5,1);
  %* clear for further reuse *; 
  call ArrayABC('C', ., ''); 
  _N_ = sleep(5,1);
  
run; 
*/
