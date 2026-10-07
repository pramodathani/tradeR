# A pricing rule that moves a resting limit after another instrument

The `follow_instrument` pricing rule of a plan: a limit moved by how far
another instrument has moved since the order was sent.

The order starts at the template's own limit price, and from then on its
price is that start price plus `delta` times the followed instrument's
move, so a Nifty call bid with a delta of 0.5 rises by 20 when the index
rises by 40, without reading the option's own thin book. The price stays
between `lowest` and `highest`, never goes below one tick, and moves
only when it would move by at least `step_ticks`. The template must be a
limit order with a price, and the followed instrument must be another
one than the order's own.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `FollowInstrumentPricing`

## Public fields

- `instrument`:

  The `Instrument` followed, sent as its `instrument_id`.

- `delta`:

  The numeric number of rupees the price moves for each rupee the
  followed instrument moves.

- `lowest`:

  The numeric lowest price the order goes to, or `NULL` for no floor.

- `highest`:

  The numeric highest price the order goes to, or `NULL` for no ceiling.

- `step_ticks`:

  The integer smallest move worth sending, in ticks, or `NULL` for UBI's
  default of 1.

## Methods

### Public methods

- [`FollowInstrumentPricing$new()`](#method-FollowInstrumentPricing-initialize)

- [`FollowInstrumentPricing$document()`](#method-FollowInstrumentPricing-document)

- [`FollowInstrumentPricing$clone()`](#method-FollowInstrumentPricing-clone)

------------------------------------------------------------------------

### `FollowInstrumentPricing$new()`

Initialises the rule with the instrument it follows and its settings.

#### Usage

    FollowInstrumentPricing$new(
      instrument,
      delta,
      lowest = NULL,
      highest = NULL,
      step_ticks = NULL
    )

#### Arguments

- `instrument`:

  The `Instrument` to follow, usually an option's underlying, which must
  not be the order's own instrument.

- `delta`:

  The numeric number of rupees the price moves for each rupee the
  followed instrument moves, which may be negative, as for a put.

- `lowest`:

  The numeric lowest price in rupees the order goes to, or `NULL` for no
  floor.

- `highest`:

  The numeric highest price in rupees the order goes to, or `NULL` for
  no ceiling.

- `step_ticks`:

  The integer smallest move worth sending, in ticks, or `NULL` for UBI's
  default of 1.

#### Returns

A new `FollowInstrumentPricing` object.

------------------------------------------------------------------------

### `FollowInstrumentPricing$document()`

Builds the `follow_instrument` pricing object UBI reads, holding every
setting that is not `NULL`.

#### Usage

    FollowInstrumentPricing$document()

#### Returns

A named list with the single key `follow_instrument`, whose value holds
the followed instrument as its `instrument_id`, `delta`, and `lowest`,
`highest` and `step_ticks` when each is set.

#### Examples

    index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pricing <- FollowInstrumentPricing$new(
      instrument = index,
      delta = 0.5
    )
    print(pricing$document())

    index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pricing <- FollowInstrumentPricing$new(
      instrument = index,
      delta = -0.4,
      lowest = 80.0,
      highest = 150.0,
      step_ticks = 2
    )
    print(pricing$document())

------------------------------------------------------------------------

### `FollowInstrumentPricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    FollowInstrumentPricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pricing <- FollowInstrumentPricing$new(
  instrument = index,
  delta = 0.5
)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `FollowInstrumentPricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pricing <- FollowInstrumentPricing$new(
  instrument = index,
  delta = 0.5
)
print(pricing$document())

index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pricing <- FollowInstrumentPricing$new(
  instrument = index,
  delta = -0.4,
  lowest = 80.0,
  highest = 150.0,
  step_ticks = 2
)
print(pricing$document())
} # }
```
