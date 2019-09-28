/*** HELP START ***/

/* >>> %loopOver() macro: <<<
 * 
 * The macro allows looping over all elements of an array.
 *
 * Loops can be embeaded e.g.
    %loopOver(ABC); 
      %loopOver(DEF); 
        X = _ABCcell_; 
        Y = _DEFcell_; 
        put X= Y=; 
      %loopEnd; 
    %loopEnd;  

 * !!CAUTION!! Cannot use one array twice!!                
 * Code like:
    
    %loopOver(ABC); 
      %loopOver(ABC); 
        put _all_;
      %loopEnd; 
    %loopEnd;

 * ends with infinite loop.                  
 *
**/
/* The definition: */
%macro loopOver(
  ARRAYS /* A space separated list of arrays defined by %dynArray() macro */
);
/*** HELP END ***/
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
