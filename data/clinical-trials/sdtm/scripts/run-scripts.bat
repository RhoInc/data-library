rem Make sure Rpath is pointing to your local install of R.
    set Rpath="C:\Program Files\R\R-3.4.3\bin\R.exe"
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet dm.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet ae.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet cm.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet sv.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet lb.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet vs.R
