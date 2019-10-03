%let packageRequired = "Base SAS Software", "SAS/STAT" ;
filename _stinit_ ".";
filename _stinit_ list;
options nosource;
%put *%sysfunc(dosubl(
options nonotes nosource %str(;)
/* temporary redirect log */
filename _stinit_ TEMP %str(;)
proc printto log = _stinit_ %str(;) run %str(;)
/* print out setinit */
proc setinit %str(;) run %str(;)
proc printto %str(;) run %str(;)
options ls=max ps=max %str(;)
data _null_ %str(;)
  /* loadup checklist of required SAS components */
  if _n_ = 1 then 
    do %str(;)
      length req $ 256 %str(;) 
      declare hash R() %str(;)
      _N_ = R.defineKey("req") %str(;)
      _N_ = R.defineDone() %str(;)
      declare hiter iR('R') %str(;)
        do req = %bquote(&packageRequired.) %str(;)
         _N_ = R.add(key:req,data:req) %str(;)
        end %str(;)
    end %str(;)

  /* read in output from proc setinit */
  infile _stinit_ end=eof %str(;)
  input %str(;)
  put "*> " _infile_ %str(;)

  /* if component is in setinit remove it from checklist */
  if _infile_ ne " " then 
    do %str(;)
      if R.find(key:substr(_infile_, 4)) = 0 then
        do %str(;) 
          _N_ = R.remove() %str(;)
        end %str(;)
    end %str(;)

  /* if checklist is not null rise error */
  if eof and R.num_items > 0 then 
    do %str(;)
      put "ERROR: The following components are missing!" %str(;)
      do while(iR.next() = 0) %str(;)
        put "ERROR- " req %str(;)
      end %str(;)
      put %str(;)
    end %str(;)
run %str(;)
filename _stinit_ clear %str(;)
options notes source %str(;)
))*;
options source;
filename _stinit_ list;
filename _stinit_ clear;
