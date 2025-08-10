# auto_oth_nonre

**Auto-recode non-repeat group open-ended responses for Stata**

---

## Overview

`auto_oth_nonre` is a Stata program designed to simplify the coding of open-ended "Other" responses in survey data where answers are stored in a non-repeat group structure.

Given a numeric variable (`mainvar`) with coded responses and an associated open-ended text variable (`othvar`) capturing "Other" details, this program:

- Identifies frequent open-ended responses (those appearing in 20% or more of non-missing cases),
- Creates new dummy variables for these common responses starting at code 1001,
- Updates the numeric main variable codes accordingly,
- Clears matched text from the open-ended variable to avoid duplication.

---

## Why use `auto_oth_nonre`?

Manual coding of open-ended survey responses is time-consuming and error-prone, especially when dealing with "Other" categories in non-repeat groups. This tool automates the process, improving coding consistency and data quality with minimal effort.

---

## Installation

You can install the package directly from GitHub within Stata:

```stata
net install auto_oth_nonre, from("https://raw.githubusercontent.com/ashikpydev/auto_oth_nonre/main")
