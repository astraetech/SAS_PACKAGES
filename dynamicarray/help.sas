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
  put 'NOTE: The dynamicArray package, version 0.20190724' /;
  put 'NOTE: The following macros are elements of the package:' /;
  do macroname = 
      'DYNARRAY',
      'APPENDTO',
      'APPENDBEFORE',
      'LOOPOVER',
      'LOOPEND',
      'GETVAL',
      'PUTVAL',
      'RANGEOF'
      '',
      'CRDFARRAY',
      'CRDHARRAY'
      ;
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
                                                                                                                  
  /* declare empty character (of length 12) array GHI                                                             
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
  _rc_ = ABC.REMOVE(key:hboundABC ;                                                                               
                                                                                                                  
  do _I_ = lboundABC to hboundABC;                                                                                
   %getVal(test, ABC, _I_);                                                                                       
    put _ALL_;                                                                                                    
  end;                                                                                                            
                                                                                                                  
run;                                                                                                              
                                                                                                                  
/*#############################################################*/                                                 
/*                                                             */                                                 
/* create Dynamic numeric Function Array - crDFArray           */                                                 
/*                                                             */                                                 
/*#############################################################*/                                                 
                                                                                                                  
/* The ArrayABC() call routine is cerated: */                                                                     
%crDFArray(ArrayABC);                                                                                             
                                                                                                                  
data _null_;                                                                                                      
  call ArrayABC(                                                                                                  
      IO       /* CHARACTER,                                                                                      
                * steering argument:                                                                              
                * O,o = Output    - get the data from an array                                                    
                * I,i = Input     - insert the data into an array                                                 
                * C,c = Clear     - reduce an array to a single empty cell                                        
                * A,a = Allocate  - reserve space for array's width                                               
                *                   and set starting value                                                        
                * D,d = Dimention - returns minimal and maximal index                                             
                */                                                                                                
    , position /* NUMERIC,                                                                                        
                * for O(I) it is an array's index from(into) which data is get(put)                               
                * for C ignored                                                                                   
                * for A sets value of minposition (i.e. minimal position of the arrays's index that occured)      
                * for D returns minposition                                                                       
                */                                                                                                
    , value    /* NUMERIC,                                                                                        
                * for O it holds value retrieved from an array on a given position                                
                * for I gets maxposition info (i.e. maximal position of the arrays's index occured)               
                * for C ignored                                                                                   
                * for A sets value of maxposition (i.e. maximal position of the arrays's index than occured)      
                * for D returns maxposition                                                                       
                * othervise returns .                                                                             
                */                                                                                                
    );                                                                                                            
run;                                                                                                              
                                                                                                                  
options cmplib = work.DynamicFunctionArray; /* default location */                                                
                                                                                                                  
%let zeros = 4;                                                                                                   
data _null_1;                                                                                                     
                                                                                                                  
  _X_ = .;                                                                                                        
  /* declare size - it's more optimal to assume                                                                   
     some innitial size in advance (for N > 10000) */                                                             
  call ArrayABC("A", 1, 1e&zeros.);                                                                               
                                                                                                                  
  t = time();                                                                                                     
  do _I_ = 17 to 1e&zeros.;                                                                                       
    _X_ = _I_*10;                                                                                                 
    call ArrayABC("I", _I_, _X_);                                                                                 
  end;                                                                                                            
  t = time() - t;                                                                                                 
  put t= / _X_= /;                                                                                                
                                                                                                                  
  /* get the size info */                                                                                         
  LB = .; HB = .;                                                                                                 
  drop LB HB;                                                                                                     
  call ArrayABC('D', LB, HB);                                                                                     
  put LB= HB= /;                                                                                                  
                                                                                                                  
  t = time();                                                                                                     
  do _I_ = HB to LB by -1;                                                                                        
    call ArrayABC('O', _I_, _X_);                                                                                 
    output;                                                                                                       
    /*put _I_= _X_=;*/                                                                                            
  end;                                                                                                            
  t = time() - t;                                                                                                 
  put t= / _X_= /;                                                                                                
                                                                                                                  
  /* clear for further reuse */                                                                                   
  call ArrayABC('C', ., .);                                                                                       
