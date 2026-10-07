# A condition that holds when a bar UBI builds from its own ticks closes past a level

The `candle_closes` trigger of a plan: a whole bar closing past a level,
rather than any tick touching it.

UBI builds the bars itself from the last traded price it sees, aligned
to the clock and `bar_minutes` long, 5 minutes by default. The condition
answers once per bar, at its close, so a wick through the level does not
count, and nothing is known until the first bar after the order rests
has closed. With no direction, a position opened with a buy waits for a
close at or below the level and one opened with a sell for a close at or
above it, which is a stop's meaning.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `CandleCloses`

## Public fields

- `level`:

  The numeric level in rupees that a close must reach.

- `direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` to
  take it from the side that opened the position.

- `bar_minutes`:

  The numeric length of one bar in minutes, or `NULL` for UBI's default
  of 5.

## Methods

### Public methods

- [`CandleCloses$new()`](#method-CandleCloses-initialize)

- [`CandleCloses$document()`](#method-CandleCloses-document)

- [`CandleCloses$clone()`](#method-CandleCloses-clone)

------------------------------------------------------------------------

### `CandleCloses$new()`

Initialises the condition with its level and settings.

#### Usage

    CandleCloses$new(level, direction = NULL, bar_minutes = NULL)

#### Arguments

- `level`:

  The numeric level in rupees, above zero.

- `direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` for
  a long to wait for a close at or below the level and a short for one
  at or above it.

- `bar_minutes`:

  The numeric length of one bar in minutes, above zero, or `NULL` for
  UBI's default of 5.

#### Returns

A new `CandleCloses` object.

------------------------------------------------------------------------

### `CandleCloses$document()`

Builds the `candle_closes` condition UBI reads, holding every setting
that is not `NULL`.

#### Usage

    CandleCloses$document()

#### Returns

A named list with the single key `candle_closes`, whose value holds
`level` and each other setting that is set.

#### Examples

    condition <- CandleCloses$new(level = 995.0)
    print(condition$document())

    condition <- CandleCloses$new(
      level = 1010.0,
      direction = "at_or_above",
      bar_minutes = 15
    )
    print(condition$document())

    part <- OrderPart$new(
      side = "protect",
      trigger = CandleCloses$new(level = 990.0),
      pricing = MarketablePricing$new()
    )
    print(part$document())

------------------------------------------------------------------------

### `CandleCloses$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CandleCloses$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- CandleCloses$new(level = 995.0, bar_minutes = 15)
document <- condition$document()
} # }

## ------------------------------------------------
## Method `CandleCloses$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
condition <- CandleCloses$new(level = 995.0)
print(condition$document())

condition <- CandleCloses$new(
  level = 1010.0,
  direction = "at_or_above",
  bar_minutes = 15
)
print(condition$document())

part <- OrderPart$new(
  side = "protect",
  trigger = CandleCloses$new(level = 990.0),
  pricing = MarketablePricing$new()
)
print(part$document())
} # }
```
