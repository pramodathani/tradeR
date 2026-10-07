# A condition that holds from a time of day onwards

The `time_after` trigger of a plan: from a time of day onwards on the
instrument's next trading day.

It holds exactly as `time_at` does, and reads better inside
`AllConditions`, where it keeps another condition to the part of the day
after the time.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `TimeAfter`

## Public fields

- `time`:

  The character time of day, such as `09:30`.

## Methods

### Public methods

- [`TimeAfter$new()`](#method-TimeAfter-initialize)

- [`TimeAfter$document()`](#method-TimeAfter-document)

- [`TimeAfter$clone()`](#method-TimeAfter-clone)

------------------------------------------------------------------------

### `TimeAfter$new()`

Initialises the condition with its time of day.

#### Usage

    TimeAfter$new(time)

#### Arguments

- `time`:

  The character time of day in India, such as `09:30`.

#### Returns

A new `TimeAfter` object.

------------------------------------------------------------------------

### `TimeAfter$document()`

Builds the `time_after` condition UBI reads.

#### Usage

    TimeAfter$document()

#### Returns

A named list with the single key `time_after`, whose value is the
character time of day.

#### Examples

    print(TimeAfter$new("09:30")$document())

    condition <- AllConditions$new(
      list(
        TimeAfter$new("09:30"),
        PriceCrosses$new(level = 995.0)
      )
    )
    print(condition$document())

------------------------------------------------------------------------

### `TimeAfter$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TimeAfter$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- TimeAfter$new("09:30")
document <- condition$document()
} # }

## ------------------------------------------------
## Method `TimeAfter$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
print(TimeAfter$new("09:30")$document())

condition <- AllConditions$new(
  list(
    TimeAfter$new("09:30"),
    PriceCrosses$new(level = 995.0)
  )
)
print(condition$document())
} # }
```
