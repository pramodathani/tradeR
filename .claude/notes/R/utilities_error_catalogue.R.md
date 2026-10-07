# R/utilities_error_catalogue.R

R has no exception classes, but its conditions carry a class vector, and `tryCatch()` matches a handler against any element of it. A condition whose class vector is the Python class followed by each Python ancestor therefore behaves like the Python exception: a handler for `InstrumentError` catches `EquityError`, and one for `UnifiedBrokerInterfaceError` catches `NotFoundError`.

## Where the hierarchy lives

The parents come from four tables, one per Python exceptions module plus one for Python's own built-in exceptions: `UTILITIES_LANGUAGE_ERROR_PARENTS` (`ValueError`, `TypeError`), `UNIFIED_BROKER_INTERFACE_ERROR_PARENTS`, `ASSETS_ERROR_PARENTS` and `ASSET_BASKETS_ERROR_PARENTS`. The three module tables were generated from the Python files on 2026-10-07 by a one-off script, so the names and descriptions match exactly. A new error class needs one line in the right table.

`ValueError` and `TypeError` were added so that the R documentation can name the same errors the Python docstrings name, rather than a vague "plain error".

## Why functions on the generator

`ErrorCatalogue$raise()` and `ErrorCatalogue$name_of()` are functions stored on the class generator, the pattern this package uses for Python class methods. Building the catalogue object reads the tables at call time, so the order R loads the files in does not matter.

## The parent field

`raise(..., parent = error)` stores the caught condition, the R counterpart of Python's `raise ... from error`, so the original UBI failure stays reachable from a family error such as `EquityError`.
