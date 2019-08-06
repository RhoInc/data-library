rem Make sure Rpath is pointing to your local install of R.
    set Rpath="C:\Program Files\R\R-3.4.3\bin\R.exe"
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet forms.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet queries.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet visits.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet dashboard-accrual.R
        %Rpath% CMD BATCH --no-save --vanilla --slave --quiet dashboard-accrual-over-time.R
