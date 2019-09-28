/*** HELP START ***/

/* >>> %appendTo() macro: <<<
 * 
 * The macro allows appending new values 
 * at the end of a dynamic array.
 * Index is automatically incremented by 1 (i.e. max(_I_) + 1)
 *
**/
/* The definition: */
%macro appendTo(
 ARRAY       /* An array defined by %dynArray() macro */
,VARIABLE    /* Data step variable                    */
);
/*** HELP END ***/
  call missing(_I_);
  _RC_ = IT_&ARRAY..last();
  _I_ + 1;
  _&ARRAY.CELL_ = &VARIABLE.;
  _RC_ = &ARRAY..replace();
%mend appendTo;
