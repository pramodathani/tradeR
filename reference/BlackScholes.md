# One European option priced by the Black-Scholes model without dividends

Holds one option's inputs and reports its fair price and its five
greeks. Theta is per calendar day, and vega and rho are per percentage
point.

The function
`BlackScholes$implied_volatility(premium, reference_price, strike_price, years_to_expiry, risk_free_rate, is_call)`
on the class generator finds the volatility at which the model's price
equals a premium, or `NULL` when the premium is not above zero or lies
outside the prices the model can give. It signals `ValueError` when the
reference price, strike price or years to expiry is not above zero.

## Super class

[`OptionPricingModel`](https://pramodathani.github.io/tradeR/reference/OptionPricingModel.md)
-\> `BlackScholes`

## Public fields

- `underlying_price`:

  The numeric price of the underlying.

- `strike_price`:

  The numeric strike price of the option.

- `years_to_expiry`:

  The numeric time left until expiry, in years.

- `risk_free_rate`:

  The numeric annual risk-free interest rate, continuously compounded,
  such as 0.065 for 6.5 per cent.

- `volatility`:

  The numeric annual volatility of the underlying, such as 0.12 for 12
  per cent.

- `is_call`:

  A logical that is `TRUE` for a call and `FALSE` for a put.

## Active bindings

- `price`:

  The option's numeric fair price by the model.

- `delta`:

  How much the option's price moves for a one-unit move in the
  underlying, as a numeric value.

- `gamma`:

  How much the delta moves for a one-unit move in the underlying, the
  same for a call and a put, as a numeric value.

- `theta`:

  How much the option's price changes as one calendar day passes, as a
  numeric value.

- `vega`:

  How much the option's price moves when volatility rises by one
  percentage point, the same for a call and a put, as a numeric value.

- `rho`:

  How much the option's price moves when the risk-free rate rises by one
  percentage point, as a numeric value.

## Methods

### Public methods

- [`BlackScholes$new()`](#method-BlackScholes-initialize)

- [`BlackScholes$clone()`](#method-BlackScholes-clone)

Inherited methods

- [`OptionPricingModel$search_volatility()`](https://pramodathani.github.io/tradeR/reference/OptionPricingModel.html#method-search_volatility)

------------------------------------------------------------------------

### `BlackScholes$new()`

Keeps the option's inputs after checking that the model can use them.

#### Usage

    BlackScholes$new(
      underlying_price,
      strike_price,
      years_to_expiry,
      risk_free_rate,
      volatility,
      is_call
    )

#### Arguments

- `underlying_price`:

  The numeric price of the underlying, above zero.

- `strike_price`:

  The numeric strike price of the option, above zero.

- `years_to_expiry`:

  The numeric time left until expiry in years, above zero.

- `risk_free_rate`:

  The numeric annual risk-free interest rate, continuously compounded.

- `volatility`:

  The numeric annual volatility of the underlying, above zero.

- `is_call`:

  A logical that is `TRUE` for a call and `FALSE` for a put.

#### Details

Errors: signals `ValueError` when the underlying price, strike price,
years to expiry or volatility is not above zero.

#### Returns

A new `BlackScholes` object.

------------------------------------------------------------------------

### `BlackScholes$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BlackScholes$clone(deep = FALSE)

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
c(
  price = model$price,
  delta = model$delta,
  theta = model$theta
)
#>       price       delta       theta 
#> 126.7939125   0.4337297 -13.0391997 
```
