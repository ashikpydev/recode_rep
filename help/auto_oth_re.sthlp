{smcl}
{* *! version 1.0.0 10aug2025}{...}
{cmd:help auto_oth_re}

{hline}
{title:Title}

    {cmd:auto_oth_re} — Auto-recodes repeat-group open-ended responses

{hline}
{title:Syntax}

    {cmd:auto_oth_re} {it:mainvar} {it:othvar}

{hline}
{title:Description}

    {cmd:auto_oth_re} searches for common open-ended responses
    (>= 20% frequency), creates new dummy variables for them, updates
    {it:mainvar} codes, and clears matched text in {it:othvar}.

    It assumes a "repeat group" structure such as {it:g1b4_5} / {it:g1b4oth_5}
    and uses the {it:_97_} code slot for "Other".

{hline}
{title:Example}

    . {cmd:auto_oth_re g1b4_5 g1b4oth_5}

{hline}
{title:Author}

    Ashiqur Rahman Rony
    Data Analyst, Development Research Initiative (dRi)
    Email: ashiqur.rahman@dri-int.org (ashiqurrahman.stat@gmail.com)

{hline}
{title:Version}

    1.0.0 — 10 Aug 2025

{hline}
