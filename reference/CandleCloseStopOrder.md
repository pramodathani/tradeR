# A hidden stop that fires only when a whole bar closes past the level

A brief wick through the level does not stop the position out. The bars
are built from the last traded price on UBI's own ticks from the moment
the order is placed, and are aligned to the clock, so one-minute bars
end on the minute and the first decision can come seconds after placing.
The exit is a limit `buffer_ticks` past the other side's best price when
the bar closes, and is not moved afterwards. Everything else is as for a
`HiddenStopOrder`, including the optional backstop, which makes the
answer HTTP 200 with a `legs` list. Without a backstop it answers HTTP
202 with an `outcome` of `armed` and sends nothing to a broker until it
fires, so keep the `parent_id` from the answer.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `CandleCloseStopOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `trigger_level`:

  The numeric hidden level in rupees.

- `bar_minutes`:

  The numeric length of each bar in minutes, or `NULL` to let UBI use 5.

- `backstop_price`:

  The numeric trigger in rupees of a real stop placed at the broker,
  given together with `backstop_limit_price`, or `NULL`.

- `backstop_limit_price`:

  The numeric limit in rupees of that real stop, or `NULL`.

- `buffer_ticks`:

  The integer number of ticks past the best price to price the exit, or
  `NULL` to let UBI use 2.

- `trigger_direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` to
  let UBI work it out from the side.

## Methods

### Public methods

- [`CandleCloseStopOrder$new()`](#method-CandleCloseStopOrder-initialize)

- [`CandleCloseStopOrder$synthetic_fields()`](#method-CandleCloseStopOrder-synthetic_fields)

- [`CandleCloseStopOrder$clone()`](#method-CandleCloseStopOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `CandleCloseStopOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    CandleCloseStopOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      trigger_price,
      price = NULL,
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
      bar_minutes = NULL,
      backstop_price = NULL,
      backstop_limit_price = NULL,
      buffer_ticks = NULL,
      trigger_direction = NULL
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

- `trigger_price`:

  The numeric hidden level in rupees.

- `price`:

  The numeric limit price in rupees, or `NULL` for an order type that
  takes no price or when a price reference supplies it.

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

- `bar_minutes`:

  The numeric length of each bar in minutes, or `NULL` to let UBI use 5.

- `backstop_price`:

  The numeric trigger in rupees of a real stop placed at the broker,
  given together with `backstop_limit_price`, or `NULL`.

- `backstop_limit_price`:

  The numeric limit in rupees of that real stop, or `NULL`.

- `buffer_ticks`:

  The integer number of ticks past the best price to price the exit, or
  `NULL` to let UBI use 2.

- `trigger_direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` to
  let UBI work it out from the side.

#### Returns

A new `CandleCloseStopOrder` object.

------------------------------------------------------------------------

### `CandleCloseStopOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    CandleCloseStopOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- CandleCloseStopOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      trigger_price = 12.0,
      bar_minutes = 15
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- CandleCloseStopOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      trigger_price = 12.0,
      backstop_price = 11.5,
      backstop_limit_price = 11.45
    )
    print(order$trigger_level)
    print(order$trigger_price)
    print(order$synthetic)

------------------------------------------------------------------------

### `CandleCloseStopOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CandleCloseStopOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- CandleCloseStopOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 990.0,
  trigger_price = 990.0,
  bar_minutes = 15.0,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `CandleCloseStopOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- CandleCloseStopOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  trigger_price = 12.0,
  bar_minutes = 15
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- CandleCloseStopOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  trigger_price = 12.0,
  backstop_price = 11.5,
  backstop_limit_price = 11.45
)
print(order$trigger_level)
print(order$trigger_price)
print(order$synthetic)
} # }
```
