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
   dynamicaly alocated numerical array 
*/

%macro createDynamicFunctionArray(arrayName, debug=0, outlib = work.DynamicFunctionArray.package);
proc fcmp outlib = &outlib.;
  subroutine &arrayName.(
      IO $     /* steering argument:
                * O,o = Output    - get the data from an array
                * I,i = Input     - insert the data into an array
                * C,c = Clear     - reduce an array to a single empty cell
                * A,a = Allocate  - reserve space for array's width 
                *                   and set starting value
                * D,d = Dimention - returns minimal and maximal index
                */
    , position /* for O(I) it is an array's index from(into) which data is get(put)
                * for C ignored
                * for A sets value of minposition (i.e. minimal position of the arrays's index that occured)
                * for D returns minposition
                */
    , value    /* for O it holds value retrieved from an array on a given position
                * for I gets maxposition info (i.e. maximal position of the arrays's index occured)
                * for C ignored
                * for A sets value of maxposition (i.e. maximal position of the arrays's index than occured)
                * for D returns maxposition
                * othervise returns .
                */
    );
    outargs position, value;

    array TEMP[1] / nosymbols; /* default size */
    static TEMP .;
    array BCKP[1] / nosymbols; /* default size */
    static BCKP .;

    static maxposition 1; /* keep track of maximal position of the arrays's index occured */
    static minposition 1; /* keep track of minimal position of the arrays's index occured */
    static offset 0;      /* if array lower bound is less than 1 keep value of shift */
    
    /* Output - get the data from an array */
    if IO = 'O' or IO = 'o' then
      do;
        if (minposition <= position <= maxposition) 
          then value = TEMP[position+offset];
          else value = .;

        %if &debug %then %do;
          _T_ = dim(TEMP);
          put "dim(TEMP)=" _T_ "TEMP[position]=" TEMP[position];
        %end;
        return;
      end;
    
    /* Input - insert the data into an array */
    if IO = 'I' or IO = 'i' then
      do;   
        if not(minposition <= position <= maxposition) then 
          do;
            do _I_ = 1 to dim(TEMP);
              BCKP[_I_] = TEMP[_I_];
            end;
            
            /* shift data acordingly */
            if position < minposition then shift = abs(position - minposition);
                                      else shift = 0;

            minposition = min(minposition, position);
            maxposition = max(maxposition, position);
 
            call dynamic_array(TEMP, abs(maxposition - minposition + 1));

            do _I_ = 1 to dim(BCKP);
              TEMP[_I_ + shift] = BCKP[_I_];
            end;
            
            offset = 1 - minposition;

            call dynamic_array(BCKP, dim(TEMP));
            call fillmatrix(BCKP, .); 
          end;

        TEMP[position + offset] = value;

        %if &debug %then %do;
          _T_ = dim(TEMP);
          put "dim(TEMP)=" _T_ "value=" value "position=" position "TEMP[position]=" TEMP[position];
        %end;
        return;
      end;

    /* Allocate - reserve space for array's width 
     *            and set starting value
     */
    if IO = 'A' or IO = 'a' then
      do;
        if .z < position <= value then 
          do;
            call dynamic_array(TEMP, abs(value - position + 1));
            call fillmatrix(TEMP, .); 
            call dynamic_array(BCKP, dim(TEMP));
            call fillmatrix(BCKP, .); 

            maxposition = value;
            minposition = position;
            offset      = 1 - position;

            %if &debug %then %do;
              _T_ = dim(TEMP);
              put "dim(TEMP)=" _T_;
            %end;
            return;
          end;
        else 
          do;
            put "WARNING:" "Array's lower bound must be less or equal than upper bound.";
            put "        " "Current values are: lower =" position " upper =" value;
            put "        " "One element array created.";
            IO = 'C';
          end;
      end;

    /* Clear - reduce an array to a single empty cell */
    if IO = 'C' or IO = 'c' then
      do;
        call dynamic_array(TEMP, 1);
        maxposition = 1;
        minposition = 1;
        TEMP[1]     = .;
        return;
      end;

    /* Dimention - returns minimal and maximal index 
     */
    if IO = 'D' or IO = 'd' then
      do;
        position = minposition;
        value    = maxposition;
        %if &debug %then %do;
          _T_ = dim(TEMP);
          put "dim(TEMP)=" _T_;
        %end;
        return;
      end;

    position = .;
    value    = .;
    return;
  endsub;
run;
%mend createDynamicFunctionArray;
