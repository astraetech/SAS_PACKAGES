/* dynamicarraybyfunction4.sas */
/**###################################################################**/
/*                                                                     */
/*  Copyright Bartosz Jablonski, July 2019.                            */
/*                                                                     */
/*  Code is free and open source. If you want - you can use it.        */
/*  But it comes with absolutely no warranty whatsoever.               */
/*  If you cause any damage or something - it will be your own fault.  */
/*  You've been warned! You are using it on your own risk.             */
/*  However, if you decide to use it don't forget to mention author.   */
/*  Bartosz Jablonski (yabwon@gmail.com)                               */
/*                                                                     */
/**###################################################################**/

/* dynamicfunctionarray is a FCMP based approach to create 
   dynamicaly alocated numerical array with searching and WHICHN() emulation
*/
/*** HELP START ***/
%macro crDFArray4(
  arrayName      /* array name */
, debug=0        /* if 1 then turns on debuging mode */
, simple=0       /* if 1 then disable SEARCH and WHICH functionality */
, resizefactor=0 /* if not 0 then table's dimentins are mutable after allocation, 
                    set e.g. to 4999 for faster allocation process */
, outlib = work.DynamicFunctionArray.package
, hashexp=13
);
/*** HELP END ***/

%if %bquote(&debug.) NE 1 %then %let debug=0;
%if %bquote(&simple.) NE 1 %then %let simple=0;

%let resizefactor = %qsysfunc(abs(&resizefactor.));
%if NOT (&resizefactor. > 0) %then %let resizefactor = 0;

/*** HELP START ***/
proc fcmp outlib = &outlib.;
  subroutine &arrayName.(
      IO $     /* steering argument:
                * O, Output, R, Return - get the data from an array
                * I, Input             - insert the data into an array
                * C, Clear             - reduce an array to a single empty cell
                * A, Allocate          - reserve space for array's width and set starting value
                * D, Dimention         - returns minimal and maximal index
                * F, Find, Exist       - finds if given value exist in the array
                * W, Which             - search the first position of data in array, WHICHN emulator
                * Sum                  - returns sum of nonmissing elements of an array
                * Nonmiss              - returns number of nonmissing elements of an array
                * Avg, Mean, Average   - returns average of nonmissing elements of an array
                * Min, Minimum         - returns minimum of nonmissing elements of an array
                * Max, Maximum         - returns maximum of nonmissing elements of an array
                */
    , position /* for O, Output, R, Return/ I, Input it is an array's index from(into) which data is get(put)
                * for C, Clear ignored
                * for A, Allocate sets value of minposition (i.e. minimal position of the arrays's index that occured)
                * for D, Dimention returns minposition
                * for Sum, Nonmiss, Avg, Mean, Average, Min, Minimum, Max, Maximum ignored
                * for F, Find, Exist returns number of instances of a value
                * for W, Which returns the first position of data value in array
                */
    , value    /* for O, Output, R, Return it holds value retrieved from an array on a given position
                * for I, Input it holds the value inserted into an array on a given position
                * for C, Clear ignored
                * for A, Allocate sets value of maxposition (i.e. maximal position of the arrays's index than occured)
                * for D, Dimention returns maxposition
                * for Sum, Nonmiss, Avg, Mean, Average, Min, Minimum, Max, Maximum returns calculated summary value
                * for F, Find, Exist, W, Which a value to be searched
                */
    );
    outargs position, value;
