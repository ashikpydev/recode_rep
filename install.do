// install.do - install recode_others_repeat from GitHub
local user "ashikpydev"
local repo "auto_recode_repeatgroup"
local branch "main"

local personal = c(sysdir_personal)
if "`personal'" == "" {
    display as error "Could not determine PERSONAL ado folder. Check sysdir output and edit install.do"
    exit 198
}

local base = "https://raw.githubusercontent.com/`user'/`repo'/`branch'/"
local adourl1 = "`base'ado/recode_others_repeat.ado"
local adourl2 = "`base'ado/auto_recode_repeatgroup.ado"
local helpurl = "`base'help/recode_others_repeat.sthlp"

display "Installing into: `personal'"

capture copy "`adourl1'" "`personal'/recode_others_repeat.ado"
if _rc display as error "Failed to download recode_others_repeat.ado"

capture copy "`adourl2'" "`personal'/auto_recode_repeatgroup.ado"
if _rc display as error "Failed to download auto_recode_repeatgroup.ado"

local helpdir = "`personal'/adohelp"
cap mkdir "`helpdir'"
capture copy "`helpurl'" "`helpdir'/recode_others_repeat.sthlp"
if _rc display as error "Failed to download help file"

display "Installation complete. Restart Stata or run: adopath + \"`personal'\""
