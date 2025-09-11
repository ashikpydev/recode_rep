cap program drop recode_rep
program define recode_rep, rclass
    version 17.0

    syntax varlist(min=3 max=3)
    if wordcount("`varlist'") != 3 {
        display as error "Incorrect syntax. Please write help recode_rep for correct usage."
        exit 198
    }

    local mainvar : word 1 of `varlist'
    local splitvar : word 2 of `varlist'
    local othvar : word 3 of `varlist'

    display as result "Main var: `mainvar'"
    display as result "Split var (others dummy): `splitvar'"
    display as result "Open-ended var: `othvar'"

    foreach v in `mainvar' `splitvar' `othvar' {
        capture confirm variable `v'
        if _rc {
            display as error "Variable `v' not found."
            exit 198
        }
    }

    // Extract repeat number and prefix from mainvar
    local last_us_main = length("`mainvar'") - strpos(reverse("`mainvar'"), "_") + 1
    local rep = substr("`mainvar'", `last_us_main' + 1, .)
    local prefix = substr("`mainvar'", 1, `last_us_main' - 1)

    // Extract components from splitvar: prefix_OTHERCODE_REPEAT
    local rev_split = reverse("`splitvar'")
    local pos1 = strpos("`rev_split'", "_")
    if `pos1' == 0 {
        display as error "Last underscore not found in splitvar."
        exit 198
    }
    local rev2 = substr("`rev_split'", `pos1' + 1, .)
    local pos2 = strpos("`rev2'", "_")
    if `pos2' == 0 {
        display as error "Second last underscore not found in splitvar."
        exit 198
    }
    local last_us_split = length("`splitvar'") - `pos1' + 1
    local second_last_us = length("`splitvar'") - (`pos1' + `pos2') + 1

    local prefix_split = substr("`splitvar'", 1, `second_last_us' - 1)
    local others_code = substr("`splitvar'", `second_last_us' + 1, `last_us_split' - `second_last_us' - 1)
    local rep_split = substr("`splitvar'", `last_us_split' + 1, .)

    // Extract repeat number from othvar
    local last_us_oth = length("`othvar'") - strpos(reverse("`othvar'"), "_") + 1
    local rep_oth = substr("`othvar'", `last_us_oth' + 1, .)

    if ("`rep'" != "`rep_split'") | ("`rep'" != "`rep_oth'") {
        display as error "Repeat number mismatch: mainvar=`rep', splitvar=`rep_split', othvar=`rep_oth'."
        exit 198
    }

    display as result "Prefix (mainvar): `prefix'"
    display as result "Repeat number: `rep'"
    display as result "Others code (splitvar): `others_code'"
    display as result "Prefix (splitvar): `prefix_split'"

    // --- STEP 1: Gather all existing dummy vars with prefix pattern, include mainvar ---
    ds `prefix'_*
    local vars1 "`r(varlist)'"
    ds `prefix_split'_*
    local vars2 "`r(varlist)'"
    local allvars "`vars1' `vars2' `mainvar'"
    local exclude "`splitvar'"
    local varsuffixes ""
    foreach v of local allvars {
        local skip = 0
        foreach e of local exclude {
            if "`v'" == "`e'" local skip = 1
        }
        if !`skip' local varsuffixes "`varsuffixes' `v'"
    }

    // Find max numeric suffix starting from 1000
    local maxcode = 1000
    if "`varsuffixes'" != "" {
        foreach v of local varsuffixes {
            if regexm("`v'", "`prefix'_([0-9]+)_`rep'$") {
                local num = real(regexs(1))
                if `num' > `maxcode' local maxcode = `num'
            }
        }
    }

    // --- STEP 2: Collect all open-ended values ---
    preserve
        keep if !missing(`othvar') & trim(`othvar') != ""
        quietly levelsof `othvar', local(all_othlist)
    restore

    // --- STEP 3: Merge all responses into existing codes first ---
    foreach val of local all_othlist {
        local matchvar ""
        foreach v of local varsuffixes {
            local vlab : variable label `v'
            if trim("`vlab'") == trim("`val'") {
                local matchvar = "`v'"
                continue, break
            }
        }

        if "`matchvar'" != "" {
            display as result "Merged `val' into existing dummy `matchvar'."
            replace `matchvar' = 1 if trim(`othvar') == "`val'"
            replace `splitvar' = 0 if trim(`othvar') == "`val'"
            foreach v of local varsuffixes {
                if regexm("`v'", "`prefix'_`others_code'_`rep'$") {
                    replace `v' = 0 if trim(`othvar') == "`val'"
                }
            }
            replace `othvar' = "" if trim(`othvar') == "`val'"
        }
    }

    // --- STEP 4: Create new codes for frequent categories (>=10%) ---
    preserve
        keep if !missing(`othvar') & trim(`othvar') != ""
        local total = _N
        contract `othvar', freq(count)
        gen double percent = 100 * count / `total'
        keep if percent >= 10
        if _N == 0 {
            display as result "No frequent categories (>=10%). No new codes created."
            restore
            exit 0
        }
        quietly levelsof `othvar', local(freq_othlist)
    restore

    foreach val of local freq_othlist {
        local ++maxcode
        local newvar = "`prefix'_`maxcode'_`rep'"
        quietly capture confirm variable `newvar'
        if _rc {
            gen byte `newvar' = .
        }
        else {
            replace `newvar' = .
        }
        label var `newvar' "`val'"
        replace `newvar' = 1 if trim(`othvar') == "`val'"
        replace `newvar' = 0 if trim(`mainvar') != "" & `newvar' != 1
        replace `splitvar' = 0 if trim(`othvar') == "`val'"
        foreach v of local varsuffixes {
            if regexm("`v'", "`prefix'_`others_code'_`rep'$") {
                replace `v' = 0 if trim(`othvar') == "`val'"
            }
        }
        capture confirm numeric variable `mainvar'
        if !_rc {
            replace `mainvar' = `maxcode' if `mainvar' == real("`others_code'") & trim(`othvar') == "`val'"
        }
        else {
            replace `mainvar' = trim(subinstr(" " + `mainvar' + " ", " `others_code' ", " `maxcode' ", .)) if strpos(" " + `mainvar' + " ", " `others_code' ") > 0 & trim(`othvar') == "`val'"
        }
        replace `othvar' = "" if trim(`othvar') == "`val'"
        cap order `newvar', after(`splitvar')
        display as result "Created `newvar' for value: `val' (code `maxcode')"
    }

    display as result "Done. New codes started at 1001 and up (if any were added)."
end
