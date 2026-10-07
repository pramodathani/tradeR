# The errors that stand in for Python's built-in exceptions

The Python library raises some of Python's own exception classes, such
as `ValueError` for an argument outside its allowed range. The R port
signals conditions with the same names, so the documentation and the
handlers read the same in both languages.

## Usage

``` r
UTILITIES_LANGUAGE_ERROR_PARENTS
```

## Format

A named character vector, one entry per error class:

- `ValueError`:

  An argument has the right type but a value the method cannot use, such
  as a price that is not above zero.

- `TypeError`:

  An argument has the wrong type, such as an underlying that is not an
  `Instrument`.

- `KeyError`:

  A name was asked for that the data does not have, such as an unknown
  column passed to `Watchlist$rank_by()`.

- `NotImplementedError`:

  A base class method that only a subclass can supply was called on the
  base class, such as `PlanPart$document()`.
