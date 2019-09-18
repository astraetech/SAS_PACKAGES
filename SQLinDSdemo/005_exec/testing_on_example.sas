/*** HELP START ***/

/* >>> testing_on_example exec: <<<
 *
 * Test of %SQL() macro executed 
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


data WORK.SQLinDStestquery;
set %SQL(select id, avg(z) as avg_z
         from dssql.sqlinds_example
         where x > y
         group by id
         order id desc
         );
put _all_;
run;
