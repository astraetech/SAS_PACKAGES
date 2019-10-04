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

/*** HELP START ***/

/* >>> macro createdfarray.sas <<<
 * dynamic function array is a FCMP based approach to create 
   dynamicaly alocated numerical array with searching and WHICHN() emulation
**/

/*** HELP END ***/

/*** HELP START ***/
%macro createDFArray(  /* macro Create Dynamic Function Array */
  arrayName            /* array name, in datastep used in form of call subroutine
                          e.g. call arrayName("Allocate", -3, 3) 
                        */
, debug=0              /* if 1 then turns on debuging mode */
, simple=0             /* if 1 then disables SEARCH and WHICH functionality */
, resizefactor=0       /* if not 0 then table's dimentins are mutable after allocation,
                          i.e. if array is alocated for A[1:10] and you can do A[17] = 42
                          (it will resize itself dynamically)
                          set e.g. to 4999 for faster allocation process 
                        */
, outlib = work.DFAfcmp.package  /* default location for compiled functions */
, hashexp=13                     /* default hashexp value for hash table */
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
                * +, Add               - increment given position by value 
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
    , position /* for O, Output, R, Return/ I, Input/ +, Add it is an array's index from(into) which data is get(put)
                * for C, Clear ignored
                * for A, Allocate sets value of minposition (i.e. minimal position of the arrays's index that occured)
                * for D, Dimention returns minposition
                * for Sum, Nonmiss, Avg, Mean, Average, Min, Minimum, Max, Maximum ignored
                * for F, Find, Exist returns number of instances of a value
                * for W, Which returns the first position of data value in array
                */
    , value    /* for O, Output, R, Return it holds value retrieved from an array on a given position
                * for I, Input it holds the value inserted into an array on a given position
                * for +, Add it holds the value incrementing an array on a given position
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
          position = max(searchCnt, 0);
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
      when ('I', 'INPUT', "+", "ADD")
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

        if upcase(IO) = "+" or upcase(IO) = "ADD" then
          do;
            _TO_BE_MODIF_VALUE_ = TEMP[position + offset];
            if _TO_BE_MODIF_VALUE_ > .z then 
              value = _TO_BE_MODIF_VALUE_ + value;
          end;


        %if &simple = 0 %then %do;
          /* update info in SEARCH hash table, part 1 */
          searchKey = TEMP[position + offset];  
          searchCnt = .;
          firstIndex = .;
          _rc_ = SEARCH.find();
          searchCnt = searchCnt - 1;
          if searchCnt > 0 then 
            do;
              /* Thanks to Richard DeVenezia <rdevenezia@gmail.com> for advice! */
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
%mend createDFArray;



/*** HELP START ***/
/*
 * EXAMPLE 1; 
 * Dynamic, Serchable, and Immutable array;

  %createDFArray(ArrDSI);
  options APPEND=(cmplib = WORK.DFAfcmp) ;

  data Example1;
    call ArrDSI("Allocate", 1, 10);
    L = 0; H = 0;
    call ArrDSI("Dim", L, H);
    put L= H=;

 * populate array with data ;
    do i = L to H;
      call ArrDSI("Input", i, i**2); 
    end;

 * searchability allows to find number of occurences of value in the array ;
    F = .;
    call ArrDSI("Find", F, 16);
    put "Value 16 occure " F "times";
    call ArrDSI("Find", F, 17);
    put "Value 17 occure " F "times";

 * increase value of cell 4 by 1, and verify at WHICH position is 17 (by searchability);
    call ArrDSI("+", 4, 1);
    call ArrDSI("Which", F, 17);
    put "Value 17 occured for the first time at position " F;
  
 * get values from the array ;
    Value = .;
    do i = L to H;
      call ArrDSI("Output", i, Value); 
      put i= Value=;
    end;

 * some basic statistics ;
    call ArrDSI("Sum", ., STAT); put "sum = " STAT;
    call ArrDSI("Avg", ., STAT); put "avg = " STAT;
    call ArrDSI("Min", ., STAT); put "min = " STAT;
    call ArrDSI("Max", ., STAT); put "max = " STAT;
    call ArrDSI("Cnt", ., STAT); put "cnt = " STAT;

 * immutability does _not_ allow to increase dimensions automatically;
 * this line returns an error ;
    call ArrDSI("Input", 42, -1); 
  run;
 
**/
/*
 * EXAMPLE 2; 
 * Dynamic, Serchable, and Mutable array;

  %createDFArray(ArrDSM, resizefactor=17);
  options APPEND=(cmplib = WORK.DFAfcmp) ;

  data Example2;
    call ArrDSM("Allocate", -2, 2);
  
    do i = -2 to 2;
      call ArrDSM("Input", i, 2**i);
    end;
    
    L = .; H = .;
    call ArrDSM("Dim", L, H);
    put L= H=;

 * mutability allows to increase dimensions automatically
 * create index 3 and -3;
    call ArrDSM("+", 3, 8);
    call ArrDSM("+",-3, 0.125);
    call ArrDSM("Dim", L, H);
    put L= H=;
    
    Value = .;
    do i = L to H;
      call ArrDSM("O", i, Value);
      put i= Value=;
    end;

  run;
**/
/*
 * EXAMPLE 3; 
 * Dynamic, noserchable(a.k.a. SiMPle), and Immutable array;

  %createDFArray(ArrDSMPLI, simple=1);
  options APPEND=(cmplib = WORK.DFAfcmp) ;

  data Example3;
    call ArrDSMPLI("Allocate", -2, 2);
  
    do i = -2 to 2;
      call ArrDSMPLI("Input", i, 2**i);
    end;

 * nonsearchabile array (a.k.a. simple) does not allow ;
 * to find number of occurences of value in the array ;
 * and verify what is the first position of a value ;
 * this lines return a warning ;
    call ArrDSMPLI("Exist", i, 1);
    call ArrDSMPLI("Which", i, 1);
  run;

**/

/*
 * EXAMPLE 4; 
 * Dynamic, noserchable(a.k.a. SiMPle), and Mutable array;

  %createDFArray(ArrDSMPLM, simple=1, resizefactor=42);
  options APPEND=(cmplib = WORK.DFAfcmp) ;

  data Example4;
    call ArrDSMPLM("Allocate", 1, 1);
  
 * mutability allows to increase dimensions automatically ;
    do i = -12 to 12;
      call ArrDSMPLM("Input", i, i*2);
    end;

 * nonsearchabile array (a.k.a. simple) does not allow ;
 * to find number of occurences of value in the array ;
 * and verify what is the first position of a value ;
 * this lines return a warning ;
    i = .;
    call ArrDSMPLM("Exist", i, -24);
    put "Exist " i=;
    call ArrDSMPLM("Which", i,  24);
    put "Which " i=;
  run;

**/
/*** HELP END ***/
/**/
