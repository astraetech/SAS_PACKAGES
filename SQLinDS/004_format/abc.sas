/*** HELP START ***/

/* >>> ABC numeric format: <<<
 *
 * This is simple test numeric format.
 *
 * >>> ABC character format: <<<
 *
 * This is simple test character format.
 *
 * >>> ABC numeric informat: <<<
 *
 * This is simple test numeric informat.
 *
 * >>> ABC charavter informat: <<<
 *
 * This is simple test character informat.
 *
**/

/*** HELP END ***/

proc format lib = work.&packageName.;
  value ABC
    1="A"
    2="B"
    3="C"
    other = "*"
  ;

  value $ ABC
    "a"="A"
    "b"="B"
    "c"="C"
    other = "_"
  ;

  invalue ABC
    "A"=1
    "B"=2
    "C"=3
    other = .
  ;

  invalue $ ABC
    "A"="AAA"
    "B"="BBB"
    "C"="CCC"
    other = _SAME_
  ;
run;
