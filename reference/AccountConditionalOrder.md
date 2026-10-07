# An order sent, or cancelled, when the account's free margin, day's profit or open position count reaches a level

This is the Atlas's G17, which waits on the account rather than on a
price. About once a second, UBI compares `account_field` with
`account_level` in `trigger_direction`: `available_balance` is the free
margin across every broker, `day_pnl` is realized plus unrealized profit
across every broker as the daily loss lockout reads it, and
`open_positions` is how many net positions are open. With `action` set
to `place`, nothing is sent until the condition holds, and the answer is
HTTP 202 with an `outcome` of `armed`, so keep the `parent_id` from the
answer. With `cancel`, the order is sent at once and cancelled when the
condition holds, such as pulling a resting bid when the day's loss
reaches a limit. `trigger_direction` is required, because the side of
the order says nothing about which way the account has to move. With
`place`, a limit order is held in UBI's virtual order book from the
moment the condition holds until the other side of the book reaches its
price, even if the account figure moves back, unless `hold_limits` is
`FALSE`.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `AccountConditionalOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `account_field`:

  The character figure watched, `available_balance`, `day_pnl` or
  `open_positions`.

- `account_level`:

  The numeric level the figure is compared with, in rupees or in
  positions, which may be negative for a loss.

- `trigger_direction`:

  The character direction, `at_or_above` or `at_or_below`.

- `action`:

  The character action when the condition holds, `place` to send the
  order then or `cancel` to send it at once and cancel it then, or
  `NULL` to let UBI use `place`.

## Methods

### Public methods

- [`AccountConditionalOrder$new()`](#method-AccountConditionalOrder-initialize)

- [`AccountConditionalOrder$synthetic_fields()`](#method-AccountConditionalOrder-synthetic_fields)

- [`AccountConditionalOrder$clone()`](#method-AccountConditionalOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `AccountConditionalOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    AccountConditionalOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      account_field,
      account_level,
      trigger_direction,
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
      action = NULL
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

- `account_field`:

  The character figure watched, `available_balance`, `day_pnl` or
  `open_positions`.

- `account_level`:

  The numeric level the figure is compared with, in rupees or in
  positions, which may be negative for a loss.

- `trigger_direction`:

  The character direction, `at_or_above` or `at_or_below`.

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

- `action`:

  The character action when the condition holds, `place` to send the
  order then or `cancel` to send it at once and cancel it then, or
  `NULL` to let UBI use `place`.

#### Returns

A new `AccountConditionalOrder` object.

------------------------------------------------------------------------

### `AccountConditionalOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    AccountConditionalOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- AccountConditionalOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 13.0,
      account_field = "open_positions",
      account_level = 5,
      trigger_direction = "at_or_above"
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- AccountConditionalOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 13.0,
      account_field = "day_pnl",
      account_level = -2000.0,
      trigger_direction = "at_or_below",
      action = "cancel"
    )
    print(order$synthetic)

------------------------------------------------------------------------

### `AccountConditionalOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    AccountConditionalOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- AccountConditionalOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 995.0,
  account_field = "day_pnl",
  account_level = -5000.0,
  trigger_direction = "at_or_below",
  action = "cancel",
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `AccountConditionalOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- AccountConditionalOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 13.0,
  account_field = "open_positions",
  account_level = 5,
  trigger_direction = "at_or_above"
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- AccountConditionalOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 13.0,
  account_field = "day_pnl",
  account_level = -2000.0,
  trigger_direction = "at_or_below",
  action = "cancel"
)
print(order$synthetic)
} # }
```
