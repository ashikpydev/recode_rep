{smcl}
{* *! version 1.0.0 10aug2025}{...}
{cmd:help recode_rep}

{hline}
{title:Title}

    {cmd:recode_rep} — Auto-recode non-repeat group open-ended responses

{hline}
{title:Syntax}

    {cmd:recode_rep} {it:mainvar} {it:othvar}

{hline}
{title:Description}

    {cmd:recode_rep} scans the open-ended variable {it:othvar} for
    frequent responses (those appearing in 20% or more of observations).
    It then creates new dummy variables for these common responses,
    updates the numeric codes in {it:mainvar} accordingly, and clears
    matched text from {it:othvar}.

    This is useful for coding "Other" responses in non-repeat groups,
    where a single variable {it:mainvar} stores codes and
    {it:othvar} stores open-ended text responses.

    The program assumes the numeric code 97 is reserved for "Other" responses
    and starts creating new dummy variables with codes beginning at 1001.

{hline}
{title:Example}

    . {cmd:recode_rep g1b4 g1b4oth}

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
