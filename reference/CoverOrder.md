# An entry with a compulsory stop and no target

It behaves like a bracket without a target, except that the stop is
required and a target is refused: the stop is armed on the first partial
fill, grows as the entry fills, and is cancelled if the entry is
cancelled with nothing filled. Brokers once sold this as a product, and
Flattrade's API restricts it, which is why UBI rebuilds it. By default
UBI holds a limit entry in its virtual order book until the other side
of the book reaches its price, answering HTTP 202 with an `outcome` of
`armed`, while the exits rest at the broker as the entry fills; give
`hold_limits` `FALSE` to send the entry at once. A stop the broker
refuses cancels the rest of the entry, and the parent ends `failed`,
because the position is left without its stop.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `CoverOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `stop_price`:

  The numeric trigger of the stop in rupees.

- `stop_limit_price`:

  The numeric limit of the stop in rupees.

## Methods

### Public methods

- [`CoverOrder$new()`](#method-CoverOrder-initialize)

- [`CoverOrder$synthetic_fields()`](#method-CoverOrder-synthetic_fields)

- [`CoverOrder$clone()`](#method-CoverOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `CoverOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    CoverOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      stop_price,
      stop_limit_price,
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

- `stop_price`:

  The numeric trigger of the stop in rupees.

- `stop_limit_price`:

  The numeric limit of the stop in rupees.

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

A new `CoverOrder` object.

------------------------------------------------------------------------

### `CoverOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    CoverOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- CoverOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 13.0,
      stop_price = 12.5,
      stop_limit_price = 12.45
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- CoverOrder$new(
      share,
      transaction_type = "sell",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 14.0,
      stop_price = 14.5,
      stop_limit_price = 14.55
    )
    fields <- order$synthetic_fields()
    risk <- fields[["stop_limit_price"]] - order$price
    cat(sprintf("At most %.2f rupees a share\n", risk))

------------------------------------------------------------------------

### `CoverOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CoverOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- CoverOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 100,
  price = 1000.0,
  stop_price = 990.0,
  stop_limit_price = 988.0,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `CoverOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- CoverOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 13.0,
  stop_price = 12.5,
  stop_limit_price = 12.45
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- CoverOrder$new(
  share,
  transaction_type = "sell",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 14.0,
  stop_price = 14.5,
  stop_limit_price = 14.55
)
fields <- order$synthetic_fields()
risk <- fields[["stop_limit_price"]] - order$price
cat(sprintf("At most %.2f rupees a share\n", risk))
} # }
```
