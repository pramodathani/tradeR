# One European option on a forward price, such as an option priced off a future, priced by the Black-76 model

Black-76 is Black-Scholes with the forward price in place of the
underlying price, so the cost of carrying the underlying is already in
the price the model starts from and is not counted again. It is the
right model when the underlying given to an option is a future, and it
is the model UBI's order engine uses.

The function
`Black76$implied_volatility(premium, reference_price, strike_price, years_to_expiry, risk_free_rate, is_call)`
on the class generator finds the volatility at which the model's price
equals a premium, with `reference_price` as the forward price, or `NULL`
when the premium is not above zero or lies outside the prices the model
can give. It signals `ValueError` when the reference price, strike price
or years to expiry is not above zero.

## Super class

[`OptionPricingModel`](https://pramodathani.github.io/tradeR/reference/OptionPricingModel.md)
-\> `Black76`

## Public fields

- `forward_price`:

  The numeric forward price, such as the last price of the future the
  option is priced off.

- `strike_price`:

  The numeric strike price of the option.

- `years_to_expiry`:

  The numeric time left until expiry, in years.

- `risk_free_rate`:

  The numeric annual risk-free interest rate, continuously compounded,
  used only to discount.

- `volatility`:

  The numeric annual volatility of the forward price, such as 0.12 for
  12 per cent.

- `is_call`:

  A logical that is `TRUE` for a call and `FALSE` for a put.

## Active bindings

- `price`:

  The option's numeric fair price by the model.

- `delta`:

  How much the option's price moves for a one-unit move in the forward
  price, as a numeric value.

- `gamma`:

  How much the delta moves for a one-unit move in the forward price, the
  same for a call and a put, as a numeric value.

- `theta`:

  How much the option's price changes as one calendar day passes, with
  the forward price held still, as a numeric value.

- `vega`:

  How much the option's price moves when volatility rises by one
  percentage point, the same for a call and a put, as a numeric value.

- `rho`:

  How much the option's price moves when the rate rises by one
  percentage point, with the forward price held still, as a numeric
  value.

## Methods

### Public methods

- [`Black76$new()`](#method-Black76-initialize)

- [`Black76$clone()`](#method-Black76-clone)

Inherited methods

- [`OptionPricingModel$search_volatility()`](https://pramodathani.github.io/tradeR/reference/OptionPricingModel.html#method-search_volatility)

------------------------------------------------------------------------

### `Black76$new()`

Keeps the option's inputs after checking that the model can use them.

#### Usage

    Black76$new(
      forward_price,
      strike_price,
      years_to_expiry,
      risk_free_rate,
      volatility,
      is_call
    )

#### Arguments

- `forward_price`:

  The numeric forward price, above zero.

- `strike_price`:

  The numeric strike price of the option, above zero.

- `years_to_expiry`:

  The numeric time left until expiry in years, above zero.

- `risk_free_rate`:

  The numeric annual risk-free interest rate, continuously compounded.

- `volatility`:

  The numeric annual volatility of the forward price, above zero.

- `is_call`:

  A logical that is `TRUE` for a call and `FALSE` for a put.

#### Details

Errors: signals `ValueError` when the forward price, strike price, years
to expiry or volatility is not above zero.

#### Returns

A new `Black76` object.

------------------------------------------------------------------------

### `Black76$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Black76$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
on_a_future <- Black76$new(
  forward_price = 9125,
  strike_price = 9100,
  years_to_expiry = 20 / 365,
  risk_free_rate = 0.065,
  volatility = 0.18,
  is_call = FALSE
)
c(
  price = on_a_future$price,
  delta = on_a_future$delta
)
#>       price       delta 
#> 140.4872036  -0.4640063 
```
