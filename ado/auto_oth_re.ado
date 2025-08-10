program drop auto_oth_re
program define auto_oth_re, rclass
    // Call: auto_oth_re g1b4_5 g1b4oth_5
    syntax varlist(min=2 max=2)
    
    local mainvar : word 1 of `varlist'    // e.g. g1b4_5
    local othvar  : word 2 of `varlist'    // e.g. g1b4oth_5
    
    display as result "Processing main variable: `mainvar'"
    display as result "Open-ended variable: `othvar'"
    
    // basic existence checks
    capture confirm variable `mainvar'
    if _rc {
        display as error "Main variable `mainvar' not found. Exiting."
        exit 198
    }
    capture confirm variable `othvar'
    if _rc {
        display as error "Open-ended variable `othvar' not found. Exiting."
        exit 198
    }
    
    // extract prefix and repeat using last underscore
    local last_underscore = length("`mainvar'") - strpos(reverse("`mainvar'"), "_") + 1
    local prefix = substr("`mainvar'", 1, `last_underscore' - 1)
    local rep    = substr("`mainvar'", `last_underscore' + 1, .)
    
    local dummy97 = "`prefix'_97_`rep'"
    capture confirm variable `dummy97'
    if _rc {
        display as error "Dummy variable `dummy97' not found. Exiting."
        exit 198
    }
    
    // get the list of open-ended values >=20%
    preserve
        keep if !missing(`othvar') & trim(`othvar') != ""
        local total = _N
        if `total' == 0 {
            display as error "No non-empty observations in `othvar'. Exiting."
            restore
            exit 198
        }
    
        contract `othvar', freq(count)
        gen double percent = 100 * count / `total'
        keep if percent >= 20
        if _N == 0 {
            display as result "No categories >= 20% found. Nothing to recode."
            restore
            exit 0
        }
        list `othvar' count percent, noobs
        quietly levelsof `othvar', local(othlist)
    restore
    
    // find existing numeric-code suffixes for this repeat
    ds `prefix'_*_`rep'
    local allvars "`r(varlist)'"
    local exclude "`mainvar' `dummy97'"
    local varsuffixes ""
    foreach v of local allvars {
        local skip = 0
        foreach e of local exclude {
            if "`v'" == "`e'" local skip = 1
        }
        if !`skip' local varsuffixes "`varsuffixes' `v'"
    }
    
    // determine current max code (start at 97)
    local maxcode = 97
    foreach v of local varsuffixes {
        if regexm("`v'", "`prefix'_([0-9]+)_`rep'$") {
            local num = real(regexs(1))
            if `num' > `maxcode' local maxcode = `num'
        }
    }
    
    // For each kept open-ended category, create new dummy and recode
    foreach val of local othlist {
        local ++maxcode
        local newvar = "`prefix'_`maxcode'_`rep'"
        
        quietly capture confirm variable `newvar'
        if _rc {
            gen byte `newvar' = 0
        }
        else {
            replace `newvar' = 0
        }
        cap order `newvar', after(`dummy97')
        label var `newvar' "`val'"
        
        replace `newvar' = 1 if `othvar' == "`val'"
        replace `dummy97' = 0 if `othvar' == "`val'"
        
        capture confirm numeric variable `mainvar'
        if _rc == 0 {
            replace `mainvar' = `maxcode' if `mainvar' == 97 & `othvar' == "`val'"
        }
        else {
            replace `mainvar' = subinstr(`mainvar', "97", "`maxcode'", .) if `othvar' == "`val'"
        }
        
        replace `othvar' = "" if `othvar' == "`val'"
        
        display as result "Created `newvar' for value: `val' (code `maxcode')"
    }
    
    display as result "Done. New codes started at 98 and up (if any were added)."
end
