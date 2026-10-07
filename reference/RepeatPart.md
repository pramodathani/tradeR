# One order sent a number of times, spaced by minutes or by trading days

The `repeat` join of a plan: one order sent again and again, on a timer
or once each trading day.

The child must be a plain `OrderPart`, not another join, and UBI sends
it `times` times, from 1 to 100. Exactly one of `every_minutes` and
`every_trading_day_at` must be given. With `every_minutes`, the first
copy goes at once and each later copy that many minutes after the one
before, counted from when the plan was placed. With
`every_trading_day_at`, each copy goes at that time on its own trading
day and the plan is kept across days. With `until`, a condition, every
copy still waiting is ended once the condition holds; the order then
takes no lifetime of its own. UBI also refuses, with the rule
`repeat_needs_order`, a child whose presets make it a join, such as a
`bracket`, and a child naming a type kept whole, such as a `grid`,
because either would place its orders at once rather than wait its turn.
A repeat join cannot be a `then` join's child.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `RepeatPart`

## Public fields

- `child`:

  The `PlanPart` `OrderPart` sent each time.

- `times`:

  The integer number of copies sent, from 1 to 100.

- `every_minutes`:

  The numeric minutes between one copy and the next, or `NULL` when
  `every_trading_day_at` is given.

- `every_trading_day_at`:

  The character time of day each copy is sent on its own trading day,
  such as `09:20`, or `NULL` when `every_minutes` is given.

- `until`:

  The `PlanPart` condition that ends every copy still waiting, or
  `NULL`.

## Methods

### Public methods

- [`RepeatPart$new()`](#method-RepeatPart-initialize)

- [`RepeatPart$document()`](#method-RepeatPart-document)

- [`RepeatPart$clone()`](#method-RepeatPart-clone)

------------------------------------------------------------------------

### `RepeatPart$new()`

Initialises the join with its order and schedule.

#### Usage

    RepeatPart$new(
      child,
      times,
      every_minutes = NULL,
      every_trading_day_at = NULL,
      until = NULL
    )

#### Arguments

- `child`:

  The `PlanPart` sent each time, which must be a plain `OrderPart`; UBI
  refuses a join here, and a preset that stands for a join or a type
  kept whole, with the rule `repeat_needs_order`.

- `times`:

  The integer number of copies, from 1 to 100.

- `every_minutes`:

  The numeric minutes above zero between copies, or `NULL` when
  `every_trading_day_at` is given.

- `every_trading_day_at`:

  The character time of day in India, such as `09:20`, at which each
  copy is sent on its own trading day, or `NULL` when `every_minutes` is
  given.

- `until`:

  A `PlanPart` condition, such as `PriceCrosses` or `TimeAt`, that ends
  every copy still waiting once it holds, or `NULL` to let every copy
  run.

#### Returns

A new `RepeatPart` object.

------------------------------------------------------------------------

### `RepeatPart$document()`

Builds the `repeat` node UBI reads.

#### Usage

    RepeatPart$document()

#### Returns

A named list with the single key `repeat`, whose value holds `child`,
`times`, and each of `every_minutes`, `every_trading_day_at` and `until`
that is not `NULL`.

#### Examples

    part <- RepeatPart$new(
      child = OrderPart$new(quantity = 10),
      times = 6,
      every_minutes = 30
    )
    print(part$document())

    part <- RepeatPart$new(
      child = OrderPart$new(
        pricing = MarketablePricing$new(buffer_ticks = 2)
      ),
      times = 5,
      every_trading_day_at = "09:20",
      until = PriceCrosses$new(
        level = 1050.0,
        direction = "at_or_above"
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `RepeatPart$clone()`

The objects of this class are cloneable with this method.

#### Usage

    RepeatPart$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- RepeatPart$new(
  child = OrderPart$new(quantity = 10),
  times = 6,
  every_minutes = 30
)
document <- part$document()
} # }

## ------------------------------------------------
## Method `RepeatPart$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- RepeatPart$new(
  child = OrderPart$new(quantity = 10),
  times = 6,
  every_minutes = 30
)
print(part$document())

part <- RepeatPart$new(
  child = OrderPart$new(
    pricing = MarketablePricing$new(buffer_ticks = 2)
  ),
  times = 5,
  every_trading_day_at = "09:20",
  until = PriceCrosses$new(
    level = 1050.0,
    direction = "at_or_above"
  )
)
print(part$document())
} # }
```
