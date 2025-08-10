## Installation

Option A — Easy (recommended)
1. Open Stata.
2. Run the following (edit USER/REPO if necessary):

    do http://raw.githubusercontent.com/USERNAME/REPO/main/install.do

Option B — Manual
1. Download `auto_recode_repeatgroup.ado` and `auto_recode_repeatgroup.sthlp` from the repo.
2. Copy `auto_recode_repeatgroup.ado` into your PERSONAL ado folder (see `sysdir` in Stata).
3. Copy the help file into the adohelp subfolder of your PERSONAL folder.
4. Restart Stata.

Usage:

    auto_recode_repeatgroup g1b4_5 g1b4oth_5
    help auto_recode_repeatgroup
