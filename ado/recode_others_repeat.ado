capture program drop recode_others_repeat
program define recode_others_repeat, rclass
    version 17.0
    // Call: recode_others_repeat mainvar othervar
    syntax varlist(min=2 max=2)

    // args
    local mainvar : word 1 of `varlist'    // e.g. g1b4_5
    local othvar  : word 2 of `varlist'    // e.g. g1b4oth_5

    display as result "Processing main variable: `mainvar'"
    display as result "Open-ended variable: `othvar'"

    // existence checks
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

    // user-changeable defaults (edit in file or change in a future version)
    local basecode = 1000   // first new code will be basecode+1 -> 1001
    local pctthreshold = 5  // percent threshold (>=)

    // gather open-ended values >= threshold
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
        keep if percent >= `pctthreshold'
        if _N == 0 {
            display as result "No categories >= `pctthreshold'% found. Nothing to recode."
            restore
            exit 0
        }
        list `othvar' count percent, noobs
        quietly levelsof `othvar', local(othlist)
    restore

    // get matching vars for this repeat (exclude main and dummy97)
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

    // determine current max code but start at basecode
    local maxcode = `basecode'
    foreach v of local varsuffixes {
        if regexm("`v'", "`prefix'_([0-9]+)_`rep'$") {
            local num = real(regexs(1))
            if `num' > `maxcode' local maxcode = `num'
        }
    }

    // For each open-ended category, create dummy and recode
    foreach val of local othlist {
        local ++maxcode
        local newvar = "`prefix'_`maxcode'_`rep'"

        // create new dummy (init 0 then set 1)
        quietly capture confirm variable `newvar'
        if _rc {
            gen byte `newvar' = 0
        }
        else {
            replace `newvar' = 0
        }
        cap order `newvar', after(`dummy97')
        label var `newvar' "`val'"

        // set dummy = 1 where open-ended text matches
        replace `newvar' = 1 if `othvar' == "`val'"

        // reset old 97 dummy for those rows
        replace `dummy97' = 0 if `othvar' == "`val'"

        // update mainvar:
        capture confirm numeric variable `mainvar'
        if _rc == 0 {
            // numeric mainvar
            replace `mainvar' = `maxcode' if `mainvar' == 97 & `othvar' == "`val'"
        }
        else {
            // string mainvar: naive substring replacement; acceptable for typical SurveyCTO coding
            replace `mainvar' = subinstr(`mainvar', "97", "`maxcode'", .) if `othvar' == "`val'"
        }

        // clear matched open-ended text
        replace `othvar' = "" if `othvar' == "`val'"

        display as result "Created `newvar' for value: `val' (code `maxcode')"
    }

    display as result "Done. New codes started at `=`basecode'+1' and up (if any were added)."
end