/*** HELP END ***/

    array TEMP[1] / nosymbols; /* default size */
    static TEMP .;
    %if &resizefactor > 0 %then %do;
    array BCKP[1] / nosymbols; /* default size */
    static BCKP .;
    %end;

    static maxposition 1; /* keep track of maximal position of the arrays's index occured */
    static minposition 1; /* keep track of minimal position of the arrays's index occured */
    static offset 0;      /* if array lower bound is less than 1 keep value of shift */

    %if &resizefactor > 0 %then %do;
      static globalmaxposition 1; /* keep track of globalmaximal position of the arrays's boundary */
      static globalminposition 1; /* keep track of globalminimal position of the arrays's boundary */
    %end;
   
    %if &simple = 0 %then %do;
    /* keep track of arrays elements for fast search */
    length searchKey searchCnt 8;
    declare hash SEARCH(ordered:"a", hashexp:&hashexp.);
    _rc_ = SEARCH.defineKey("searchKey");
    _rc_ = SEARCH.defineData("searchKey","searchCnt","firstIndex");
    _rc_ = SEARCH.defineDone();
    declare hiter iSEARCH("SEARCH");
    %end;

    select(upcase(IO));
    /* Output - get the data from an array 
     */
      when ('O', 'OUTPUT', 'R', 'RETURN')
        do;
          if (minposition <= position <= maxposition) 
            then value = TEMP[position + offset];
            else value = .;

          %if &debug %then %do;
            _T_ = dim(TEMP);
            put "NOTE:[&arrayName.] Debug O:" "dim(TEMP)=" _T_ "TEMP[position]=" TEMP[position + offset];
          %end;
          return;
        end;

    %if &simple = 0 %then %do;
    /* Find - search if the data exist in array, returns count 
     */
      when ('F', 'FIND', 'EXIST')
        do;
          searchKey = value;
          searchCnt = .;
          _rc_ = SEARCH.find();
          position = searchCnt;
          return;
        end;
    /* firstIndex - search the first position of data in array, WHICHN emulator 
     */
      when ('W', 'WHICH')
        do;
          searchKey = value;
          firstIndex = .;
          _rc_ = SEARCH.find();
          position = firstIndex;
          return;
        end;
    %end;

    /* Input - insert the data into an array 
     */
      when ('I', 'INPUT')
        do;
        %if &resizefactor > 0 %then %do;
        /* to avoid resizeing when every new element is added */ 
        if not(globalminposition <= position <= globalmaxposition) then 
          do; 
            /* alocate temporary BaCKuP memory */ 
            call dynamic_array(BCKP, dim(TEMP)); 
            do _I_ = 1 to dim(TEMP);
              BCKP[_I_] = TEMP[_I_];
            end;
            
            /* shift data acordingly */
            if position < globalminposition 
              then shift = abs(position - globalminposition) + &resizefactor.;
              else shift = 0;

            globalminposition = min(globalminposition, position) - &resizefactor.*(position < globalminposition);
            globalmaxposition = max(globalmaxposition, position) + &resizefactor.*(position > globalmaxnposition);
            
            /* to handle the 65535 issue */
            _RESIZE_ = abs(globalmaxposition - globalminposition + 1);
            if _RESIZE_ = 65535 then 
              do;
                _RESIZE_ = _RESIZE_ + 1;
                globalmaxposition = globalmaxposition + 1;
              end;
            call dynamic_array(TEMP, _RESIZE_);
            
            %if &debug %then %do;
              _T_ = dim(TEMP); 
              put "NOTE:[&arrayName.] Debug I: 0): dim(TEMP)=" _T_; 
              put "NOTE:[&arrayName.] Debug I: 1): min=" minposition "and max=" maxposition; 
              put "NOTE:[&arrayName.] Debug I: 2): gmin=" globalminposition "and gmax=" globalmaxposition;
              put "NOTE:[&arrayName.] Debug I: 3): position=" position "shift=" shift;
            %end;

            do _I_ = 1 to dim(BCKP);
              TEMP[_I_ + shift] = BCKP[_I_];
            end;
            
            offset = 1 - globalminposition;

            call dynamic_array(BCKP, 1);
            %if &debug %then %do;
              put "NOTE:[&arrayName.] Debug I: offset=" offset;
            %end;
          end;

        %if &simple = 0 %then %do;
        dim_before = maxposition - minposition;
        %end;
        if not(minposition <= position <= maxposition) then 
          do;
            minposition = min(minposition, position);
            maxposition = max(maxposition, position);
          end;
        %if &simple = 0 %then %do;
        dim_after = maxposition - minposition;
        %end;

        %end;
        %else %do;
          if not(minposition <= position <= maxposition) then 
            do;
              put "ERROR: out of range!";
              put "ERROR: values should be between " minposition " and " maxposition;
              return;
            end;
        %end;


        %if &resizefactor > 0 and &simple = 0 %then %do;
        /*put "*> dim_before=" dim_before;*/
        /*put "*> dim_after=" dim_after;*/

        expansion_size = abs(dim_before - dim_after);
        if expansion_size > 0 then
          do;
            searchKey = .;
            searchCnt = .;
            firstIndex = .;
            _rc_ = SEARCH.find();
            searchCnt = max(expansion_size, searchCnt + expansion_size);
            /*put "searchCnt=" searchCnt;*/
            firstIndex = min(firstIndex, position);
            _rc_ = SEARCH.replace();
          end;
        %end;

        %if &simple = 0 %then %do;
          /* update info in SEARCH hash table, part 1 */
          searchKey = TEMP[position + offset];  
          searchCnt = .;
          firstIndex = .;
          _rc_ = SEARCH.find();
          searchCnt = searchCnt - 1;
          if searchCnt > 0 then 
            do;
              ddd=dim(TEMP);
              if firstIndex = position then do;
                  do firstIndex = (firstIndex + 1) to (maxposition) 
                    while (TEMP[firstIndex + offset] ne searchKey);
                  end;
              end;
              _rc_ = SEARCH.replace();
            end;
          else _rc_ = SEARCH.remove();
        %end;

          /* insert data into array */
          TEMP[position + offset] = value;

        %if &simple = 0 %then %do;
          /* update info in SEARCH hash table, part 2 */
          searchKey = value;
          searchCnt = .;
          firstIndex = .;
          _rc_ = SEARCH.find();
          searchCnt = max(1, searchCnt + 1);
          firstIndex = min(firstIndex, position);  /* new: track firstIndex */
          _rc_ = SEARCH.replace();
        %end;

          %if &debug %then %do;
            _T_ = dim(TEMP);
            put "NOTE:[&arrayName.] Debug I: min=" minposition "and max=" maxposition;
            put "NOTE:[&arrayName.] Debug I: dim(TEMP)=" _T_ "value=" value "position=" position "TEMP[position]=" TEMP[position + offset];
          %end;
          return;
        end;

    /* Allocate - reserve space for array's width 
     *            and set starting value
     */
      when ('A', 'ALLOCATE')
        do;
          if .z < position <= value then 
            do;
              /* to handle the 65535 issue */
              _RESIZE_ = abs(value - position + 1);
              if _RESIZE_ = 65535 then 
                do;
                  _RESIZE_ = _RESIZE_ + 1;
                  put "NOTE: to handle 65535 issue array size set to 65536";
                end;

              call dynamic_array(TEMP, _RESIZE_);
              call fillmatrix(TEMP, .); 
              %if &simple = 0 %then %do;
              _rc_              = SEARCH.clear();
              searchKey         = .;
              searchCnt         = _RESIZE_;
              firstIndex        = position;
              _rc_              = SEARCH.add();
              %end;  
              maxposition       = value;
              minposition       = position;
              %if &resizefactor > 0 %then %do;
              globalmaxposition = value;
              globalminposition = position;
              %end;
              offset            = 1 - position;

              %if &debug %then %do;
                _T_ = dim(TEMP);
                put "NOTE:[&arrayName.] Debug A:" "dim(TEMP)=" _T_;
              %end;
              return;
            end;
          else 
            do;
              put "WARNING:" "Array's lower bound must be less or equal than upper bound.";
              put "        " "Current values are: lower =" position " upper =" value;
              put "        " "One element array created.";
              call dynamic_array(TEMP, 1);
              maxposition       = 1;
              minposition       = 1;
              TEMP[1]           = .;
              offset            = 0;
              %if &simple = 0 %then %do;
              _rc_              = SEARCH.clear();
              searchKey         = .;
              searchCnt         = 1;
              firstIndex        = 1;
              _rc_              = SEARCH.add();
              %end;
              %if &resizefactor > 0 %then %do;
              globalmaxposition = 1;
              globalminposition = 1;
              %end;
              return;
            end;
        end;

    /* Clear - reduce an array to a single empty cell 
     */
      when ('C', 'CLEAR')
        do;
          call dynamic_array(TEMP, 1);
          maxposition       = 1;
          minposition       = 1;
          TEMP[1]           = .;
          offset            = 0;
          %if &simple = 0 %then %do;
          _rc_              = SEARCH.clear();
          searchKey         = .;
          searchCnt         = 1;
          firstIndex        = 1;
          _rc_              = SEARCH.add();
          %end;
          %if &resizefactor > 0 %then %do;
          globalmaxposition = 1;
          globalminposition = 1;
          %end;
          return;
        end;

    /* Dimention - returns minimal and maximal index 
     */
      when ('D', 'DIM', 'DIMENTION', 'DIMENTIONS')
        do;
          position = minposition;
          value    = maxposition;
          %if &debug %then %do;
            _T_ = dim(TEMP);
            put "NOTE:[&arrayName.] Debug D:" "dim(TEMP)=" _T_;
          %end;
          return;
        end;

    /* Statistics - returns selected statistics 
     */
      when ('SUM', 'AVG', 'MEAN', 'AVERAGE', 'CNT', 'NONMISS') 
        do; /* Sum, Average, NonMiss */
          value = .;
          cnt   = 0;
          do _I_ = minposition+offset to maxposition+offset;
            value = sum(value, TEMP[_I_]);
            cnt = cnt + (TEMP[_I_] > .z);
          end;
          if upcase(IO) = 'AVG' 
          or upcase(IO) = 'MEAN' 
          or upcase(IO) = 'AVERAGE' then value = divide(value, cnt);
          else 
            if upcase(IO) = 'CNT' 
            or upcase(IO) = 'NONMISS' then value = cnt;
          return;
        end;
      %if simple = 0 %then %do;
      when ('MIN', 'MINIMUM') /* Min */
        do;
          do while(searchKey <= .z and iSEARCH.next() = 0);
             value = searchKey;
          end;
          _rc_ = iSEARCH.first();
          _rc_ = iSEARCH.prev();
          return;
        end;
      when ('MAX', 'MAXIMUM') /* Max */
        do;
          _rc_ = iSEARCH.last();
          value = searchKey;
          _rc_ = iSEARCH.next();
          return;
        end;
      %end;
      %else %do;
      when ('MIN', 'MINIMUM') /* Min */
        do;
          value = .;
            do _I_ = minposition+offset to maxposition+offset;
              value = min(value, TEMP[_I_]);
            end;
          return;
        end;
      when ('MAX', 'MAXIMUM') /* Max */
        do;
          value = .;
            do _I_ = minposition+offset to maxposition+offset;
              value = max(value, TEMP[_I_]);
            end;
          return;
        end;
      %end;
      otherwise;
    end;

    put "WARNING: IO parameter value" IO "is unknown.";
    put "NOTE: Use: 'O', 'OUTPUT', 'R', 'RETURN', 'I', 'INPUT', 'A', 'ALLOCATE'";
    put "NOTE:  or  'C', 'CLEAR', 'D', 'DIM', 'DIMENTION', 'DIMENTIONS', 'SUM'";
    put "NOTE:  or  'AVG', 'MEAN', 'AVERAGE', 'CNT', 'NONMISS'";
    put "NOTE:  or  'MIN', 'MINIMUM', 'MAX', 'MAXIMUM'";
    %if simple = 0 %then %do;
    put "NOTE:   or 'F', 'FIND', 'EXIST', 'W', 'WHICH'";
    %end;
    return;
  endsub;
