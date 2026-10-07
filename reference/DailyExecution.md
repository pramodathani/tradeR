# An execution that sends the order again at a set time each trading day until anything trades

The `daily` execution of a plan: the order sent again each trading
morning, for an order the exchange ends at the close.

A native stop dies at the close, so a position held for a week needs a
new one every morning. This sends the whole order each trading day at
`arm_at`, `09:20` by default, after the pre-open has settled, and not on
a day the instrument does not trade. A plan placed after that time on a
trading day first sends on the next trading morning. Once anything has
traded no more is sent, and since UBI's fix of 2026-10-02 a stop that
has traded completes the order rather than being sent again the next
morning.

It is one of only two executions a resting stop may have, the other
being `AllAtOnceExecution`, because renewing a stop each day still
protects the whole position at once while splitting it would not. Pair
it with a `Lifetime` in `after_days`, which ends it and keeps the plan
across days. It does not nest.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `DailyExecution`

## Public fields

- `arm_at`:

  The character time of day in India, `HH:MM`, to send at, or `NULL` for
  UBI's default of `09:20`.

## Methods

### Public methods

- [`DailyExecution$new()`](#method-DailyExecution-initialize)

- [`DailyExecution$document()`](#method-DailyExecution-document)

- [`DailyExecution$clone()`](#method-DailyExecution-clone)

------------------------------------------------------------------------

### `DailyExecution$new()`

Initialises the execution with the time it sends at.

#### Usage

    DailyExecution$new(arm_at = NULL)

#### Arguments

- `arm_at`:

  The character time of day in India, `HH:MM`, to send at each trading
  day, or `NULL` for UBI's default of `09:20`.

#### Returns

A new `DailyExecution` object.

------------------------------------------------------------------------

### `DailyExecution$document()`

Builds the `daily` execution object UBI reads.

#### Usage

    DailyExecution$document()

#### Returns

A named list with the single key `daily`, whose value holds `arm_at`
when it is set and is otherwise empty.

#### Examples

    execution <- DailyExecution$new()
    print(execution$document())

    part <- OrderPart$new(
      side = "protect",
      pricing = NativeStopPricing$new(
        trigger_price = 950.0,
        limit_price = 948.0
      ),
      execution = DailyExecution$new(arm_at = "09:30")
    )
    print(part$document())

------------------------------------------------------------------------

### `DailyExecution$clone()`

The objects of this class are cloneable with this method.

#### Usage

    DailyExecution$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
execution <- DailyExecution$new()
part <- OrderPart$new(execution = execution)
document <- part$document()
} # }

## ------------------------------------------------
## Method `DailyExecution$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
execution <- DailyExecution$new()
print(execution$document())

part <- OrderPart$new(
  side = "protect",
  pricing = NativeStopPricing$new(
    trigger_price = 950.0,
    limit_price = 948.0
  ),
  execution = DailyExecution$new(arm_at = "09:30")
)
print(part$document())
} # }
```
