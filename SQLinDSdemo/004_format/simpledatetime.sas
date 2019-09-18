/*** HELP START ***/

/* >>> simpleDateTime numeric format: <<<
 *
 * This is simple test numeric format with picture.
 *
**/

/*** HELP END ***/

proc format lib = work.&packageName.format; 
  picture simpleDateTime (default=19)
    other='%Y-%0m-%0d %0H:%0M:%0S' (datatype=datetime_util)
  ;
run;
