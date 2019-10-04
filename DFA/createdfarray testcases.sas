
options cmplib = _null_;

/* test of dynamic serchable immutable array */
%createDFArray(ArrayXYZ, debug=0, outlib = work.DynamicFunctionArray.package);

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
      call ArrayXYZ("+", b+3, 17); /* Insert above High - Error */  
      call ArrayXYZ("+", b  , 17);   
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
%createDFArray(ArrayABC, debug=0, simple=1, outlib = work.DynamicFunctionArray.package);

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
      call ArrayABC("+", b+3, 17); /* Insert above High - Error */  
      call ArrayABC("+", b  , 17);   
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
%createDFArray(ArrayMNK, debug=0, simple=1, resizefactor=17, outlib = work.DynamicFunctionArray.package);

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
      call ArrayMNK("+", b+3, 17); /* Insert above High - Error */  
      call ArrayMNK("+", b  , 17);   
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
%createDFArray(ArrayVWU, debug=0, simple=0, resizefactor=17, outlib = work.DynamicFunctionArray.package);

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
      i = b+3; xx = 17; call ArrayVWU("+", i, xx); /* Insert above High - No Error */  call ArrayVWU("F", f, xx); call ArrayVWU("W", w, xx); call ArrayVWU("D", L, H); put 'd) ' _all_;
      i = b  ; xx = 17; call ArrayVWU("+", i, xx);                                     call ArrayVWU("F", f, xx); call ArrayVWU("W", w, xx); call ArrayVWU("D", L, H); put 'e) ' _all_;
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
%createDFArray(ArrayBIG, debug=0, simple=0, resizefactor=4999, outlib = work.DynamicFunctionArray.package);
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
      i = b+3; xx = 17; call ArrayBIG("+", i, xx); /* Insert above High - No Error */  call ArrayBIG("F", f, xx); call ArrayBIG("W", w, xx); call ArrayBIG("D", L, H); /*put 'd) ' _all_; */
      i = b  ; xx = 17; call ArrayBIG("+", i, xx);                                     call ArrayBIG("F", f, xx); call ArrayBIG("W", w, xx); call ArrayBIG("D", L, H); /*put 'e) ' _all_; */
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
