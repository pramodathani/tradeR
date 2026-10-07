# An order above the exchange's freeze quantity, split into even orders that each fit

An exchange refuses any single futures or options order above its freeze
quantity. UBI reads the limit that the broker it is sending to
publishes, in that broker's own units, and splits the order into as few
orders as fit below it, cut in whole lots as evenly as whole lots allow,
so 55 NIFTY lots of 65 under a limit of 3,511 go as 28 and 27 lots. When
the broker publishes no limit, the order goes whole, and an order whose
single lot is already above the limit is refused with HTTP 400. By
default UBI holds the whole order until the other side of the book
reaches its price and then sends every slice together, answering HTTP
202 with an `outcome` of `armed`; with `hold_limits` `FALSE` it is sent
at once, and the answer carries a `legs` list with one entry per slice.

The order template's attributes are described on `SyntheticOrder`, and
this type adds none of its own.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `FreezeSlicerOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

## Methods

### Public methods

- [`FreezeSlicerOrder$new()`](#method-FreezeSlicerOrder-initialize)

- [`FreezeSlicerOrder$synthetic_fields()`](#method-FreezeSlicerOrder-synthetic_fields)

- [`FreezeSlicerOrder$clone()`](#method-FreezeSlicerOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `FreezeSlicerOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    FreezeSlicerOrder$new(
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

A new `FreezeSlicerOrder` object.

------------------------------------------------------------------------

### `FreezeSlicerOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    FreezeSlicerOrder$synthetic_fields()

#### Returns

An empty named list, because this type has no settings of its own.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- FreezeSlicerOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 13.0
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- FreezeSlicerOrder$new(
      share,
      transaction_type = "sell",
      product = "mis",
      order_type = "limit",
      quantity = 5,
      price = 14.0
    )
    print(order$synthetic)

------------------------------------------------------------------------

### `FreezeSlicerOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    FreezeSlicerOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- FreezeSlicerOrder$new(
  share,
  transaction_type = "buy",
  product = "nrml",
  order_type = "limit",
  quantity = 2500,
  price = 120.0,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `FreezeSlicerOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- FreezeSlicerOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 13.0
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- FreezeSlicerOrder$new(
  share,
  transaction_type = "sell",
  product = "mis",
  order_type = "limit",
  quantity = 5,
  price = 14.0
)
print(order$synthetic)
} # }
```