run;
%mend crDFArray4;


options cmplib = _null_;

/* test of dynamic serchable immutable array */
%crDFArray4(ArrayXYZ, debug=0, outlib = work.DynamicFunctionArray.package);

options APPEND=(cmplib = WORK.DynamicFunctionArray) ;


options fullstimer msglevel=i; resetline;
data test;                                                                                                        
                                                                                                                  
  xx = 42;                                                                                                        
  do a = -8 to 8;                                                                                                 
    b = a + ceil(ranuni(123)*10);                                                                                                        
      call ArrayXYZ("A", a, b); /* Allocate arrays size */                                                                    
      call ArrayXYZ("D", L, H); /* Get dimentions */ 
      call ArrayXYZ("F", f, .); /* Find/Search for value */
      call ArrayXYZ('W', w, .); /* which is the first index */ 
      put "1) " _all_; put;                                                                                                 
      

      do i = L to H;
        if ranuni(123) > 0.5 then do; call ArrayXYZ("I", i, i); put i= @; end;
      end; 
      put ;
      call ArrayXYZ("I", a-3, 17); /* Insert below Low - Error */ 
      call ArrayXYZ("I", a  , 17); 
      call ArrayXYZ("I",floor((b+a)/2),42);
      call ArrayXYZ("I", b+3, 17); /* Insert above High - Error */  
      call ArrayXYZ("I", b  , 17);   
      call ArrayXYZ("D", L, H);  
      put "2) " _all_;
      
      call ArrayXYZ("sum", 1, STAT); put "sum " STAT=;
      call ArrayXYZ("avg", 2, STAT); put "avg " STAT=;
      call ArrayXYZ("min", 3, STAT); put "min " STAT=;
      call ArrayXYZ("max", 4, STAT); put "max " STAT=;
      call ArrayXYZ("cnt", 5, STAT); put "cnt " STAT=;
                                                                                                                  
      do i = L to H;                                                                                          
        call ArrayXYZ("O", i, xx); /* Output data */                                                                                                                                                            
        call ArrayXYZ("F", f, xx); /* Find/Search for value */
        call ArrayXYZ('W', w, xx); /* which is the first index */      
        put i= xx= f= w=;
      end;                                                                                                        
      put "3) " _all_ ;                                                                                                  
      put ;                                                                                                       
   end;                                                                                                           
                                                                                                                  
  /* warning - wrong range */                                                                                     
  call ArrayXYZ("A", 3, -5);                                                                                      
  call ArrayXYZ("D", L, H);                                                                                       
  put _all_;                                                                                                      
