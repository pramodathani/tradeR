# A limit order that starts on its own side of the book and steps towards the other until it fills

It saves the spread when the market is patient and still fills when it
is not. After `cross_after_seconds` it crosses the spread outright, and
it never goes past `cap_price`. It is never moved backwards, even when
the book lags behind it, and `cross_after_seconds` is counted from the
first tick after it rests.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `ChaserOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `step_ticks`:

  The integer number of ticks per step, or `NULL` to let UBI use 1.

- `step_seconds`:

  The numeric number of seconds between steps, or `NULL` to let UBI use
  5.

- `cap_price`:

  The numeric worst price in rupees it will take, or `NULL`.

- `cross_after_seconds`:

  The numeric number of seconds after which it crosses the spread, or
  `NULL` never to cross.

## Methods

### Public methods

- [`ChaserOrder$new()`](#method-ChaserOrder-initialize)

- [`ChaserOrder$synthetic_fields()`](#method-ChaserOrder-synthetic_fields)

- [`ChaserOrder$clone()`](#method-ChaserOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `ChaserOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    ChaserOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
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
      step_ticks = NULL,
      step_seconds = NULL,
      cap_price = NULL,
      cross_after_seconds = NULL
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

- `step_ticks`:

  The integer number of ticks per step, or `NULL` to let UBI use 1.

- `step_seconds`:

  The numeric number of seconds between steps, or `NULL` to let UBI use
  5.

- `cap_price`:

  The numeric worst price in rupees it will take, or `NULL`.

- `cross_after_seconds`:

  The numeric number of seconds after which it crosses the spread, or
  `NULL` never to cross.

#### Returns

A new `ChaserOrder` object.

------------------------------------------------------------------------

### `ChaserOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    ChaserOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- ChaserOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 13.0,
      step_ticks = 2,
      step_seconds = 3,
      cap_price = 13.2
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- ChaserOrder$new(
      share,
      transaction_type = "sell",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 14.0
    )
    print(order$synthetic)

------------------------------------------------------------------------

### `ChaserOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ChaserOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- ChaserOrder$new(
  share,
  transaction_type = "sell",
  product = "mis",
  order_type = "limit",
  quantity = 75,
  price = 120.0,
  cap_price = 115.0,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `ChaserOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- ChaserOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 13.0,
  step_ticks = 2,
  step_seconds = 3,
  cap_price = 13.2
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- ChaserOrder$new(
  share,
  transaction_type = "sell",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 14.0
)
print(order$synthetic)
} # }
```
