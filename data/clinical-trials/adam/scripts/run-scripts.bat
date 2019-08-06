rem Make sure Rpath is pointing to your local install of R.
    set Rpath="C:\Program Files\R\R-3.4.3\bin\R.exe"
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet adae.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet adcm.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet adlb.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet adsl.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet advs.R
