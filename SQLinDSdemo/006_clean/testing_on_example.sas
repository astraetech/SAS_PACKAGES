/*** HELP START ***/

/* >>> testing_on_example clean: <<<
 *
 * Cleaning after test of %SQL() macro executed 
 * on dssql.sqlinds_example data set 
 *  
 * Recomnended for SAS 9.3 and higher. 
 * Based on paper: 
 * "Use the Full Power of SAS in Your Function-Style Macros"
 * by Mike Rhoads, Westat, Rockville, MD
 * https://support.sas.com/resources/papers/proceedings12/004-2012.pdf
 *
**/

/*** HELP END ***/


data _null_; 
  if exist('WORK.SQLinDStestquery','data') then 
    do;
      call execute('proc delete data = WORK.SQLinDStestquery; run;');
    end;
run;
