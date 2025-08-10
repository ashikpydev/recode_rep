program define auto_oth_nonre, rclass
    syntax varlist(min=2 max=2)
    
    local mainvar : word 1 of `varlist'
    local othvar  : word 2 of `varlist'
    
    display "Processing variable: `mainvar' and open-ended: `othvar'"
    
    capture confirm variable `mainvar'
    if _rc {
        display as error "Variable `mainvar' not found. Exiting."
        exit 198
    }
    capture confirm variable `othvar'
    if _rc {
        display as error "Variable `othvar' not found. Exiting."
        exit 198
    }
    
    preserve
    keep if !missing(`othvar')
    local total = _N
    contract `othvar', freq(count)
    gen percent = 100 * count / `total'
    keep if percent > 20
    quietly levelsof `othvar', local(othlist)
    restore
    
    unab varsuffixes : `mainvar'_*
    local maxcode = 1000
    foreach v of local varsuffixes {
        local num = real(substr("`v'", strlen("`mainvar'_") + 1, .))
        if `num' > `maxcode' local maxcode = `num'
    }
    
    foreach val of local othlist {
        local ++maxcode
        gen `mainvar'_`maxcode' = .
        cap order `mainvar'_`maxcode', after(`mainvar'_`=`maxcode'-1'')
        label var `mainvar'_`maxcode' "`val'"
        
        replace `mainvar'_`maxcode' = 1 if `othvar' == "`val'"
        replace `mainvar'_`maxcode' = 0 if `mainvar' != "" & `mainvar'_`maxcode' != 1
        
        replace `mainvar' = subinstr(`mainvar', "97", string(`maxcode'), .) if `othvar' == "`val'"
        replace `mainvar'_97 = 0 if `othvar' == "`val'"
        replace `othvar' = "" if `othvar' == "`val'"
        
        quietly count if `mainvar'_`maxcode' == 1
        local coded = r(N)
        local pct = round(100 * `coded' / `total', 0.01)
        
        display as result "Created `mainvar'_`maxcode' for value: `val' (code `maxcode', `pct'% of data)"
    }
end
