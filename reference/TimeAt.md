# A condition that holds from a time of day onwards

The `time_at` trigger of a plan: a time of day reached on the
instrument's next trading day.

UBI works the moment out once, when the plan is placed, so a time
already passed on a trading day is refused, and a weekend or holiday
rolls to the next trading day. It holds from that moment on, exactly as
`time_after` does; the two names exist so a plan reads naturally.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `TimeAt`

## Public fields

- `time`:

  The character time of day, such as `10:00`.

## Methods

### Public methods

- [`TimeAt$new()`](#method-TimeAt-initialize)

- [`TimeAt$document()`](#method-TimeAt-document)

- [`TimeAt$clone()`](#method-TimeAt-clone)

------------------------------------------------------------------------

### `TimeAt$new()`

Initialises the condition with its time of day.

#### Usage

    TimeAt$new(time)

#### Arguments

- `time`:

  The character time of day in India, such as `10:00` or `14:45`.

#### Returns

A new `TimeAt` object.

------------------------------------------------------------------------

### `TimeAt$document()`

Builds the `time_at` condition UBI reads.

#### Usage

    TimeAt$document()

#### Returns

A named list with the single key `time_at`, whose value is the character
time of day.

#### Examples

    print(TimeAt$new("10:00")$document())

    part <- OrderPart$new(trigger = TimeAt$new("14:45"))
    print(part$document())

------------------------------------------------------------------------

### `TimeAt$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TimeAt$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- TimeAt$new("10:00")
document <- condition$document()
} # }

## ------------------------------------------------
## Method `TimeAt$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
print(TimeAt$new("10:00")$document())

part <- OrderPart$new(trigger = TimeAt$new("14:45"))
print(part$document())
} # }
```
