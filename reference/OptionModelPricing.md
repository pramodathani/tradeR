# A pricing rule that prices an option from an implied volatility and its underlying

The `option_model` pricing rule of a plan: an option's premium worked
out from an implied volatility and kept current as the underlying moves.

UBI prices the order's option with the Black-76 model at the stated
`volatility`, reading the option's strike, expiry and kind from its
catalogue when the plan is placed, and re-prices it as the underlying
moves and expiry nears. When the underlying is a future it is the
forward; otherwise, as for the index, the spot is grown by
`interest_rate` to expiry. The template's own price is the worst the
order accepts, and the bounds and the step work as they do for
`FollowInstrumentPricing`. An order whose instrument is not an option is
refused.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `OptionModelPricing`

## Public fields

- `instrument`:

  The `Instrument` that is the option's underlying, sent as its
  `instrument_id`.

- `volatility`:

  The numeric implied volatility as a percentage, above zero and at most
  500.

- `interest_rate`:

  The numeric yearly interest rate as a percentage, or `NULL` for UBI's
  default of 0.

- `lowest`:

  The numeric lowest price the order goes to, or `NULL` for no floor.

- `highest`:

  The numeric highest price the order goes to, or `NULL` for no ceiling.

- `step_ticks`:

  The integer smallest move worth sending, in ticks, or `NULL` for UBI's
  default of 1.

## Methods

### Public methods

- [`OptionModelPricing$new()`](#method-OptionModelPricing-initialize)

- [`OptionModelPricing$document()`](#method-OptionModelPricing-document)

- [`OptionModelPricing$clone()`](#method-OptionModelPricing-clone)

------------------------------------------------------------------------

### `OptionModelPricing$new()`

Initialises the rule with the underlying, the volatility and its
settings.

#### Usage

    OptionModelPricing$new(
      instrument,
      volatility,
      interest_rate = NULL,
      lowest = NULL,
      highest = NULL,
      step_ticks = NULL
    )

#### Arguments

- `instrument`:

  The `Instrument` that is the option's underlying, such as the index or
  a future on it.

- `volatility`:

  The numeric implied volatility as a percentage, such as 14.0 for 14%,
  above zero and at most 500.

- `interest_rate`:

  The numeric yearly interest rate as a percentage, used to grow a spot
  underlying to expiry, or `NULL` for UBI's default of 0.

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

A new `OptionModelPricing` object.

------------------------------------------------------------------------

### `OptionModelPricing$document()`

Builds the `option_model` pricing object UBI reads, holding every
setting that is not `NULL`.

#### Usage

    OptionModelPricing$document()

#### Returns

A named list with the single key `option_model`, whose value holds the
underlying as its `instrument_id`, `volatility`, and `interest_rate`,
`lowest`, `highest` and `step_ticks` when each is set.

#### Examples

    index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pricing <- OptionModelPricing$new(
      instrument = index,
      volatility = 14.0
    )
    print(pricing$document())

    index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pricing <- OptionModelPricing$new(
      instrument = index,
      volatility = 12.5,
      interest_rate = 6.5,
      lowest = 50.0,
      highest = 120.0,
      step_ticks = 2
    )
    print(pricing$document())

------------------------------------------------------------------------

### `OptionModelPricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptionModelPricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pricing <- OptionModelPricing$new(
  instrument = index,
  volatility = 14.0
)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `OptionModelPricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pricing <- OptionModelPricing$new(
  instrument = index,
  volatility = 14.0
)
print(pricing$document())

index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pricing <- OptionModelPricing$new(
  instrument = index,
  volatility = 12.5,
  interest_rate = 6.5,
  lowest = 50.0,
  highest = 120.0,
  step_ticks = 2
)
print(pricing$document())
} # }
```
