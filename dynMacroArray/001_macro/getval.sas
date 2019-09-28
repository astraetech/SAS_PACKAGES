/*** HELP START ***/

/* >>> %getVal() macro: <<<
 * 
 * The macro behaves like: value = ABC[i];
 *
 * Example 1:
     %getVal(value, ABC, i);        
 *
**/
/* The definition: */
%macro getVal(
  VARIABLE /* a datastep variable                   */
, ARRAY    /* an array defined by %dynArray() macro */
, INDEX    /* indexing value                        */
);
/*** HELP END ***/
  call missing(_&ARRAY.CELL_);
  _RC_ = &ARRAY..find(key:&INDEX);
  &VARIABLE. = _&ARRAY.CELL_;
%mend getVal;
