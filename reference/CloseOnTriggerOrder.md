# A level that, when reached, cancels every order on the instrument to free margin and then closes the whole position

This is the Atlas's G12, a stop whose exit is not refused for margin.
When the level is reached, UBI first cancels every order resting on the
instrument at every broker, including orders placed outside UBI, because
pending orders hold margin, and then closes the whole net position held
in the instrument and the template's product with a limit two ticks past
the other side's best price. It closes what is held when it fires, so
the template's `quantity` is not used, and when nothing is held it
completes without sending an order. Set `transaction_type` to the side
that opened the position, so a long position is protected by asking for
`buy`, which fires when the price falls to the level. `trigger_price`
here is that level, not the order's own trigger. With `trigger_on`, the
level is compared with the bid, the offer or the midpoint instead of the
last trade, or must be reached on two ticks in a row (`double_last`) or
for `hold_seconds` (`held`), so a single stray trade does not fire it.
It answers HTTP 202 with an `outcome` of `armed` and sends nothing to a
broker until it fires, so keep the `parent_id` from the answer. Only
orders on the template's product are cancelled, since orders on another
product belong to another position, and a change to the order's price or
quantity while it waits is refused with HTTP 409.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `CloseOnTriggerOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `trigger_level`:

  The numeric level in rupees that fires the order. Above zero.

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

- [`CloseOnTriggerOrder$new()`](#method-CloseOnTriggerOrder-initialize)

- [`CloseOnTriggerOrder$synthetic_fields()`](#method-CloseOnTriggerOrder-synthetic_fields)

- [`CloseOnTriggerOrder$clone()`](#method-CloseOnTriggerOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `CloseOnTriggerOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    CloseOnTriggerOrder$new(
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

A new `CloseOnTriggerOrder` object.

------------------------------------------------------------------------

### `CloseOnTriggerOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    CloseOnTriggerOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- CloseOnTriggerOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      trigger_price = 12.0
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- CloseOnTriggerOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      trigger_price = 12.0,
      trigger_on = "held",
      hold_seconds = 10
    )
    print(order$synthetic)

------------------------------------------------------------------------

### `CloseOnTriggerOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CloseOnTriggerOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- CloseOnTriggerOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 995.0,
  trigger_price = 995.0,
  trigger_on = "held",
  hold_seconds = 3.0,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `CloseOnTriggerOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- CloseOnTriggerOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  trigger_price = 12.0
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- CloseOnTriggerOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  trigger_price = 12.0,
  trigger_on = "held",
  hold_seconds = 10
)
print(order$synthetic)
} # }
```
