{smcl}
{* *! version 1.0.0 10aug2025}
{cmd:help recode_rep}

{hline}
{title:Title}

    {cmd:recode_rep} — Automatically recode "Other specify" responses in repeat group survey variables

{hline}
{title:Purpose}

    When working with primary survey data collected via tools like SurveyCTO, ODK, or KoBoToolbox, repeat groups are commonly used to capture multiple responses for a set of related questions.

    Inside these repeat groups, multiple-response variables are frequent, and often respondents provide open-ended "Other specify" answers.

    For data cleaning and analysis, these "Other specify" responses need to be recoded into numeric codes, which usually requires manual coding, creating new variables, and updating existing codes.

    This process is time-consuming, error-prone, and reduces efficiency.

    {txt:This program automates this process by:}
    {txt:- Detecting frequently occurring "Other specify" text responses (with frequency above a threshold, default 10%)}
    {txt:- Creating new dummy variables and numeric codes for these responses}
    {txt:- Updating the main and split variables accordingly}
    {txt:- Clearing the matched open-ended text to avoid duplication}

    This greatly speeds up data cleaning and improves accuracy.

{hline}
{title:Syntax}

    {cmd:recode_rep} {it:mainvar} {it:splitvar} {it:othvar}

    where:  
    {txt:mainvar = numeric coded variable in the repeat group}  
    {txt:splitvar = dummy variable for the "Other specify" category}  
    {txt:othvar = open-ended text variable containing "Other specify" responses}

{hline}
{title:Example}

    Suppose your dataset has these variables from a repeat group:

    {txt:- g1b4_5 = main coded variable}  
    {txt:- g1b4_97_5 = dummy for "Other specify" (code 97)}  
    {txt:- g1b4oth_5 = text responses for "Other specify"}

    To automatically recode frequent "Other specify" responses, run:

    . {cmd:recode_rep} g1b4_5 g1b4_97_5 g1b4oth_5

    The program will detect common text entries in {it:g1b4oth_5} (10% or more frequency),  
    create new dummy variables and codes for these, update {it:g1b4_5} and {it:g1b4_97_5},  
    and clear the matched text from {it:g1b4oth_5}.

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
