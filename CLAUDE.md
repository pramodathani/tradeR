# CLAUDE.md

This file guides Claude Code when working in this repository.

## What this project is

`tradeR` is an R package that is a native port of the sibling Python library `tradingmachine` in `/home/pramod/Projects/tradingmachine`. The user chose on 2026-10-07 to rewrite the library in R rather than call the Python version through reticulate, and to port all of it.

The Python library is the specification. Its source in `src/tradingmachine/`, its `CLAUDE.md`, and its sidecar notes in `.claude/notes/src/tradingmachine/` record what every class does and why. When porting a Python file, read its code, its docstrings and its sidecar note first, and keep the behaviour the same unless this file says otherwise.

Like the Python library, nothing here talks to a broker. Every request goes to the sibling project `unified_broker_interface` (UBI), a REST service on `127.0.0.1:8080`, which speaks to ten Indian retail brokers.

## Safety rules

This package places real orders with real money, exactly as the Python library does.

- During development, never call a method that places, modifies or cancels an order against the live UBI unless it is a dry run, with `dry_run = TRUE`. Never call `flatten`, the holdings methods, `rebalance` or `place_orders` against the live UBI.
- Every connection to UBI replaces UBI's single access token and logs out every other client, including a running Python script. Ask the user before connecting to the live UBI.
- Tests use mocked HTTP responses through `httr2::local_mocked_responses()`, so `devtools::test()` never reaches UBI.

## Mapping Python to R

The table below lists how each Python construct is written in this package.

| Python | R |
|---|---|
| A class | An R6 class from `R6::R6Class()`, with the same name |
| An instance attribute, such as `instrument_id` | A public field |
| A `@property` | An active binding in `active = list(...)`, which raises an error when assigned to |
| A method | A public method with the same name and the same arguments in the same order |
| A protected method `_name` | A private method `name`, without the underscore |
| A `@classmethod` or `@staticmethod` that is public, such as `Equity.search` | A function stored on the class generator after the class is defined, such as `Equity$search <- function(...)`, written out for each class that has it, because R6 generators do not inherit these |
| A protected class method shared by many classes, such as `Instrument._search_catalogue` | A method on a small helper R6 class, such as `InstrumentCatalogue` |
| Multiple inheritance of the analysis mixins | A single chain of R6 classes, each analysis class inheriting the previous one, with `Instrument` inheriting the last |
| `None` | `NULL` for a single value, and `NA` inside a data frame column |
| `dict` returned to the caller | A named list |
| `list` of values | An atomic vector when every element is a scalar of one type, otherwise a list |
| `pandas.DataFrame`, or None when there are no rows | A base `data.frame`, or `NULL` when there are no rows |
| A nested dictionary inside a row, such as a position's `pnl` | A list column of the data frame |
| `datetime.date` | `Date` |
| A timezone-aware `datetime` | `POSIXct` with the time zone `Asia/Kolkata` |
| `decimal.Decimal` | `numeric` |
| An exception class | An R condition whose class vector is the Python class name followed by every Python parent class, then `error` and `condition`, so `tryCatch(..., NotFoundError = ...)` and `tryCatch(..., UnifiedBrokerInterfaceError = ...)` both work |
| `raise SomeError(message)` | `ErrorCatalogue$raise("SomeError", message)` |
| `__repr__` | A `format()` method returning the same text, and a `print()` method that prints it |
| `__eq__` | An `equals(other)` method |
| A module-level constant | A package-level constant in `ALL_CAPS`, prefixed with the file's topic whenever the bare name could clash, such as `EQUITIES_SEARCH_LIMIT` |

A Python call translates to R with `.` replaced by `$` and the same argument names:

```r
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$prices(days = 365)
strength <- infosys$relative_strength_index(window = 14, days = 365)
spread <- infosys$bid_offer_spread
```

## Where files go

R packages keep all code in one flat `R/` directory, so the Python package path becomes a file name prefix joined with underscores. `src/tradingmachine/assets/equities.py` becomes `R/assets_equities.R`, and `src/tradingmachine/orders/plan_parts/order_part.py` becomes `R/orders_plan_parts_order_part.R`. A test for `R/assets_equities.R` lives in `tests/testthat/test-assets_equities.R`.

The sidecar note for `R/assets_equities.R` is `.claude/notes/R/assets_equities.R.md`.

## Code style

The user's global rules in `~/.claude/CLAUDE.md` apply to R code too, with the R-specific choices below.

- Follow the tidyverse style guide: `snake_case` names, `<-` for assignment, double quotes, two-space indentation and lines of at most 80 characters, except that a sentence in a documentation line or a string is never split across lines.
- Spell every identifier out in full, as the user's rules require: `unified_broker_interface`, never `ubi`; `error`, never `e`; `index`, never `i`.
- Put every element of a `list()` or `c()` literal with more than one element on its own line, with the closing parenthesis on its own line.
- Write no explanatory comments in code. Reasoning, trade-offs and history go in the sidecar note.
- Write simple R that someone with a year of R could follow. Prefer a `for` loop, an explicit `if` and a named local variable over `Reduce`, `do.call` tricks, functional programming helpers, non-standard evaluation or clever one-liners. Use base R plus the packages in `DESCRIPTION`; do not add the tidyverse.
- Behaviour lives in R6 classes. Avoid free-standing functions; the functions stored on class generators are the one exception, because they stand in for Python class methods.
- Return the same columns, in the same order, as the Python version returns.

## Documentation

Every class, field, active binding and method has roxygen2 documentation, the R equivalent of the user's mandatory docstrings.

- The class block has a title line, a `@description`, and `@export`.
- Each public method is preceded by `#' @description`, one `#' @param` per argument giving its type and meaning, `#' @return` giving the type and meaning of the value, and, when the method can signal an error, a `#' @details` paragraph that starts `Errors:` and names each condition class and when it is signalled.
- Each active binding is preceded by a `#' @field` line naming it and describing the value and its type.
- Private methods get the same documentation, with the same tags, written with a plain `#` rather than `#'`. Roxygen has no place for private R6 members: a tagged `#'` block there produces a "can't find matching R6 method" warning, and an untagged one is joined onto the previous public method's page. A `#` block is the R form of a private method's docstring, so it is not an explanatory comment under the user's rule. `devtools::document()` runs with no warnings, and a new warning is worth reading.
- The Python docstrings carry `Examples:` sections; the R port carries `#' @examples` with the code wrapped in `\dontrun{}`, because every example needs the live UBI.

`NAMESPACE` and `man/` are generated by `devtools::document()` and committed. Do not run it while other work is in progress in parallel, because it rewrites them.

## Checking work

```bash
Rscript -e 'devtools::load_all(); devtools::test()'
Rscript -e 'lintr::lint_package()'
```
