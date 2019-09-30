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
   dynamicaly alocated numerical array with searching
*/

%macro crDFArray4(arrayName, debug=0, resizefactor=4999, outlib = work.DynamicFunctionArray.package, hashexp=13);
proc fcmp outlib = &outlib.;
  subroutine &arrayName.(
      IO $     /* steering argument:
                * O,o = Output    - get the data from an array
                * I,i = Input     - insert the data into an array
                * C,c = Clear     - reduce an array to a single empty cell
                * A,a = Allocate  - reserve space for array's width 
                *                   and set starting value
                * D,d = Dimention - returns minimal and maximal index
                * S,s = Summary   - calculate basic summary
                * F,f = Find      - search if given value exist in the array
                */
    , position /* for O(I) it is an array's index from(into) which data is get(put)
                * for C ignored
                * for A sets value of minposition (i.e. minimal position of the arrays's index that occured)
                * for D returns minposition
                * for S selects: 1=Sum, 2=Average, 3=Min, 4=Max, 5=NumberOfNonMissing
                * for F returns number of instances on a value
                */
    , value    /* for O it holds value retrieved from an array on a given position
                * for I gets maxposition info (i.e. maximal position of the arrays's index occured)
                * for C ignored
                * for A sets value of maxposition (i.e. maximal position of the arrays's index than occured)
                * for D returns maxposition
                * for S returns calculated summary value
                * for F a value to be searched
                */
    );
    outargs position, value;

    array TEMP[1] / nosymbols; /* default size */
    static TEMP .;

    static maxposition 1; /* keep track of maximal position of the arrays's index occured */
    static minposition 1; /* keep track of minimal position of the arrays's index occured */
    static offset 0;      /* if array lower bound is less than 1 keep value of shift */
   
    /* keep track of arrays elements for fast search */
    length searchKey searchCnt 8;
    declare hash SEARCH(ordered:"a", hashexp:&hashexp.);
    _rc_ = SEARCH.defineKey("searchKey");
    _rc_ = SEARCH.defineData("searchKey","searchCnt","firstIndex");
    _rc_ = SEARCH.defineDone();
    declare hiter iSEARCH("SEARCH");

    select(upcase(IO));
    /* Output - get the data from an array 
     */
      when ('OUTPUT', 'O', 'RETURN', 'R')
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

    /* Find - search if the data exist in array, returns count 
     */
      when ('FIND', 'F', 'EXIST')
        do;
          searchKey = value;
          searchCnt = .;
          _rc_ = SEARCH.find();
          position = searchCnt;
          return;
        end;

    /* firstIndex - search the first position of data in array, WHICHN substitute 
     */
      when ('WHICH', 'W')
        do;
          searchKey = value;
          firstIndex = .;
          _rc_ = SEARCH.find();
          position = firstIndex;
          return;
        end;

    /* Input - insert the data into an array 
     */
      when ('INPUT', 'I')
        do;

          if not(minposition <= position <= maxposition) then 
            do;
              put "ERROR: out of range!";
              put "ERROR- values should be between " minposition " and " maxposition;
              return;
            end;

   
          searchKey = TEMP[position + offset];
          searchCnt = .;
          firstIndex = .;
          _rc_ = SEARCH.find();
          searchCnt = searchCnt - 1;
          if searchCnt > 0 then 
            do;
              if firstIndex = position + offset then
                do firstIndex = firstIndex + 1 to maxposition 
                  while (TEMP[FirstIndex] ne searchKey);
                end;
              _rc_ = SEARCH.replace();
            end;
          else _rc_ = SEARCH.remove();

          TEMP[position + offset] = value;

          searchKey = value;
          searchCnt = .;
          firstIndex = .;
          _rc_ = SEARCH.find();
          searchCnt = max(1, searchCnt + 1);
          if firstIndex > (position + offset) then FirstIndex = (position + index);  /* new: track FirstIndex */
          _rc_ = SEARCH.replace();

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
      when ('ALLOCATE', 'A')
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
              _rc_              = SEARCH.clear();
              searchKey         = .;
              searchCnt         = _RESIZE_;
              _rc_              = SEARCH.add();
                
              maxposition       = value;
              minposition       = position;
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
              _rc_              = SEARCH.clear();
              searchKey         = .;
              searchCnt         = 1;
              _rc_              = SEARCH.add();
              return;
            end;
        end;

    /* Clear - reduce an array to a single empty cell 
     */
      when ('CLEAR', 'C')
        do;
          call dynamic_array(TEMP, 1);
          maxposition       = 1;
          minposition       = 1;
          TEMP[1]           = .;
          offset            = 0;
          _rc_              = SEARCH.clear();
          searchKey         = .;
          searchCnt         = 1;
          _rc_              = SEARCH.add();
          return;
        end;

    /* Dimention - returns minimal and maximal index 
     */
      when ('DIM', 'D', 'DIMENTION', 'DIMENTIONS')
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
      when ('SUM', 'AVERAGE', 'AVG', 'MEAN', 'NONMISS') 
        do; /* Sum, Average, NonMiss */
          value = .;
          cnt   = 0;
          do _I_ = minposition+offset to maxposition+offset;
            value = sum(value, TEMP[_I_]);
            cnt = cnt + (TEMP[_I_] > .z);
          end;
          if upcase(IO) = 'AVERAGE' 
          or upcase(IO) = 'AVG' 
          or upcase(IO) = 'MEAN' then value = divide(value, cnt);
          else 
            if upcase(IO) = 'NONMISS' then value = cnt;
          return;
        end;
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
      otherwise;
    end;

    put "NOTE: IO parameter value" IO "is unknown.";
    put "Use: O, I, C, A, D, F, or S.";
    return;
  endsub;
run;
%mend crDFArray4;


data _null_;
cards4;
options cmplib = _null_;

%crDFArray4(ArrayXYZ, debug=0, outlib = work.DynamicFunctionArray.package);

options APPEND=(cmplib = WORK.DynamicFunctionArray) ;


options fullstimer msglevel=i;
data test;                                                                                                        
                                                                                                                  
  xx = 42;                                                                                                        
  do a = -8 to 8;                                                                                                 
    b = a + ceil(ranuni(123)*10);                                                                                                        
      call ArrayXYZ("A", a, b); /* Allocate arrays size */                                                                    
      call ArrayXYZ("D", L, H); /* Get dimentions */ 
      call ArrayXYZ("F", f, .); /* Find/Search for value */ 
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
      
      call ArrayXYZ("S", 1, STAT); put "sum" STAT=;
      call ArrayXYZ("S", 2, STAT); put "avg" STAT=;
      call ArrayXYZ("S", 3, STAT); put "min" STAT=;
      call ArrayXYZ("S", 4, STAT); put "max" STAT=;
      call ArrayXYZ("S", 5, STAT); put "cnt" STAT=;
                                                                                                                  
      do i = L to H;                                                                                          
        call ArrayXYZ("O", i, xx); /* Output data */                                                                                                                                                            
        call ArrayXYZ("F", f, xx); /* Find/Search for value */
        put i= xx= f=;
      end;                                                                                                        
      put "3) " _all_ ;                                                                                                  
      put ;                                                                                                       
   end;                                                                                                           
                                                                                                                  
  /* warning - wrong range */                                                                                     
  call ArrayXYZ("A", 3, -5);                                                                                      
  call ArrayXYZ("D", L, H);                                                                                       
  put _all_;                                                                                                      
run; 
;;;;
run;


