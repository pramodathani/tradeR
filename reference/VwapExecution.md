# An execution that sends slices on a clock, each sized by the volume profile of the half hour it falls in

The `vwap` execution of a plan: slices sized by how busy the market
usually is, a volume-weighted average price order.

It sends `slices`, from 2 to 60, on the same clock as `TwapExecution`,
but each slice takes the weight of the half hour it falls in, so slices
near the busy open and close are bigger. The half hours are counted from
the segment's own open, 09:15 for equity and 09:00 for currency and MCX,
on the day the order starts working, and a slice after the last half
hour takes the last weight. `volume_profile` gives the weights, one per
half hour from the open; without it, an equity order takes UBI's NSE
equity shape and a currency or commodity order gets even slices. Slices
are whole lots, and a slice that comes to nothing is skipped.

The span is given in one of two ways: `over_minutes`, or `until`, a time
of day such as `"15:00"`, which spreads the slices from when the order
starts until that time and is refused if the order starts after it.
Giving both is refused. A VWAP can be the outer or the inner execution
of a nested pair, and cannot carry a resting stop.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `VwapExecution`

## Public fields

- `slices`:

  The integer number of slices, from 2 to 60.

- `over_minutes`:

  The numeric number of minutes the slices are spread across, or `NULL`
  when `until` is given.

- `until`:

  The character time of day, such as `15:00`, the slices end by, or
  `NULL` when `over_minutes` is given.

- `volume_profile`:

  The numeric vector of relative weights, one per half hour from the
  segment's open, or `NULL` for UBI's default.

## Methods

### Public methods

- [`VwapExecution$new()`](#method-VwapExecution-initialize)

- [`VwapExecution$document()`](#method-VwapExecution-document)

- [`VwapExecution$clone()`](#method-VwapExecution-clone)

------------------------------------------------------------------------

### `VwapExecution$new()`

Initialises the execution with its slices, its span and its profile.

#### Usage

    VwapExecution$new(
      slices,
      over_minutes = NULL,
      until = NULL,
      volume_profile = NULL
    )

#### Arguments

- `slices`:

  The integer number of slices, from 2 to 60.

- `over_minutes`:

  The numeric number of minutes the slices are spread across, or `NULL`
  when `until` is given.

- `until`:

  The character time of day in India, `HH:MM`, the slices end by, or
  `NULL` when `over_minutes` is given.

- `volume_profile`:

  A numeric vector of relative weights at or above zero, one per half
  hour from the segment's open, or `NULL` for UBI's NSE equity shape on
  equity and even slices elsewhere.

#### Returns

A new `VwapExecution` object.

------------------------------------------------------------------------

### `VwapExecution$document()`

Builds the `vwap` execution object UBI reads.

#### Usage

    VwapExecution$document()

#### Returns

A named list with the single key `vwap`, whose value holds `slices`,
whichever of `over_minutes` and `until` is set, and `volume_profile`
when it is set.

#### Examples

    execution <- VwapExecution$new(slices = 10, over_minutes = 90)
    print(execution$document())

    execution <- VwapExecution$new(slices = 12, until = "15:00")
    print(execution$document())

    part <- OrderPart$new(
      execution = VwapExecution$new(
        slices = 8,
        over_minutes = 120,
        volume_profile = list(
          3.0,
          2.0,
          1.5,
          1.0
        )
      ),
      inner_execution = IcebergExecution$new(
        visible_quantity = 20
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `VwapExecution$clone()`

The objects of this class are cloneable with this method.

#### Usage

    VwapExecution$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
execution <- VwapExecution$new(slices = 10, until = "15:00")
part <- OrderPart$new(execution = execution)
document <- part$document()
} # }

## ------------------------------------------------
## Method `VwapExecution$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
execution <- VwapExecution$new(slices = 10, over_minutes = 90)
print(execution$document())

execution <- VwapExecution$new(slices = 12, until = "15:00")
print(execution$document())

part <- OrderPart$new(
  execution = VwapExecution$new(
    slices = 8,
    over_minutes = 120,
    volume_profile = list(
      3.0,
      2.0,
      1.5,
      1.0
    )
  ),
  inner_execution = IcebergExecution$new(
    visible_quantity = 20
  )
)
print(part$document())
} # }
```
