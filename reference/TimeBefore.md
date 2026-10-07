# A condition that holds until a time of day

The `time_before` trigger of a plan: until a time of day on the
instrument's next trading day.

On its own it holds at once, so it is meant for `AllConditions`, where
it keeps another condition to the part of the day before the time.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `TimeBefore`

## Public fields

- `time`:

  The character time of day, such as `15:00`.

## Methods

### Public methods

- [`TimeBefore$new()`](#method-TimeBefore-initialize)

- [`TimeBefore$document()`](#method-TimeBefore-document)

- [`TimeBefore$clone()`](#method-TimeBefore-clone)

------------------------------------------------------------------------

### `TimeBefore$new()`

Initialises the condition with its time of day.

#### Usage

    TimeBefore$new(time)

#### Arguments

- `time`:

  The character time of day in India, such as `15:00`.

#### Returns

A new `TimeBefore` object.

------------------------------------------------------------------------

### `TimeBefore$document()`

Builds the `time_before` condition UBI reads.

#### Usage

    TimeBefore$document()

#### Returns

A named list with the single key `time_before`, whose value is the
character time of day.

#### Examples

    print(TimeBefore$new("15:00")$document())

    condition <- AllConditions$new(
      list(
        TimeAfter$new("10:00"),
        TimeBefore$new("15:00"),
        PriceCrosses$new(level = 995.0)
      )
    )
    print(condition$document())

------------------------------------------------------------------------

### `TimeBefore$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TimeBefore$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- TimeBefore$new("15:00")
document <- condition$document()
} # }

## ------------------------------------------------
## Method `TimeBefore$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
print(TimeBefore$new("15:00")$document())

condition <- AllConditions$new(
  list(
    TimeAfter$new("10:00"),
    TimeBefore$new("15:00"),
    PriceCrosses$new(level = 995.0)
  )
)
print(condition$document())
} # }
```
