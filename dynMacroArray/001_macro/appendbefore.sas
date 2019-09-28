/*** HELP START ***/

/* >>> %appendBefore() macro: <<<
 * 
 * The macro allows appending new values 
 * at the begining of a dynamic array.
 * Index is automatically decremented by 1 (i.e. min(_I_) - 1)
 *
**/
/* The definition: */
%macro appendBefore(
 ARRAY       /* An array defined by %dynArray() macro */
,VARIABLE    /* Data step variable                    */
);
/*** HELP END ***/
  call missing(_I_);
  _RC_ = IT_&ARRAY..first();
  _I_ + (-1);
  _&ARRAY.CELL_ = &VARIABLE.;
  _RC_ = &ARRAY..replace();
%mend appendBefore;