run; 

options cmplib = _null_;

/* test of dynamic non-serchable immutable array */
%crDFArray4(ArrayABC, debug=0, simple=1, outlib = work.DynamicFunctionArray.package);

options APPEND=(cmplib = WORK.DynamicFunctionArray) ;


options fullstimer msglevel=i;
data test;                                                                                                        
                                                                                                                  
  xx = 42;                                                                                                        
  do a = -8 to 8;                                                                                                 
    b = a + ceil(ranuni(123)*10);                                                                                                        
      call ArrayABC("A", a, b); /* Allocate arrays size */                                                                    
      call ArrayABC("D", L, H); /* Get dimentions */ 
      call ArrayABC("F", f, .); /* Find/Search for value */ 
      call ArrayABC('W', w, .); /* which is the first index */
      put "1) " _all_; put;                                                                                                 
      

      do i = L to H;
        if ranuni(123) > 0.5 then do; call ArrayABC("I", i, i); put i= @; end;
      end; 
      put ;
      call ArrayABC("I", a-3, 17); /* Insert below Low - Error */ 
      call ArrayABC("I", a  , 17); 
      call ArrayABC("I",floor((b+a)/2),42);
      call ArrayABC("I", b+3, 17); /* Insert above High - Error */  
      call ArrayABC("I", b  , 17);   
      call ArrayABC("D", L, H);  
      put "2) " _all_;
      
      call ArrayABC("sum", 1, STAT); put "sum " STAT=;
      call ArrayABC("avg", 2, STAT); put "avg " STAT=;
      call ArrayABC("min", 3, STAT); put "min " STAT=;
      call ArrayABC("max", 4, STAT); put "max " STAT=;
      call ArrayABC("cnt", 5, STAT); put "cnt " STAT=;
                                                                                                                  
      do i = L to H;                                                                                          
        call ArrayABC("O", i, xx); /* Output data */                                                                                                                                                            
        call ArrayABC("F", f, xx); /* Find/Search for value */
        call ArrayABC('W', w, xx); /* which is the first index */
        put i= xx= f= w=;
      end;                                                                                                        
      put "3) " _all_ ;                                                                                                  
      put ;                                                                                                       
   end;                                                                                                           
                                                                                                                  
  /* warning - wrong range */                                                                                     
  call ArrayABC("A", 3, -5);                                                                                      
  call ArrayABC("D", L, H);                                                                                       
  put _all_;                                                                                                      
