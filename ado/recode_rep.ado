* ------------------------------------------------------------------------
* Copyright 2025 Ashiqur Rahman Rony
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
* ------------------------------------------------------------------------


cap program drop recode_rep
program define recode_rep, rclass
    version 17.0

    // Check syntax: require exactly 3 variables
    syntax varlist(min=3 max=3)
    if wordcount("`varlist'") != 3 {
        display as error "Incorrect syntax. Please write help recode_rep in command for seeing correct syntax."
        exit 198
    }

    local mainvar : word 1 of `varlist'      // e.g., g1b4_5
    local splitvar : word 2 of `varlist'     // e.g., g1b4_97_5
    local othvar : word 3 of `varlist'       // e.g., g1b4oth_5

    display as result "Main var: `mainvar'"
    display as result "Split var (others dummy): `splitvar'"
    display as result "Open-ended var: `othvar'"

    // Confirm variables exist
    foreach v in `mainvar' `splitvar' `othvar' {
        capture confirm variable `v'
        if _rc {
            display as error "Variable `v' not found. Please write help recode_rep in command for seeing correct syntax."
            exit 198
        }
    }

    // Extract repeat number and prefix from mainvar
    local last_us_main = length("`mainvar'") - strpos(reverse("`mainvar'"), "_") + 1
    local rep = substr("`mainvar'", `last_us_main' + 1, .)
    local prefix = substr("`mainvar'", 1, `last_us_main' - 1)

    // Extract from splitvar (expects pattern prefix_OTHERCODE_REPEAT)
    local rev_split = reverse("`splitvar'")
    local pos1 = strpos("`rev_split'", "_")

    if `pos1' == 0 {
        display as error "Last underscore not found in splitvar. Please write help recode_rep in command for seeing correct syntax."
        exit 198
    }

    local rev2 = substr("`rev_split'", `pos1' + 1, .)
    local pos2 = strpos("`rev2'", "_")

    if `pos2' == 0 {
        display as error "Second last underscore not found in splitvar. Please write help recode_rep in command for seeing correct syntax."
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

    // Check repeat numbers match
    if ("`rep'" != "`rep_split'") | ("`rep'" != "`rep_oth'") {
        display as error "Repeat number mismatch: mainvar=`rep', splitvar=`rep_split', othvar=`rep_oth'. Please write help recode_rep in command for seeing correct syntax."
        exit 198
    }

    display as result "Prefix (mainvar): `prefix'"
    display as result "Repeat number: `rep'"
    display as result "Others code (splitvar): `others_code'"
    display as result "Prefix (splitvar): `prefix_split'"

    // Count total non-missing non-empty open-ended responses
    preserve
        keep if !missing(`othvar') & trim(`othvar') != ""
        local total = _N
        if `total' == 0 {
            display as error "No non-empty observations in `othvar'. Please write help recode_rep in command for seeing correct syntax."
            restore
            exit 198
        }

        contract `othvar', freq(count)
        gen double percent = 100 * count / `total'
        keep if percent >= 20
        if _N == 0 {
            display as result "No open-ended categories >= 20% frequency. Nothing to recode."
            restore
            exit 0
        }
        list `othvar' count percent, noobs
        quietly levelsof `othvar', local(othlist)
    restore

    // Find existing dummy vars matching prefix_* and prefix_split_*
    ds `prefix'_*
    local vars1 "`r(varlist)'"

    ds `prefix_split'_*
    local vars2 "`r(varlist)'"

    // Combine
    local allvars "`vars1' `vars2'"

    // Exclude mainvar and splitvar
    local exclude "`mainvar' `splitvar'"
    local varsuffixes ""
    foreach v of local allvars {
        local skip = 0
        foreach e of local exclude {
            if "`v'" == "`e'" local skip = 1
        }
        if !`skip' local varsuffixes "`varsuffixes' `v'"
    }

    // Determine max numeric suffix starting at 1000
    local maxcode = 1000
    if "`varsuffixes'" != "" {
        foreach v of local varsuffixes {
            if regexm("`v'", "`prefix'_([0-9]+)_`rep'$") {
                local num = real(regexs(1))
                if `num' > `maxcode' local maxcode = `num'
            }
        }
    }

    // Create new dummy variables and recode mainvar
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

        cap order `newvar', after(`splitvar')
        label var `newvar' "`val'"

        replace `newvar' = 1 if `othvar' == `"`val'"'
        replace `splitvar' = 0 if `othvar' == `"`val'"'

        capture confirm numeric variable `mainvar'
        if _rc == 0 {
            replace `mainvar' = `maxcode' if `mainvar' == `others_code' & `othvar' == `"`val'"'
        }
        else {
            replace `mainvar' = subinstr(`mainvar', "`others_code'", "`maxcode'", .) if `othvar' == `"`val'"'
        }

        replace `othvar' = "" if `othvar' == `"`val'"'

        display as result "Created `newvar' for value: `val' (code `maxcode')"
    }

    display as result "Done. New codes started at 1001 and up (if any were added)."
end
