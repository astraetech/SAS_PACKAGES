/*** HELP START ***/

/* >>> %rangeOf() macro: <<<
 * 
 * The macro gets current values of 
 * lower bound and higher bound 
 * of ARRAY, the default names are:       
 * lbound<ARRAYNAME> and hbound<ARRAYNAME>
 *
 * Example 1:
     %rangeOf(ABC);
     put lboundABC= hboundABC=; 

 * Example 2:
     %rangeOf(ABC, START=startABC, END=endABC);
     put startABC= endABC=; 
 *
**/
/* The definition: */
%macro rangeOf(
  ARRAY                /* an array defined by %dynArray() macro */
, START=lbound&ARRAY.  /* variable for lower bound, default: lbound<ARRAYNAME> */
, END  =hbound&ARRAY.  /* variable for upper bound, default: hbound<ARRAYNAME> */
);
/*** HELP END ***/
  _RC_ = IT_&ARRAY..first();
  &START. = _I_;
  _RC_ = IT_&ARRAY..last();
  &END. = _I_;
  _RC_ = IT_&ARRAY..next();
  drop &START. &END.;
%mend rangeOf;
