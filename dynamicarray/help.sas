/**###################################################################**/
/*                                                                     */
/*  Copyright Bartosz Jablonski, June 2019.                            */
/*                                                                     */
/*  Code is free and open source. If you want - you can use it.        */
/*  But it comes with absolutely no warranty whatsoever.               */
/*  If you cause any damage or something - it will be your own fault.  */
/*  You've been warned! You are using it on your own risk.             */
/*  However, if you decide to use it don't forget to mention author.   */
/*  Bartosz Jablonski (yabwon@gmail.com)                               */
/*                                                                     */
/**###################################################################**/

filename package list;

%put NOTE: HELP to package dynamicArray START;

data _null_;
  put "NOTE- " / ;
  put 'NOTE: The following macros are elements of the dynamicArray package:' /;
  do macroname = 
      'DYNARRAY',
      'APPENDTO',
      'APPENDBEFORE',
      'LOOPOVER',
      'LOOPEND',
      'GETVAL',
      'PUTVAL',
      'RANGEOF';
    put "NOTE- " macroname;
  end;
  put "NOTE- " / " "; 
  put "NOTE- " / " ";
run;

data _%sysfunc(datetime(), hex16.)_;
 length ps ls $ 32;
 ps = getoption("ps");
 ls = getoption("ls");;
 call execute ('options ps = max ls = max;');
run;

data _null_;
  infile cards4 dsd dlm = '0A0D'x;
  input ;
  putlog "NOTE-" _infile_;
cards4;
/* dynamic Array package - an example of use */ 
options mprint source notes; 
data _null_; 
 
  /* declare empty numeric array ABC 
     with index _I_ and data _ABCcell_ */ 
  %dynArray(ABC) 
 
  /* declare empty character array GHI 
     with index _I_ and data _GHIcell_ */ 
  %dynArray(GHI, type = $ 12) 
 
  /* loop */ 
  do i = 1 to 5; 
    /* add new data to the end of ABC, index is 
       automatically incremented by 1 (i.e. max(_I_) + 1) */ 
    %appendTo(ABC, i**3) 
 
    /* add new data to the end of GHI, index is 
       automatically incremented by 1 (i.e. max(_I_) + 1) */ 
    %appendTo(GHI, cats("test", i**3)) 
  end; 
 
  do i = 1 to 5; 
    /* add new data to the begining of ABC, index is 
       automatically decremented by 1 (i.e. min(_I_) - 1) */ 
    %appendBefore(ABC, -(i**3)) 
 
    /* add new data to the begining of GHI, index is 
       automatically decremented by 1 (i.e. min(_I_) - 1) */ 
    %appendBefore(GHI, cats("test", -(i**3))) 
  end; 
  
  /* behaves like: test = ABC[3]; */ 
  %getVal(test, ABC, 3); 
 
  /* get current values of lbound and hbound of ARRAY, 
     default names: lbound<ARRAYNAME> and hbound<ARRAYNAME> */ 
  %rangeOf(ABC) 
  do i = lboundABC to hboundABC; 
    %getVal(test, ABC, i); 
    put '%getVal ' i= test=; 
  end; 
 
  test = -17; 
  /* behaves like: ABC[8] = test; */ 
  %putVal(ABC, 8, test); 
 
  /* behaveslike: ABC[7] = -42; ABC[7] = -555; */ 
  %putVal(ABC, 7, -42); 
 
  %putVal(ABC, 7, -555); 
 
  /* one loop for 2 tables, 
     first array sets up loop's index */ 
  %loopOver(ABC GHI); 
    j = _ABCcell_; 
    t = _GHIcell_; 
    output; 
  %loopEnd; 
 
  /* a loop in a loop (can't use one array twice! 
     ends with infinite loop) */ 
  %loopOver(ABC); 
    %loopOver(GHI); 
    j = _ABCcell_; 
    t = _GHIcell_; 
    put "**" j= t=; 
    %loopEnd; 
  %loopEnd; 
 
 %rangeOf(ABC) 
  put lboundABC=  hboundABC=; 
  _rc_ = ABC.REMOVE(key:lboundABC); 
  _rc_ = ABC.REMOVE(key:hboundABC) ;
 
  do _I_ = lboundABC to hboundABC; 
   %getVal(test, ABC, _I_); 
    put _ALL_; 
  end; 
 
run;
;;;;
run;


data _null_;
 set _last_ indsname = indsname;
 call execute (cats('options ps = ', ps, ' ls = ', ls, ';') );
 call execute ('proc delete data = ' !! indsname !! '; run;');
run;


%put NOTE: HELP to package dynamicArray END;