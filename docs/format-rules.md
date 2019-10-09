# Code formatting rules for catlearn

## Rationale

Code should be readable, and this means adopting a standard format for all
contributions. catlearn uses version control for development, so correcting
deviations from these rules leaves the commit log full of formatting changes,
which makes it harder to track substantive changes. Please ensure your code
meets these style rules before commiting it to the catlearn github repo.

## Rules

Maximum line length: 79 characters

Indentation: Loops, functions, etc, should indent by four spaces per level.

Use spaces: Spaces should appear 

- after commas
- before and after arithmetic expressions (e.g. +, -, /, *, =, ==)
- before and after assignment e.g. a <- b

Spaces should _not_ appear:

- before or after paranthesis - ( { [ ] } )
- before or after range operator (:)

Comments in R should use ## for a whole-line comment.
