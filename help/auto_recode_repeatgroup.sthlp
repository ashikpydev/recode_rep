*! version 1.0.0 10 Aug 2025
help auto_recode_repeatgroup

TITLE
    auto_recode_repeatgroup — Recode open-ended responses from repeat groups into dummies

SYNOPSIS
    auto_recode_repeatgroup mainvar othervar

DESCRIPTION
    auto_recode_repeatgroup reads the open-ended text variable 'othervar' for the
    corresponding repeat-coded main variable 'mainvar' (for example: g1b4_5 g1b4oth_5).
    It creates indicator variables for frequent open-ended responses and replaces
    '97' codes in 'mainvar' with newly allocated numeric codes.

OPTIONS
    None. Supply two positional arguments: mainvar and open-ended string var.

EXAMPLE
    auto_recode_repeatgroup g1b4_5 g1b4oth_5

AUTHOR
    Ashiqur Rahman Rony <ashiqur.rahman@dri-int.org> <ashiqurrahman.stat@gmail.com>

COPYRIGHT
    Copyright (c) 2025 Ashiqur Rahman Rony
end
