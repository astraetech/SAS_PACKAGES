
filename packages "C:\SAS_PACKAGES";

%macro listPackages();

%local filesWithCodes ;
%let   filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;

options nonotes nosource ls=max ps=max;
data _null_;
  base = "%sysfunc(pathname(packages))";
  length folder file $ 256 folderRef fileRef $ 8;

  folderRef = "_%sysfunc(datetime(), hex6.)0";

  rc=filename(folderRef, base);
  folderid=dopen(folderRef);

  put 100*"+" ;
  do i=1 to dnum(folderId); drop i;
    folder = dread(folderId, i);

    fileRef = "_%sysfunc(datetime(), hex6.)1";
    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    EOF = 0;
    if fileId = 0 and lowcase(scan(folder, -1, ".")) = 'zip' then 
      do;
          file = catx('/',base, folder);
          length nn $ 96;
          nn = repeat("*", (96-lengthn(file)));   
          put "* " file @; put nn /;
           
          infile package ZIP FILEVAR=file member="description.sas" end=EOF; 
          
          
          do until(EOF);
              input;
              if lowcase(scan(_INFILE_,1,":")) in ("package" "title" "version" "author" "maintainer") then
              putlog "  " _INFILE_;
              if strip(_INFILE_) = "DESCRIPTION START:" then leave;
          end; 
          
          
          output;
          put;
      end;
    
    rc = dclose(fileId);
    rc = filename(fileRef);
  end;

  put 100*"+";
  rc = dclose(folderid);
  rc = filename(folderRef);
  stop;
run;
options nonotes nosource;

%mend listPackages;

%listPackages()


/*
Package: 
Title: SQL queries in Data Step                 
Version: 1.0                                    
Author: Bartosz Jablonski (yabwon@gmail.com)    
Maintainer: Bartosz Jablonski (yabwon@gmail.com)

*/
