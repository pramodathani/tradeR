# A fixed quantity bought at a fixed interval, each purchase resting on its own side of the book

This is a systematic plan in the manner of a SIP, run by UBI. Each
purchase rests on its own side of the book rather than paying the
spread. A `limit` template's price is a cap: the most a buy pays or the
least a sell takes, so a purchase rests at the book's own touch when
that is better and at the template's price otherwise. A template price
that is not a whole number of ticks is refused with HTTP 400 when the
order is placed, and by a dry run as well, and a `purchases` or
`every_minutes` out of range is refused with HTTP 400 under its own
name. Purchases follow the clock rather than the market's hours, so
hourly purchases on an intraday product carry on after the close.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `AccumulationOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `every_minutes`:

  The numeric number of minutes between purchases. Above zero.

- `purchases`:

  The integer number of purchases, from 1 to 100.

## Methods

### Public methods

- [`AccumulationOrder$new()`](#method-AccumulationOrder-initialize)

- [`AccumulationOrder$synthetic_fields()`](#method-AccumulationOrder-synthetic_fields)

- [`AccumulationOrder$clone()`](#method-AccumulationOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `AccumulationOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    AccumulationOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      every_minutes,
      purchases,
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
      dry_run = FALSE
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

- `every_minutes`:

  The numeric number of minutes between purchases. Above zero.

- `purchases`:

  The integer number of purchases, from 1 to 100.

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

#### Returns

A new `AccumulationOrder` object.

------------------------------------------------------------------------

### `AccumulationOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    AccumulationOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- AccumulationOrder$new(
      share,
      transaction_type = "buy",
      product = "cnc",
      order_type = "limit",
      quantity = 1,
      price = 13.0,
      every_minutes = 30,
      purchases = 10
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- AccumulationOrder$new(
      share,
      transaction_type = "buy",
      product = "cnc",
      order_type = "limit",
      quantity = 2,
      price = 13.0,
      every_minutes = 15,
      purchases = 8
    )
    fields <- order$synthetic_fields()
    total_quantity <- order$quantity * fields[["purchases"]]
    total_minutes <- fields[["every_minutes"]] * (fields[["purchases"]] - 1)
    cat(total_quantity, "shares over", total_minutes, "minutes\n")

------------------------------------------------------------------------

### `AccumulationOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    AccumulationOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- AccumulationOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 5,
  price_reference = list(
    kind = "bid_level",
    level = 1
  ),
  every_minutes = 30.0,
  purchases = 10,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `AccumulationOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- AccumulationOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 1,
  price = 13.0,
  every_minutes = 30,
  purchases = 10
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- AccumulationOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 2,
  price = 13.0,
  every_minutes = 15,
  purchases = 8
)
fields <- order$synthetic_fields()
total_quantity <- order$quantity * fields[["purchases"]]
total_minutes <- fields[["every_minutes"]] * (fields[["purchases"]] - 1)
cat(total_quantity, "shares over", total_minutes, "minutes\n")
} # }
```
