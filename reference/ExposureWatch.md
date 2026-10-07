# One watched instrument and how much exposure each unit of its position carries

One instrument whose position counts towards the exposure an
`ExposureHedgeOrder` keeps inside a band.

## Public fields

- `instrument`:

  The `Instrument` whose net position is counted.

- `exposure_per_unit`:

  The numeric exposure one unit of the position carries, or `NULL` to
  let UBI count 1.

## Methods

### Public methods

- [`ExposureWatch$new()`](#method-ExposureWatch-initialize)

- [`ExposureWatch$document()`](#method-ExposureWatch-document)

- [`ExposureWatch$clone()`](#method-ExposureWatch-clone)

------------------------------------------------------------------------

### `ExposureWatch$new()`

Initialises the watch.

#### Usage

    ExposureWatch$new(instrument, exposure_per_unit = NULL)

#### Arguments

- `instrument`:

  The `Instrument` whose net position is counted.

- `exposure_per_unit`:

  The numeric exposure one unit carries, such as an option's delta, or
  `NULL` to let UBI count 1.

#### Returns

A new `ExposureWatch` object.

------------------------------------------------------------------------

### `ExposureWatch$document()`

Builds the watched object UBI reads.

#### Usage

    ExposureWatch$document()

#### Returns

A named list with `instrument_id`, and `exposure_per_unit` when it is
set.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    watch <- ExposureWatch$new(share)
    print(watch$document())

    first_share <- Equity$new(exchange = "nse", symbol = "IDEA")
    second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    watches <- list(
      ExposureWatch$new(first_share, exposure_per_unit = 1.2),
      ExposureWatch$new(second_share, exposure_per_unit = 0.8)
    )
    for (watch in watches) {
      print(watch$document())
    }

------------------------------------------------------------------------

### `ExposureWatch$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ExposureWatch$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
watch <- ExposureWatch$new(nifty_call, exposure_per_unit = 0.5)
document <- watch$document()
} # }

## ------------------------------------------------
## Method `ExposureWatch$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
watch <- ExposureWatch$new(share)
print(watch$document())

first_share <- Equity$new(exchange = "nse", symbol = "IDEA")
second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
watches <- list(
  ExposureWatch$new(first_share, exposure_per_unit = 1.2),
  ExposureWatch$new(second_share, exposure_per_unit = 0.8)
)
for (watch in watches) {
  print(watch$document())
}
} # }
```
