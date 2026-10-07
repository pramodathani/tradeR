# Resting buys below the market and sells above it, where each fill places its opposite one step away

A grid books a small profit every time the price swings back and forth
through a level. A trending market keeps filling one side, which is why
`most_inventory` is required: it caps how large a position the grid may
build. Once the position reaches it, every resting order on the side
that would make the position bigger is cancelled and not placed again,
and since the cap is checked after each fill, one fill can take the
position past it. `step_points` must be a whole number of ticks, or UBI
refuses the order with HTTP 400, because each filled order is answered
one step away. The grid never re-centres and never ends on its own, and
once you cancel it with `cancel()`, a fill that arrives afterwards
places nothing new.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `GridOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `levels`:

  The integer number of levels on each side, from 1 to 20.

- `step_points`:

  The numeric distance between levels in rupees, above zero and a whole
  number of ticks.

- `most_inventory`:

  The integer largest position the grid may hold, at least 1.

## Methods

### Public methods

- [`GridOrder$new()`](#method-GridOrder-initialize)

- [`GridOrder$synthetic_fields()`](#method-GridOrder-synthetic_fields)

- [`GridOrder$clone()`](#method-GridOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `GridOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    GridOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      levels,
      step_points,
      most_inventory,
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

- `levels`:

  The integer number of levels on each side, from 1 to 20.

- `step_points`:

  The numeric distance between levels in rupees, above zero and a whole
  number of ticks.

- `most_inventory`:

  The integer largest position the grid may hold, at least 1.

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

A new `GridOrder` object.

------------------------------------------------------------------------

### `GridOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    GridOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- GridOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 13.5,
      levels = 3,
      step_points = 0.5,
      most_inventory = 3
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- GridOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 13.5,
      levels = 2,
      step_points = 0.25,
      most_inventory = 2
    )
    fields <- order$synthetic_fields()
    for (level in seq_len(fields[["levels"]])) {
      distance <- fields[["step_points"]] * level
      buy_price <- order$price - distance
      sell_price <- order$price + distance
      cat(sprintf("buy %.2f  sell %.2f\n", buy_price, sell_price))
    }

------------------------------------------------------------------------

### `GridOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    GridOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- GridOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  levels = 3,
  step_points = 2.0,
  most_inventory = 30,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `GridOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- GridOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 13.5,
  levels = 3,
  step_points = 0.5,
  most_inventory = 3
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- GridOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 13.5,
  levels = 2,
  step_points = 0.25,
  most_inventory = 2
)
fields <- order$synthetic_fields()
for (level in seq_len(fields[["levels"]])) {
  distance <- fields[["step_points"]] * level
  buy_price <- order$price - distance
  sell_price <- order$price + distance
  cat(sprintf("buy %.2f  sell %.2f\n", buy_price, sell_price))
}
} # }
```
