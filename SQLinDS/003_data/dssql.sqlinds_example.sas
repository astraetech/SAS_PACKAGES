/*** HELP START ***/

/* >>> dssql.sqlinds_example dataset: <<<
 *
 * Example data to play with the package. 
 *  
 * Recomnended for SAS 9.3 and higher. 
 * Based on paper: 
 * "Use the Full Power of SAS in Your Function-Style Macros"
 * by Mike Rhoads, Westat, Rockville, MD
 * https://support.sas.com/resources/papers/proceedings12/004-2012.pdf
 *
**/

/*** HELP END ***/


data dssql.sqlinds_example;
  call streaminit(12345);

  do id = 1 to 42;
    do _N_ = 1 to 17;
      x = rand('uniform');
      y = rand('uniform');
      z = rand('uniform');
      output;
    end;
  end;
run;
