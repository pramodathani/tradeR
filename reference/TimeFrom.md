# A condition that holds from a time of day onwards, and at once when that time has already passed today

The `time_from` trigger of a plan: from a time of day onwards, starting
at once when that time has already passed today.

It differs from `time_at` and `time_after` only in what happens to a
time already passed on a trading day. Those two refuse such a time when
the plan is placed, while `time_from` holds at once, so an order placed
inside its window starts straight away rather than being refused. A time
not yet reached today, or any time on a weekend or holiday, waits for
that time on the instrument's next trading day, as `time_at` does.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `TimeFrom`

## Public fields

- `time`:

  The character time of day, such as `15:00`.

## Methods

### Public methods

- [`TimeFrom$new()`](#method-TimeFrom-initialize)

- [`TimeFrom$document()`](#method-TimeFrom-document)

- [`TimeFrom$clone()`](#method-TimeFrom-clone)

------------------------------------------------------------------------

### `TimeFrom$new()`

Initialises the condition with its time of day.

#### Usage

    TimeFrom$new(time)

#### Arguments

- `time`:

  The character time of day in India, such as `15:00` or `09:20:30`.

#### Returns

A new `TimeFrom` object.

------------------------------------------------------------------------

### `TimeFrom$document()`

Builds the `time_from` condition UBI reads.

#### Usage

    TimeFrom$document()

#### Returns

A named list with the single key `time_from`, whose value is the
character time of day.

#### Examples

    print(TimeFrom$new("15:00")$document())

    part <- OrderPart$new(
      trigger = TimeFrom$new("09:20"),
      pricing = MarketablePricing$new()
    )
    print(part$document())

------------------------------------------------------------------------

### `TimeFrom$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TimeFrom$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- TimeFrom$new("15:00")
document <- condition$document()
} # }

## ------------------------------------------------
## Method `TimeFrom$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
print(TimeFrom$new("15:00")$document())

part <- OrderPart$new(
  trigger = TimeFrom$new("09:20"),
  pricing = MarketablePricing$new()
)
print(part$document())
} # }
```
