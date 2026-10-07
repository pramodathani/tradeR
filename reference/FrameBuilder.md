# A converter between UBI's rows and R data frames

UBI answers with lists of JSON objects, which `jsonlite` parses into
lists of named lists. This class turns such a list into a base
`data.frame` the way `pandas.DataFrame(rows)` does in the Python
library: every field any row has becomes a column, in the order the
fields are first seen, a missing or null value becomes `NA`, a field
whose values are all single numbers, strings or logicals becomes an
ordinary column, and any other field, such as a position's `pnl` object
or an order book's levels, becomes a list column whose elements are the
original values.

It also turns one row of a data frame back into a named list, which is
how the Python code's `frame.to_dict("records")` loops are written in R.

## Methods

### Public methods

- [`FrameBuilder$frame()`](#method-FrameBuilder-frame)

- [`FrameBuilder$column()`](#method-FrameBuilder-column)

- [`FrameBuilder$row()`](#method-FrameBuilder-row)

- [`FrameBuilder$rows()`](#method-FrameBuilder-rows)

- [`FrameBuilder$clone()`](#method-FrameBuilder-clone)

------------------------------------------------------------------------

### `FrameBuilder$frame()`

Builds a data frame from a list of rows.

#### Usage

    FrameBuilder$frame(rows)

#### Arguments

- `rows`:

  A list of named lists, one per row.

#### Returns

A `data.frame` with one row per element of `rows`, or `NULL` when `rows`
is `NULL` or empty.

------------------------------------------------------------------------

### `FrameBuilder$column()`

Builds one column from the values of one field, one value per row.

#### Usage

    FrameBuilder$column(values)

#### Arguments

- `values`:

  A list with one element per row, where `NULL` marks a missing value.

#### Returns

An atomic vector with `NA` for missing values when every present value
is a single number, string or logical, otherwise a list with `NULL` for
missing values.

------------------------------------------------------------------------

### `FrameBuilder$row()`

Turns one row of a data frame back into a named list, the R counterpart
of one record from `frame.to_dict("records")`.

#### Usage

    FrameBuilder$row(frame, row_index)

#### Arguments

- `frame`:

  A `data.frame`.

- `row_index`:

  An integer row number.

#### Returns

A named list with one element per column, where a list column gives its
element for that row and an atomic column gives its value, `NA`
included.

------------------------------------------------------------------------

### `FrameBuilder$rows()`

Turns every row of a data frame into a named list.

#### Usage

    FrameBuilder$rows(frame)

#### Arguments

- `frame`:

  A `data.frame`, or `NULL`.

#### Returns

A list of named lists, one per row, or an empty list when `frame` is
`NULL`.

------------------------------------------------------------------------

### `FrameBuilder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    FrameBuilder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
builder <- FrameBuilder$new()
frame <- builder$frame(
  list(
    list(symbol = "INFY", quantity = 10, pnl = list(realized = 5)),
    list(symbol = "TCS", quantity = NULL, pnl = list(realized = 7))
  )
)
frame$quantity
#> [1] 10 NA
frame$pnl[[2]]$realized
#> [1] 7
```