run; 



options cmplib = _null_;
/* test of dynamic non-serchable mutable array */
%crDFArray4(ArrayMNK, debug=0, simple=1, resizefactor=17, outlib = work.DynamicFunctionArray.package);

options APPEND=(cmplib = WORK.DynamicFunctionArray) ;


options fullstimer msglevel=i;
data test;                                                                                                        
                                                                                                                  
  xx = 42;                                                                                                        
  do a = -8 to 8;                                                                                                 
    b = a + ceil(ranuni(123)*10);                                                                                                        
      call ArrayMNK("A", a, b); /* Allocate arrays size */                                                                    
      call ArrayMNK("D", L, H); /* Get dimentions */ 
      call ArrayMNK("F", f, .); /* Find/Search for value */
      call ArrayMNK('W', w, .); /* which is the first index */ 
      put "1) " _all_; put;                                                                                                 
      

      do i = L to H;
        if ranuni(123) > 0.5 then do; call ArrayMNK("I", i, i); put i= @; end;
      end; 
      put ;
      call ArrayMNK("I", a-3, 17); /* Insert below Low - Error */ 
      call ArrayMNK("I", a  , 17); 
      call ArrayMNK("I",floor((b+a)/2),42);
      call ArrayMNK("I", b+3, 17); /* Insert above High - Error */  
      call ArrayMNK("I", b  , 17);   
      call ArrayMNK("D", L, H);  
      put "2) " _all_;
      
      call ArrayMNK("sum", 1, STAT); put "sum " STAT=;
      call ArrayMNK("avg", 2, STAT); put "avg " STAT=;
      call ArrayMNK("min", 3, STAT); put "min " STAT=;
      call ArrayMNK("max", 4, STAT); put "max " STAT=;
      call ArrayMNK("cnt", 5, STAT); put "cnt " STAT=;
                                                                                                                  
      do i = L to H;                                                                                          
        call ArrayMNK("O", i, xx); /* Output data */                                                                                                                                                            
        call ArrayMNK("F", f, xx); /* Find/Search for value */
        call ArrayMNK('W', w, xx); /* which is the first index */
        put i= xx= f= w=;
      end;                                                                                                        
      put "3) " _all_ ;                                                                                                  
      put ;                                                                                                       
   end;                                                                                                           
                                                                                                                  
  /* warning - wrong range */                                                                                     
  call ArrayMNK("A", 3, -5);                                                                                      
  call ArrayMNK("D", L, H);                                                                                       
  put _all_;                                                                                                      
