/*** HELP START ***/

/* >>> testsubroutine() call routine: <<<
 *
 * Test call routine.
 *
**/

/*** HELP END ***/

proc fcmp 
  inlib  = work.&packageName.fcmp
  outlib = work.&packageName.fcmp.package
;

subroutine testsubroutine(a,b,c);
  outargs a, b ,c;
    a = a + 1;
    b = b + 2;
    c = c + 3;
  return;
endsub;

run;
quit;
