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
                * for A sets value of maxposition (i.e. maximal position of the arrays's index than occured)
                *                 and minposition (i.e. minimal position of the arrays's index that occured)
                * for D returns minposition
                */
    , value    /* for O it holds value retrieved from an array on a given position
                * for I gets maxposition info (i.e. maximal position of the arrays's index occured)
                * for C ignored
                * for A returns position
                * for D returns maxposition
                * othervise returns .
                */
    );
    outargs position, value;

    array TEMP[100] / nosymbols; /* default size */
    static TEMP .;
    array BCKP[100] / nosymbols; /* default size */
    static BCKP .;

    static maxposition .; /* keep track of maximal position of the arrays's index occured */
    static minposition .; /* keep track of minimal position of the arrays's index occured */
    
    /* Output - get the data from an array */
    if IO = 'O' or IO = 'o' then
      do;
        if (0 < position <= dim(TEMP)) then value = TEMP[position];
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
        if position > dim(TEMP) then 
          do;
            do _I_ = 1 to dim(TEMP);
              BCKP[_I_] = TEMP[_I_];
            end;

            call dynamic_array(TEMP, position);

            do _I_ = 1 to dim(BCKP);
              TEMP[_I_] = BCKP[_I_];
            end;

            call dynamic_array(BCKP, position);
            call fillmatrix(BCKP, .); 
          end;

        TEMP[position] = value;

        maxposition = max( maxposition,  position);
        minposition = max(-minposition, -position);

        %if &debug %then %do;
          _T_ = dim(TEMP);
          put "dim(TEMP)=" _T_ "value=" value "position=" position "TEMP[position]=" TEMP[position];
        %end;
        return;
      end;
    
    /* Clear - reduce an array to a single empty cell */
    if IO = 'C' or IO = 'c' then
      do;
        call dynamic_array(TEMP, 1);
        maxposition = 1;
        minposition = 1;
        TEMP[1] = .;
        return;
      end;

    /* Allocate - reserve space for array's width 
     *            and set starting value
     */
    if IO = 'A' or IO = 'a' then
      do;
        call dynamic_array(TEMP, position);
        call fillmatrix(TEMP, value); 
        maxposition = position;
        minposition = position;
        value = position;
        %if &debug %then %do;
          _T_ = dim(TEMP);
          put "dim(TEMP)=" _T_;
        %end;
        return;
      end;

    /* Dimention - returns minimal and maximal index 
     */
    if IO = 'D' or IO = 'd' then
      do;
        position = abs(minposition);
        value    = abs(maxposition);
        %if &debug %then %do;
          _T_ = dim(TEMP);
          put "dim(TEMP)=" _T_;
        %end;
        return;
      end;


    value = .;
    return;
  endsub;
run;
%mend createDynamicFunctionArray;