run; 

/*dm 'log;clear;';*/
/*resetline;*/
options cmplib = _null_;
/* test of dynamic serchable mutable array */
options mprint;
%crDFArray4(ArrayVWU, debug=0, simple=0, resizefactor=17, outlib = work.DynamicFunctionArray.package);

options APPEND=(cmplib = WORK.DynamicFunctionArray) ;


options fullstimer msglevel=i;
data test;                                                                                                        
                                                                                                                  
  xx = 42;                                                                                                        
  do a = -8 to 8;                                                                                                 
    b = a + ceil(ranuni(123)*10);
      call ArrayVWU("A", a, b); /* Allocate arrays size */                                                                    
      call ArrayVWU("D", L, H); /* Get dimentions */ 
      call ArrayVWU("F", f, .); /* Find/Search for value */
      call ArrayVWU('W', w, .); /* which is the first index */ 
      put "1) " _all_; put;                                                                                                 
      

      do i = L to H;
        if ranuni(123) > 0.5 then do; 
                                    call ArrayVWU("I", i, i); 
                                    call ArrayVWU("D", L, H); 
                                    call ArrayVWU("F", f, .); 
                                    call ArrayVWU('W', w, .); 
                                    put i= @; put 'x) ' _all_;  
                                  end;
      end; 
      put ;
      i = a-3; xx = 17; call ArrayVWU("I", i, xx); /* Insert below Low - No Error */   call ArrayVWU("F", f, xx); call ArrayVWU("W", w, xx); call ArrayVWU("D", L, H); put 'a) ' _all_;
      i = a  ; xx = 17; call ArrayVWU("I", i, xx);                                     call ArrayVWU("F", f, xx); call ArrayVWU("W", w, xx); call ArrayVWU("D", L, H); put 'b) ' _all_;
      i=floor((b+a)/2); xx = 42; call ArrayVWU("I", i, xx);                            call ArrayVWU("F", f, xx); call ArrayVWU("W", w, xx); call ArrayVWU("D", L, H); put 'c) ' _all_;
      i = b+3; xx = 17; call ArrayVWU("I", i, xx); /* Insert above High - No Error */  call ArrayVWU("F", f, xx); call ArrayVWU("W", w, xx); call ArrayVWU("D", L, H); put 'd) ' _all_;
      i = b  ; xx = 17; call ArrayVWU("I", i, xx);                                     call ArrayVWU("F", f, xx); call ArrayVWU("W", w, xx); call ArrayVWU("D", L, H); put 'e) ' _all_;
      call ArrayVWU("D", L, H);
      call ArrayVWU("F", f, .); /* Find/Search for value */
      call ArrayVWU('W', w, .); /* which is the first index */ 
      put "2) " _all_;
      
      call ArrayVWU("sum", 1, STAT); put "sum " STAT=;
      call ArrayVWU("avg", 2, STAT); put "avg " STAT=;
      call ArrayVWU("min", 3, STAT); put "min " STAT=;
      call ArrayVWU("max", 4, STAT); put "max " STAT=;
      call ArrayVWU("cnt", 5, STAT); put "cnt " STAT=;
                                                                                                                  
      do i = L to H;                                                                                          
        call ArrayVWU("O", i, xx); /* Output data */                                                                                                                                                            
        call ArrayVWU("F", f, xx); /* Find/Search for value */
        call ArrayVWU('W', w, xx); /* which is the first index */
        put i= xx= f= w=;
      end;                                                                                                        
      put "3) " _all_ ;                                                                                                  
      put ;                                                                                                       
   end;                                                                                                           
                                                                                                                  
  /* warning - wrong range */                                                                                     
  call ArrayVWU("A", 3, -5);                                                                                      
  call ArrayVWU("D", L, H);                                                                                       
  put _all_;                                                                                                      
