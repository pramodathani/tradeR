# An order that shows nothing and strikes only when enough size appears at an acceptable price

It is the closest thing to a minimum-quantity order that anyone can
build: it waits until the visible book covers `minimum_quantity` at
`limit_price` or better, and then sends an order for it. It answers HTTP
202 with an `outcome` of `armed` and sends nothing to a broker until it
fires, so keep the `parent_id` from the answer. The strike is rounded
down to whole lots and uses the template's validity, so with the default
`day` an unfilled strike rests at `limit_price`. A book UBI marks stale
is never acted on.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `LiquiditySeekingOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `limit_price`:

  The numeric worst price in rupees it will trade at. Above zero.

- `minimum_quantity`:

  The integer smallest size worth striking for, at least 1.

## Methods

### Public methods

- [`LiquiditySeekingOrder$new()`](#method-LiquiditySeekingOrder-initialize)

- [`LiquiditySeekingOrder$synthetic_fields()`](#method-LiquiditySeekingOrder-synthetic_fields)

- [`LiquiditySeekingOrder$clone()`](#method-LiquiditySeekingOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `LiquiditySeekingOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    LiquiditySeekingOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      limit_price,
      minimum_quantity,
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

- `limit_price`:

  The numeric worst price in rupees it will trade at. Above zero.

- `minimum_quantity`:

  The integer smallest size worth striking for, at least 1.

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

A new `LiquiditySeekingOrder` object.

------------------------------------------------------------------------

### `LiquiditySeekingOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    LiquiditySeekingOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- LiquiditySeekingOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      limit_price = 13.0,
      minimum_quantity = 5000
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- LiquiditySeekingOrder$new(
      share,
      transaction_type = "sell",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      limit_price = 14.0,
      minimum_quantity = 1000
    )
    print(order$synthetic)

------------------------------------------------------------------------

### `LiquiditySeekingOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LiquiditySeekingOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- LiquiditySeekingOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 500,
  price = 1000.0,
  limit_price = 1001.0,
  minimum_quantity = 200,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `LiquiditySeekingOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- LiquiditySeekingOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  limit_price = 13.0,
  minimum_quantity = 5000
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- LiquiditySeekingOrder$new(
  share,
  transaction_type = "sell",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  limit_price = 14.0,
  minimum_quantity = 1000
)
print(order$synthetic)
} # }
```
