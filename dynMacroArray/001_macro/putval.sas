/*** HELP START ***/

/* >>> %putVal() macro: <<<
 * 
 * The macro behaves like: ABC[i] = value;
 *
 * Example 1:
     %putVal(ABC, i, value);        
 *
**/
/* The definition: */
%macro putVal(
  ARRAY    /* an array defined by %dynArray() macro */
, INDEX    /* indexing value                        */
, VARIABLE /* a datastep variable                   */
);
/*** HELP END ***/
  if not missing(&INDEX.) then
    do;
      _RC_ = &ARRAY..replace(key:&INDEX., data:&INDEX., data:&VARIABLE.);
    end;
%mend putVal;