run;                                                                                                              
                                                                                                                  
                                                                                                                  
%crDFArray(ArrayXYZ);                                                                                             
                                                                                                                  
options cmplib=work.DynamicFunctionArray;                                                                         
data test;                                                                                                        
                                                                                                                  
  xx = 42;                                                                                                        
  do a = -8 to 8;                                                                                                 
    b=a+3;                                                                                                        
      call ArrayXYZ("A", a, b); /* Allocate */                                                                    
      call ArrayXYZ("D", L, H); /* Get dimentions */                                                              
      put _all_;                                                                                                  
                                                                                                                  
      call ArrayXYZ("I", a-3, 17); /* Insert below Low */                                                         
      call ArrayXYZ("I", b+3, 17); /* Insert above High */                                                        
      call ArrayXYZ("D", L, H);                                                                                   
                                                                                                                  
      do i = L-1 to H+1;                                                                                          
        call ArrayXYZ("O", i, xx); /* Output data */                                                              
        put i= xx=;                                                                                               
      end;                                                                                                        
      put _all_;                                                                                                  
      put ;                                                                                                       
   end;                                                                                                           
                                                                                                                  
  /* warning - wrong range */                                                                                     
  call ArrayXYZ("A", 3, -5);                                                                                      
  call ArrayXYZ("D", L, H);                                                                                       
  put _all_;                                                                                                      
run;                                                                                                              
                                                                                                                  
/*#############################################################*/                                                 
/*                                                             */                                                 
/* create Dynamic Hash Function Array - crDHArray              */                                                 
/*                                                             */                                                 
/*#############################################################*/                                                 
                                                                                                                  
/* The ArrayABC() call routine is cerated: */  
data _null_;                                                                                                      
  call ArrayABC(
      IO $     /* CHARACTER
                * steering argument:
                * O,o = Output    - get the data from an array
                * I,i = Input     - insert the data into an array
                * C,c = Clear     - reduce an array to an empty one
                * L,l,H,h = Dimentions - return minimal and maximal poistion of index
                */
    , position /* NUMERIC
                * for O(I) it is an array's index from(into) which data is get(put)
                * for C ignored
                * for L returns first position of index
                * for H returns last position of index
                * othervise does not modify value
                */
    , value    /* NUM/CHAR %qsysfunc(compress(&type., $, k))   
                * for O it holds value retrieved from an array on a given position
                * for I gets maxposition info (i.e. maximal position of the arrays's index occured)
                * for C ignored
                * for L returns first value of index
                * for H returns last value of index
                * othervise does not modify value
                */
    )                                                                                                            
run;         

 
%crDHArray(ArrayABC, type = $ 12); 
options cmplib = work.DynamicFunctionArray; %* default location *; 
 
%let zeros = 3; 
data _null_1; 
 
  t = time(); 
  do _I_ = -1e&zeros. to 1e&zeros.; 
    _X_ = put(_I_*10, z12.); 
    call ArrayABC("I", _I_, _X_); 
  end; 
  t = time() - t; 
  put t= / _X_= /; 
 
  %* get the size info *; 
  LB = 0; HB = 0; 
  drop LB HB; 
  call ArrayABC('L', LB, _X_); 
  call ArrayABC('H', HB, _X_); 
  put LB= HB= /; 
 
  t = time(); 
  do _I_ = HB+1 to LB-1 by -1; 
    call ArrayABC('O', _I_, _X_); 
    output;  
  end; 
  t = time() - t; 
  put t= / _X_= /; 
 
  _N_ = sleep(5,1);
  %* clear for further reuse *; 
  call ArrayABC('C', ., ''); 
  _N_ = sleep(5,1);
  
run;                 
;;;;
run;


data _null_;
 set _last_ indsname = indsname;
 call execute (catx(" ", 'options ps = ', ps, ' ls = ', ls, ';') );
 call execute ('proc delete data = ' !! indsname !! '; run;');
run;


%put NOTE: HELP to package dynamicArray END;
