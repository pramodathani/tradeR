# One plain order sent to one broker, with nothing watching it afterwards

This is what UBI's order engine runs when an order carries no
`synthetic` object at all, unless the order is a plain limit or market
order that UBI holds or follows the book with. Asking for it by name is
useful for four things: to send a `limit` order to the broker at once,
since a plain limit order with a price is otherwise held inside UBI as a
`virtual_limit` until the other side reaches its price; to send a real
`market` order, since a plain market order is otherwise run as a
`marketable_limit` that follows the other side of the book for 30
seconds and is refused with HTTP 409 when that side is empty; to mark
the order as closing a position with `closes_position`, so it may use
the share of a broker's daily order cap kept for exits; and to make it
reduce-only with `reduce_only`.

The order template's attributes are described on `SyntheticOrder`, and
this type adds none of its own.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `SimpleOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

## Methods

### Public methods

- [`SimpleOrder$new()`](#method-SimpleOrder-initialize)

- [`SimpleOrder$synthetic_fields()`](#method-SimpleOrder-synthetic_fields)

- [`SimpleOrder$clone()`](#method-SimpleOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `SimpleOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    SimpleOrder$new(
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

  A logical that is `TRUE` to have UBI build the first broker request
  and return it without recording or sending anything.

#### Returns

A new `SimpleOrder` object.

------------------------------------------------------------------------

### `SimpleOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    SimpleOrder$synthetic_fields()

#### Returns

An empty named list, because this type has no settings of its own.

------------------------------------------------------------------------

### `SimpleOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    SimpleOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- SimpleOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
