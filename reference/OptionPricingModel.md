# The mechanism every pricing model here shares: the normal distribution and the search for an implied volatility

`BlackScholes` prices an option from its underlying's price and
`Black76` from a forward price, such as a future's. Each holds one
option's inputs and reports its fair price and its five greeks as
read-only fields, and each has an `implied_volatility()` function on its
class generator that finds the volatility at which the model reproduces
a premium seen in the market. `Option` uses Black-76 when the option's
underlying is a future and Black-Scholes otherwise, and the models can
be used on their own with any figures.

The models assume no dividends and a European option, one exercised only
at expiry. Theta is given per calendar day, and vega and rho per
percentage point, which is how brokers' option chains show them.

A subclass takes the price it models from, the strike, the time to
expiry, the rate, the volatility and the side, in that order, keeps the
volatility in a public `volatility` field, and reports `price` and the
greeks as active bindings. This class needs nothing else from it, so the
search works for any model that follows that shape.

## Methods

### Public methods

- [`OptionPricingModel$search_volatility()`](#method-OptionPricingModel-search_volatility)

- [`OptionPricingModel$clone()`](#method-OptionPricingModel-clone)

------------------------------------------------------------------------

### `OptionPricingModel$search_volatility()`

Finds the volatility at which this model's price equals a premium,
keeping every other input of this model.

The search halves the range from `OPTION_PRICING_LOWEST_VOLATILITY` to
`OPTION_PRICING_HIGHEST_VOLATILITY` for `OPTION_PRICING_SEARCH_STEPS`
rounds, which is far finer than any premium's tick. A premium outside
the prices the model gives at the two ends of that range has no
volatility to find, which happens when the premium is below the option's
discounted intrinsic value or implausibly high. The class generator
functions `BlackScholes$implied_volatility()` and
`Black76$implied_volatility()` build the model and call this.

#### Usage

    OptionPricingModel$search_volatility(premium)

#### Arguments

- `premium`:

  The numeric price the option trades at.

#### Returns

The numeric annual volatility, such as 0.12 for 12 per cent, or `NULL`
when the premium is not above zero or lies outside the prices the model
can give.

------------------------------------------------------------------------

### `OptionPricingModel$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OptionPricingModel$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
model <- BlackScholes$new(
  underlying_price = 24000,
  strike_price = 24100,
  years_to_expiry = 7 / 365,
  risk_free_rate = 0.065,
  volatility = 0.12,
  is_call = TRUE
)
model$price
#> [1] 126.7939
model$delta
#> [1] 0.4337297

BlackScholes$implied_volatility(
  premium = 150,
  reference_price = 24000,
  strike_price = 24100,
  years_to_expiry = 7 / 365,
  risk_free_rate = 0.065,
  is_call = TRUE
)
#> [1] 0.1377121
```
