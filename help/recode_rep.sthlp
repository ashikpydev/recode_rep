{smcl}
{* *! version 1.0.0 10aug2025}
{cmd:help recode_rep}

{hline}
{title:Title}

    {cmd:recode_rep} — Automatically recode repeat group variables

{hline}
{title:Syntax}

    {cmd:recode_rep} {it:mainvar} {it:splitvar} {it:othvar}

{hline}
{title:Description}

    {cmd:recode_rep} processes repeat group survey variables by automatically
    recoding the "Other specify" responses in multiple related variables.

    It scans the open-ended "Other specify" variable {it:othvar} linked to
    a set of split variables {it:splitvar} and the main variable {it:mainvar},
    then recodes the data accordingly to clean and harmonize responses.

    This is especially useful in repeat group data where respondents can
    select multiple options plus specify others in text form.

{hline}
{title:Example}

    . {cmd:recode_rep} g1b4 g1b4_5 g1b4oth_5

{hline}
{title:Author}

    Ashiqur Rahman Rony  
    Data Analyst, Development Research Initiative (dRi)  
    Email: ashiqur.rahman@dri-int.org  
    Alternate: ashiqurrahman.stat@gmail.com

{hline}
{title:Version}

    1.0.0 — 10 August 2025

{hline}
