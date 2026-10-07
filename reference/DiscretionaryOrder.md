# A limit order that shows one price and quietly takes a slightly worse one when it comes within reach

The visible limit rests at `price`. When the other side comes within
`discretion_points` of it, UBI takes what is there and reduces the
resting order by the same amount. When the take covers the whole resting
order, UBI cancels it rather than reducing it. The template must be a
`limit` order with a price, and a stop or `market` template is refused
with `discretion_needs_limit`.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `DiscretionaryOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `discretion_points`:

  The numeric number of rupees beyond the shown price it will pay. Above
  zero.

- `discretion_quantity`:

  The integer quantity to take when the chance comes, or `NULL` to take
  everything still resting.

## Methods

### Public methods

- [`DiscretionaryOrder$new()`](#method-DiscretionaryOrder-initialize)

- [`DiscretionaryOrder$synthetic_fields()`](#method-DiscretionaryOrder-synthetic_fields)

- [`DiscretionaryOrder$clone()`](#method-DiscretionaryOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `DiscretionaryOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    DiscretionaryOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      discretion_points,
      price = NULL,
      trigger_price = NULL,
      validity = NULL,
      disclosed_quantity = NULL,
      after_market = FALSE,
      tag = NULL,
      price_reference = NULL,
      quantity_reference = NULL,
      closes_position = FALSE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE,
      discretion_quantity = NULL
    )

#### Arguments

- `instrument`:

  The `TradeableInstrument` to place the order in.

- `transaction_type`:

  The character side of the order, `"buy"` or `"sell"`.

- `product`:

  The character product, `"cnc"` for delivery, `"mis"` for intraday or
  `"nrml"` for carry forward.

- `order_type`:

  The character kind of order, `"market"`, `"limit"`, `"sl"` or
  `"sl-m"`.

- `quantity`:

  The integer quantity in underlying units, not lots, or `NULL` when a
  quantity reference supplies it.

- `discretion_points`:

  The numeric number of rupees beyond the shown price it will pay. Above
  zero.

- `price`:

  The numeric limit price in rupees, or `NULL` for an order type that
  takes no price or when a price reference supplies it.

- `trigger_price`:

  The numeric trigger price in rupees of the order itself, or `NULL` for
  an order type that takes no trigger.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use
  `"day"`.

- `disclosed_quantity`:

  The integer quantity to show on the exchange, or `NULL` to disclose
  the whole order.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character label of up to twenty letters and digits to label the
  order with, or `NULL`.

- `price_reference`:

  A named list describing the price for UBI to work out, such as
  `list(kind = "mid")`, or `NULL`.

- `quantity_reference`:

  A named list describing the quantity for UBI to work out, such as
  `list(kind = "liquidate_position")`, or `NULL`.

- `closes_position`:

  A logical that is `TRUE` when every order this type sends closes a
  position, so it may use the share of a broker's daily order cap kept
  for exits.

- `reduce_only`:

  A logical that is `TRUE` to have UBI refuse, with HTTP 409, any leg
  that is not on the closing side of the net position held when it is
  sent or is bigger than that position.

- `hold_limits`:

  A logical that is `TRUE` to have UBI hold each order that would rest
  at the broker at a fixed limit price until the other side of the book
  reaches it, `FALSE` to send them as they come, or `NULL` to let UBI
  use the type's default.

- `dry_run`:

  A logical that is `TRUE` to have UBI check the order and answer with
  the `plan` it would run, without recording or sending anything; the
  answer's `request` is the template as a broker would receive it, which
  for a stop is not the stop.

- `discretion_quantity`:

  The integer quantity to take when the chance comes, or `NULL` to take
  everything still resting.

#### Returns

A new `DiscretionaryOrder` object.

------------------------------------------------------------------------

### `DiscretionaryOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    DiscretionaryOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- DiscretionaryOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 13.0,
      discretion_points = 0.05
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- DiscretionaryOrder$new(
      share,
      transaction_type = "sell",
      product = "mis",
      order_type = "limit",
      quantity = 2,
      price = 14.0,
      discretion_points = 0.1,
      discretion_quantity = 1
    )
    fields <- order$synthetic_fields()
    worst_price <- order$price - fields[["discretion_points"]]
    cat(sprintf("Shows %s, takes down to %.2f\n", order$price, worst_price))

------------------------------------------------------------------------

### `DiscretionaryOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    DiscretionaryOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- DiscretionaryOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  discretion_points = 1.5,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `DiscretionaryOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- DiscretionaryOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 13.0,
  discretion_points = 0.05
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- DiscretionaryOrder$new(
  share,
  transaction_type = "sell",
  product = "mis",
  order_type = "limit",
  quantity = 2,
  price = 14.0,
  discretion_points = 0.1,
  discretion_quantity = 1
)
fields <- order$synthetic_fields()
worst_price <- order$price - fields[["discretion_points"]]
cat(sprintf("Shows %s, takes down to %.2f\n", order$price, worst_price))
} # }
```
