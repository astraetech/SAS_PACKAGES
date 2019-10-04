/*** HELP STRAT ***/

/*
 * >>> exec generatearrays.sas <<<
 * Some example arrays are generated.
**/

/*** HELP END ***/

/* Create Simple Immutable Dynamic Function Array */
%createDFArray(SmpArray, simple=1, resizefactor=0, outlib = work.DFAfcmp.package);

/* Create Simple Mutable Dynamic Function Array */
%createDFArray(SmpMtbArray, simple=1, resizefactor=4999, outlib = work.DFAfcmp.package);

/* Create Searchable Immutable Dynamic Function Array */
%createDFArray(SrchArray, outlib = work.DFAfcmp.package);

/* Create Searchable Mutable Dynamic Function Array */
%createDFArray(SrchMtbArray, resizefactor=4999, outlib = work.DFAfcmp.package);

/**/