run; 

options nomprint;


options cmplib = _null_;
%crDFArray4(ArrayBIG, debug=0, simple=0, resizefactor=4999, outlib = work.DynamicFunctionArray.package);
options APPEND=(cmplib = WORK.DynamicFunctionArray) ;


data test;                                                                                                        
                                                                                                                  
  xx = 42;                                                                                                        
  do a = -10000 to 10000;                                                                                                 
    b = a + 10000 + ceil(ranuni(123)*10000);
      call ArrayBIG("A", a, b); /* Allocate arrays size */                                                                    
      call ArrayBIG("D", L, H); /* Get dimentions */ 
      call ArrayBIG("F", f, .); /* Find/Search for value */
      call ArrayBIG('W', w, .); /* which is the first index */ 
/*      put "1) " _all_; put;                                                                                                 */
      

      do i = L to H;
        if ranuni(123) > 0.5 then do; 
                                    call ArrayBIG("I", i, i); 
                                    call ArrayBIG("D", L, H); 
                                    call ArrayBIG("F", f, .); 
                                    call ArrayBIG('W', w, .); 
/*                                    put i= @; put 'x) ' _all_;  */
                                  end;
      end; 
      /*put ;*/
      i = a-3; xx = 17; call ArrayBIG("I", i, xx); /* Insert below Low - No Error */   call ArrayBIG("F", f, xx); call ArrayBIG("W", w, xx); call ArrayBIG("D", L, H); /*put 'a) ' _all_; */
      i = a  ; xx = 17; call ArrayBIG("I", i, xx);                                     call ArrayBIG("F", f, xx); call ArrayBIG("W", w, xx); call ArrayBIG("D", L, H); /*put 'b) ' _all_; */
      i=floor((b+a)/2); xx = 42; call ArrayBIG("I", i, xx);                            call ArrayBIG("F", f, xx); call ArrayBIG("W", w, xx); call ArrayBIG("D", L, H); /*put 'c) ' _all_; */
      i = b+3; xx = 17; call ArrayBIG("I", i, xx); /* Insert above High - No Error */  call ArrayBIG("F", f, xx); call ArrayBIG("W", w, xx); call ArrayBIG("D", L, H); /*put 'd) ' _all_; */
      i = b  ; xx = 17; call ArrayBIG("I", i, xx);                                     call ArrayBIG("F", f, xx); call ArrayBIG("W", w, xx); call ArrayBIG("D", L, H); /*put 'e) ' _all_; */
      call ArrayBIG("D", L, H);
      call ArrayBIG("F", f, .); /* Find/Search for value */
      call ArrayBIG('W', w, .); /* which is the first index */ 
/*      put "2) " _all_;*/
      
      call ArrayBIG("sum", 1, STAT); /*put "sum " STAT=;*/
      call ArrayBIG("avg", 2, STAT); /*put "avg " STAT=;*/
      call ArrayBIG("min", 3, STAT); /*put "min " STAT=;*/
      call ArrayBIG("max", 4, STAT); /*put "max " STAT=;*/
      call ArrayBIG("cnt", 5, STAT); /*put "cnt " STAT=;*/
                                                                                                                  
      do i = L to H;                                                                                          
        call ArrayBIG("O", i, xx); /* Output data */                                                                                                                                                            
        call ArrayBIG("F", f, xx); /* Find/Search for value */
        call ArrayBIG('W', w, xx); /* which is the first index */
/*        put i= xx= f= w=;*/
      end;                                                                                                        
/*      put "3) " _all_ ;                                                                                                  */
/*      put ;                                                                                                       */
   end;                                                                                                           
                                                                                                                  
  /* warning - wrong range */                                                                                     
  call ArrayBIG("A", 3, -5);                                                                                      
  call ArrayBIG("D", L, H);                                                                                       
  put _all_;                                                                                                      
run; 
