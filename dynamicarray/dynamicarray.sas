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

/* dynamicarray package is a hash table wrapper which emulates 
   beviour of classic array but based on hash table, there 
   is an integer variable index _I_ and a data portion variable
   _<arrayName>cell_. It is not a speed deamon for big sazes arrays, 
   it works with hahs table speed/efficiency
*/

%macro dynArray(
  ARRAY     /* array name, not null */
, TYPE=8    /* array type ,default: numerc 8 bytes */
, HASHEXP=8 /* hashexp for hash table, default: 8*/
);
  if _N_ = 1 then
  do;
    length _I_ _RC_ 8 _&ARRAY.CELL_ &type. ;
    declare hash &ARRAY.(ordered:"A", hashexp:&HASHEXP.);
    &ARRAY..defineKey("_I_");
    &ARRAY..defineData("_I_","_&ARRAY.CELL_"); 
    &ARRAY..defineDone();
    &ARRAY..clear();
    declare hiter IT_&ARRAY.("&ARRAY.");
    drop _&ARRAY.CELL_ _I_ _RC_;
  end;
%mend dynArray;


%macro appendTo(ARRAY, VARIABLE);
  call missing(_I_);
  _RC_ = IT_&ARRAY..last();
  _I_ + 1;
  _&ARRAY.CELL_ = &VARIABLE.;
  _RC_ = &ARRAY..replace();
%mend appendTo;

%macro appendBefore(ARRAY, VARIABLE);
  call missing(_I_);
  _RC_ = IT_&ARRAY..first();
  _I_ + (-1);
  _&ARRAY.CELL_ = &VARIABLE.;
  _RC_ = &ARRAY..replace();
%mend appendBefore;


%macro loopOver(ARRAYS);
  %local ARRAY i;
  %let ARRAY = %scan(&ARRAYS., 1);
  _RC_ = IT_&ARRAY..first();
  _RC_ = IT_&ARRAY..prev();
  do while(IT_&ARRAY..next()=0);

    %let i = 2;
    %let ARRAY = %scan(&ARRAYS., &i.); 
    %do %while(&ARRAY. ne);

      call missing(_&ARRAY.CELL_);
      _RC_ = &ARRAY..find();

      %let i = %eval(&i.+1);
      %let ARRAY = %scan(&ARRAYS., &i.); 
    %end;
/*end;*/
%mend loopOver;

%macro loopEnd;
end;
%mend loopEnd;


%macro getVal(VARIABLE, ARRAY, INDEX);
  call missing(_&ARRAY.CELL_);
  _I_ = &INDEX;
  _RC_ = &ARRAY..find();
  &VARIABLE. = _&ARRAY.CELL_;
%mend getVal;

%macro putVal(ARRAY, INDEX, VARIABLE);
  if not missing(&INDEX.) then
    do;
      _I_ = &INDEX;
      _&ARRAY.CELL_ = &VARIABLE. ; 
      _RC_ = &ARRAY..replace();
    end;
%mend putVal;

%macro rangeOf(ARRAY, START=lbound&ARRAY., END=hbound&ARRAY.);
  _RC_ = IT_&ARRAY..first();
  &START. = _I_;
  _RC_ = IT_&ARRAY..last();
  &END. = _I_;
  drop &START. &END.;
%mend rangeOf;


options ps = max ls = max;
data _null_;
  infile cards4 dsd dlm = '0A0D'x;
  input ;
  putlog "NOTE-" _infile_;
cards4;
/* dynamic Array package - an example of use */ 
options mprint source notes; 
data _null_; 
 
  /* declare empty numeric array ABC 
     with index _I_ and data _ABCcell_ */ 
  %dynArray(ABC) 
 
  /* declare empty character array GHI 
     with index _I_ and data _GHIcell_ */ 
  %dynArray(GHI, type = $ 12) 
 
  /* loop */ 
  do i = 1 to 5; 
    /* add new data to the end of ABC, index is 
       automatically incremented by 1 (i.e. max(_I_) + 1) */ 
    %appendTo(ABC, i**3) 
 
    /* add new data to the end of GHI, index is 
       automatically incremented by 1 (i.e. max(_I_) + 1) */ 
    %appendTo(GHI, cats("test", i**3)) 
  end; 
 
  do i = 1 to 5; 
    /* add new data to the begining of ABC, index is 
       automatically decremented by 1 (i.e. min(_I_) - 1) */ 
    %appendBefore(ABC, -(i**3)) 
 
    /* add new data to the begining of GHI, index is 
       automatically decremented by 1 (i.e. min(_I_) - 1) */ 
    %appendBefore(GHI, cats("test", -(i**3))) 
  end; 
  
  /* behaves like: test = ABC[3]; */ 
  %getVal(test, ABC, 3); 
 
  /* get current values of lbound and hbound of ARRAY, 
     default names: lbound<ARRAYNAME> and hbound<ARRAYNAME> */ 
  %rangeOf(ABC) 
  do i = lboundABC to hboundABC; 
    %getVal(test, ABC, i); 
    put '%getVal ' i= test=; 
  end; 
 
  test = -17; 
  /* behaves like: ABC[8] = test; */ 
  %putVal(ABC, 8, test); 
 
  /* behaveslike: ABC[7] = -42; ABC[7] = -555; */ 
  %putVal(ABC, 7, -42); 
 
  %putVal(ABC, 7, -555); 
 
  /* one loop for 2 tables, 
     first array sets up loop's index */ 
  %loopOver(ABC GHI); 
    j = _ABCcell_; 
    t = _GHIcell_; 
    output; 
  %loopEnd; 
 
  /* a loop in a loop (can't use one array twice! 
     ends with infinite loop) */ 
  %loopOver(ABC); 
    %loopOver(GHI); 
    j = _ABCcell_; 
    t = _GHIcell_; 
    put "**" j= t=; 
    %loopEnd; 
  %loopEnd; 
 
run;
;;;;
run;
