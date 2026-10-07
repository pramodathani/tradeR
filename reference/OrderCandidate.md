# One instrument's order inside a multi-instrument synthetic order, with the template fields it overrides

`BasketOrder`, `OneCancelsAllOrder`, `LeggedSpreadOrder` and
`StrategyStopOrder` each place one real order per candidate. A candidate
names its instrument and may override eight fields of the order
template; every field left as `NULL` takes the template's value.

## Public fields

- `instrument`:

  The `TradeableInstrument` this leg trades.

- `transaction_type`:

  The character side, `"buy"` or `"sell"`, or `NULL` to use the
  template's.

- `product`:

  The character product, `"cnc"`, `"mis"` or `"nrml"`, or `NULL` to use
  the template's.

- `order_type`:

  The character kind of order, or `NULL` to use the template's.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to use the
  template's.

- `quantity`:

  The integer quantity in underlying units, or `NULL` to use the
  template's.

- `price`:

  The numeric limit price in rupees, or `NULL` to use the template's.

- `trigger_price`:

  The numeric trigger price in rupees, or `NULL` to use the template's.

- `tag`:

  The character label, or `NULL` to use the template's.

## Methods

### Public methods

- [`OrderCandidate$new()`](#method-OrderCandidate-initialize)

- [`OrderCandidate$document()`](#method-OrderCandidate-document)

- [`OrderCandidate$clone()`](#method-OrderCandidate-clone)

------------------------------------------------------------------------

### `OrderCandidate$new()`

Initialises the leg with its instrument and the fields it overrides.

A candidate is merged over the whole template, so a template price is
carried into a candidate that sets `order_type` to `market` unless the
candidate is priced differently, and UBI then refuses the market order
that carries a price. Give such a template no price, or give each
candidate its own.

#### Usage

    OrderCandidate$new(
      instrument,
      transaction_type = NULL,
      product = NULL,
      order_type = NULL,
      validity = NULL,
      quantity = NULL,
      price = NULL,
      trigger_price = NULL,
      tag = NULL
    )

#### Arguments

- `instrument`:

  The `TradeableInstrument` this leg trades.

- `transaction_type`:

  The character side, `"buy"` or `"sell"`, or `NULL` to use the
  template's.

- `product`:

  The character product, `"cnc"`, `"mis"` or `"nrml"`, or `NULL` to use
  the template's.

- `order_type`:

  The character kind of order, `"market"`, `"limit"`, `"sl"` or
  `"sl-m"`, or `NULL` to use the template's.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to use the
  template's.

- `quantity`:

  The integer quantity in underlying units, or `NULL` to use the
  template's.

- `price`:

  The numeric limit price in rupees, or `NULL` to use the template's.

- `trigger_price`:

  The numeric trigger price in rupees, or `NULL` to use the template's.

- `tag`:

  A character label of up to twenty letters and digits, or `NULL` to use
  the template's.

#### Returns

A new `OrderCandidate` object.

------------------------------------------------------------------------

### `OrderCandidate$document()`

Builds the candidate object UBI reads, naming the instrument and every
field that is set.

#### Usage

    OrderCandidate$document()

#### Returns

A named list with `instrument_id` and each overridden field that is not
`NULL`.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    candidate <- OrderCandidate$new(share, price = 13.0)
    print(candidate$document())

    first_share <- Equity$new(exchange = "nse", symbol = "IDEA")
    second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    candidates <- list(
      OrderCandidate$new(first_share, price = 13.0),
      OrderCandidate$new(
        second_share,
        transaction_type = "sell",
        quantity = 2,
        price = 21.0,
        tag = "pairleg"
      )
    )
    for (candidate in candidates) {
      print(candidate$document())
    }

------------------------------------------------------------------------

### `OrderCandidate$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OrderCandidate$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
first <- OrderCandidate$new(nifty_call, price = 120.0)
second <- OrderCandidate$new(
  nifty_put,
  transaction_type = "sell",
  price = 95.0
)
document <- first$document()
} # }

## ------------------------------------------------
## Method `OrderCandidate$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
candidate <- OrderCandidate$new(share, price = 13.0)
print(candidate$document())

first_share <- Equity$new(exchange = "nse", symbol = "IDEA")
second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
candidates <- list(
  OrderCandidate$new(first_share, price = 13.0),
  OrderCandidate$new(
    second_share,
    transaction_type = "sell",
    quantity = 2,
    price = 21.0,
    tag = "pairleg"
  )
)
for (candidate in candidates) {
  print(candidate$document())
}
} # }
```
