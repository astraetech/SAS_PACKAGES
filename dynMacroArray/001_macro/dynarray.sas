/*** HELP START ***/

/* >>> %dynArray() macro: <<<
 * 
 * The macro instantiates hash object "pretending"
 * a dynamically allocated array.
 *
**/
/* The definition: */
%macro dynArray(
  ARRAY     /* array name, not null                */
, TYPE=8    /* array type, default: numerc 8 bytes */
, HASHEXP=8 /* hashexp for hash table, default: 8  */
);
/*** HELP END ***/
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

/*** HELP START ***/

/* Egample 1:
 * 
 * Declare empty numeric array ABC                     ;
 * with index variable _I_                             ;
 * and data variable _ABCcell_                         ;

  data _null_; 
    %dynArray(ABC); 

 * Add new data to the end of ABC, index is            ;
 * automatically incremented by 1 (i.e. max(_I_) + 1)  ; 
    do i = 1 to 5; 
      %appendTo(ABC, i**3); 
    end;

 * Add new data to the begining of ABC, index is       ;
 * automatically decremented by 1 (i.e. min(_I_) - 1)  ;
    do i = 1 to 5; 
      %appendBefore(ABC, -(i**3)); 
    end;

 * Get current values of lower bound and higher bound  ;
 * of ARRAY, the default names are:                    ;
 * lbound<ARRAYNAME> and hbound<ARRAYNAME>             ;
 * and loop over dynamicarray ABC.                     ;
    %rangeOf(ABC); 
    put lboundABC= hboundABC=;
    
    do i = lboundABC to hboundABC;
 * The getVal behaves like: value = ABC[i];            ;
      %getVal(value, ABC, i); 
      put '%getVal ' i= value=; 
    end; 
   
 * The putVal behaves like: ABC[hboundABC+17] = 42;    ;
 * Size is automatically extended.                     ;
    %putVal(ABC, hboundABC+17, 42);
    %rangeOf(ABC);
    put lboundABC= hboundABC=;
  run;
 
**/

/* Egample 2:
 * 
 * Declare two empty character arrays ABC and DEF      ;
 * ABC index variable _I_ and data variable _ABCcell_  ;
 * DEF index variable _I_ and data variable _DEFcell_  ;

  data _null_;
    %dynArray(ABC, type = $ 3); 
    %dynArray(DEF, type = $ 4); 

    %putVal(ABC, 1, 'A');
    %putVal(ABC, 2, 'BB');
    %putVal(ABC, 3, 'CCC'); 

    %putVal(DEF,-1, 'd');
    %putVal(DEF,-2, 'ee');
    %putVal(DEF,-3, 'fff');
    %putVal(DEF,-4, 'gggg');
  
 * One loop for 2 arrays (space separated)              ;
 * the first array sets up looping index (!)            ;
    %loopOver(ABC DEF); 
      X = _ABCcell_; 
      Y = _DEFcell_; 
      put X= Y=; 
    %loopEnd;
 
 * A loop in a loop is also possible                    ;
    %loopOver(ABC); 
      %loopOver(DEF); 
      X = _ABCcell_; 
      Y = _DEFcell_; 
      put X= Y=; 
      %loopEnd; 
    %loopEnd; 
 * !CAUTION! Cannot use one array twice!                ;
 *  Such code ends with infinite loop.                  ;

  run;
 
**/
/*** HELP END ***/
