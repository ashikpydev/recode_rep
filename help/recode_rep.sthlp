{smcl}
{* *! version 1.0.0 10aug2025}
{cmd:help recode_rep}

{hline}
{title:Title}

    {cmd:recode_rep} — Automatically recode repeat group variables with "Other specify" responses

{hline}
{title:Syntax}

    {cmd:recode_rep} {it:mainvar} {it:splitvar} {it:othvar}

{hline}
{title:Description}

    {cmd:recode_rep} is designed to help clean and recode repeat group survey variables, especially when respondents provide "Other specify" open-ended responses.

    This program:

    {bullet} Scans the open-ended variable {it:othvar} for common responses  
    {bullet} Links these to the main variable {it:mainvar} and the split group variables {it:splitvar}  
    {bullet} Automatically recodes and harmonizes the data by creating new numeric codes and dummy variables where needed  
    {bullet} Clears matched text from the {it:othvar} variable to avoid duplication  

    Use this to efficiently manage and analyze repeat group data with textual "Other" responses.

{hline}
{title:Example}

    To recode variables named {it:g1b4} (main), {it:g1b4_5} (split group), and {it:g1b4oth_5} (open-ended "Other specify"):

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
