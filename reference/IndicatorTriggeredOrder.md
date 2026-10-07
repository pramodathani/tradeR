# An order sent as a limit when one field of the live quote crosses a level

It compares one value from the quote, not a computed indicator. The most
useful is `average_price`, the day's volume-weighted average, because
buying when the price comes back below the day's average cannot be
written as a native stop. `trigger_price` here is the level, not the
order's own trigger. It answers HTTP 202 with an `outcome` of `armed`
and sends nothing to a broker until it fires, so keep the `parent_id`
from the answer. Once it fires, its limit is held in UBI's virtual order
book until the other side of the book reaches it, even if the price
moves back, unless `hold_limits` is `FALSE`.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `IndicatorTriggeredOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `trigger_level`:

  The numeric level in rupees that fires the order. Above zero.

- `limit_price`:

  The numeric limit price in rupees of the order sent. Above zero.

- `watch_field`:

  The character quote field watched, `last_price`, `average_price`,
  `previous_close`, `best_bid`, `best_offer` or `mid`, or `NULL` to let
  UBI use `last_price`.

- `trigger_direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` to
  let a buy wait for a fall and a sell for a rise.

## Methods

### Public methods

- [`IndicatorTriggeredOrder$new()`](#method-IndicatorTriggeredOrder-initialize)

- [`IndicatorTriggeredOrder$synthetic_fields()`](#method-IndicatorTriggeredOrder-synthetic_fields)

- [`IndicatorTriggeredOrder$clone()`](#method-IndicatorTriggeredOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `IndicatorTriggeredOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    IndicatorTriggeredOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      trigger_price,
      limit_price,
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
      watch_field = NULL,
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

  The numeric level in rupees that fires the order. Above zero.

- `limit_price`:

  The numeric limit price in rupees of the order sent. Above zero.

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

- `watch_field`:

  The character quote field watched, `last_price`, `average_price`,
  `previous_close`, `best_bid`, `best_offer` or `mid`, or `NULL` to let
  UBI use `last_price`.

- `trigger_direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` to
  let a buy wait for a fall and a sell for a rise.

#### Returns

A new `IndicatorTriggeredOrder` object.

------------------------------------------------------------------------

### `IndicatorTriggeredOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    IndicatorTriggeredOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- IndicatorTriggeredOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      trigger_price = 13.0,
      limit_price = 13.0,
      watch_field = "average_price"
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- IndicatorTriggeredOrder$new(
      share,
      transaction_type = "sell",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      trigger_price = 14.5,
      limit_price = 14.45,
      watch_field = "best_offer",
      trigger_direction = "at_or_above"
    )
    print(order$trigger_level)
    print(order$synthetic)

------------------------------------------------------------------------

### `IndicatorTriggeredOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    IndicatorTriggeredOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- IndicatorTriggeredOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 999.5,
  trigger_price = 999.8,
  limit_price = 999.5,
  watch_field = "average_price",
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `IndicatorTriggeredOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- IndicatorTriggeredOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  trigger_price = 13.0,
  limit_price = 13.0,
  watch_field = "average_price"
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- IndicatorTriggeredOrder$new(
  share,
  transaction_type = "sell",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  trigger_price = 14.5,
  limit_price = 14.45,
  watch_field = "best_offer",
  trigger_direction = "at_or_above"
)
print(order$trigger_level)
print(order$synthetic)
} # }
```
