/*** HELP STRAT ***/

/*
 * >>> clear generatearrays.sas <<<
 * Clear generated example arrays.
**/

/*** HELP END ***/

Proc FCMP 
   inlib = work.DFAfcmp
  outlib = work.DFAfcmp.package
;
/* Remove Simple Immutable Dynamic Function Array */
DELETESUBR SmpArray;

/* Remove Simple Mutable Dynamic Function Array */
DELETESUBR SmpMtbArray;

/* Remove Searchable Immutable Dynamic Function Array */
DELETESUBR SrchArray;

/* Remove Searchable Mutable Dynamic Function Array */
DELETESUBR SrchMtbArray;
run;
quit;
 
/**/
