capture program drop auto_recode_repeatgroup
program define auto_recode_repeatgroup, rclass
    // Thin wrapper to preserve old name; forwards to recode_others_repeat
    syntax varlist(min=2 max=2)
    local arg1 : word 1 of `varlist'
    local arg2 : word 2 of `varlist'
    // call new program (capture so errors come from original implementation)
    capture noisily recode_others_repeat `arg1' `arg2'
end
