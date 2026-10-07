# An order that waits for the price to touch a level and then rests a limit at another price

`trigger_price` here is the level that fires the order, not the order's
own trigger, and `limit_price` is deliberately not defaulted to it. With
`trigger_on`, the level is compared with the bid, the offer or the
midpoint instead of the last trade, or must be reached on two ticks in a
row (`double_last`) or for `hold_seconds` (`held`), so a single stray
trade does not fire it. It answers HTTP 202 with an `outcome` of `armed`
and sends nothing to a broker until it fires, so keep the `parent_id`
from the answer. Once it fires, its limit is held in UBI's virtual order
book until the other side of the book reaches it, even if the price
moves back, unless `hold_limits` is `FALSE`.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `LimitIfTouchedOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `trigger_level`:

  The numeric level in rupees that fires the order. Above zero.

- `limit_price`:

  The numeric limit price in rupees of the order sent. Above zero.

- `trigger_direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` to
  let a buy wait for a fall and a sell for a rise.

- `trigger_on`:

  The character price compared with the level and how it must confirm,
  `last`, `bid`, `ask`, `mid`, `double_last` or `held`, or `NULL` to let
  UBI use `last`.

- `hold_seconds`:

  The numeric number of seconds the level must stay reached before a
  `held` trigger fires, which `held` requires, or `NULL`.

## Methods

### Public methods

- [`LimitIfTouchedOrder$new()`](#method-LimitIfTouchedOrder-initialize)

- [`LimitIfTouchedOrder$synthetic_fields()`](#method-LimitIfTouchedOrder-synthetic_fields)

- [`LimitIfTouchedOrder$clone()`](#method-LimitIfTouchedOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `LimitIfTouchedOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    LimitIfTouchedOrder$new(
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
      trigger_direction = NULL,
      trigger_on = NULL,
      hold_seconds = NULL
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

- `trigger_direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` to
  let a buy wait for a fall and a sell for a rise.

- `trigger_on`:

  The character price compared with the level and how it must confirm,
  `last`, `bid`, `ask`, `mid`, `double_last` or `held`, or `NULL` to let
  UBI use `last`.

- `hold_seconds`:

  The numeric number of seconds the level must stay reached before a
  `held` trigger fires, which `held` requires, or `NULL`.

#### Returns

A new `LimitIfTouchedOrder` object.

------------------------------------------------------------------------

### `LimitIfTouchedOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    LimitIfTouchedOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- LimitIfTouchedOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      trigger_price = 12.0,
      limit_price = 12.1
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- LimitIfTouchedOrder$new(
      share,
      transaction_type = "sell",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      trigger_price = 15.0,
      limit_price = 14.95,
      trigger_on = "bid"
    )
    print(order$synthetic)

------------------------------------------------------------------------

### `LimitIfTouchedOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LimitIfTouchedOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- LimitIfTouchedOrder$new(
  share,
  transaction_type = "buy",
  product = "nrml",
  order_type = "limit",
  quantity = 75,
  price = 142.5,
  trigger_price = 25000.0,
  limit_price = 142.5,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `LimitIfTouchedOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- LimitIfTouchedOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  trigger_price = 12.0,
  limit_price = 12.1
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- LimitIfTouchedOrder$new(
  share,
  transaction_type = "sell",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  trigger_price = 15.0,
  limit_price = 14.95,
  trigger_on = "bid"
)
print(order$synthetic)
} # }
```
