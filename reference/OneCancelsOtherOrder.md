# A stop and a target resting together on a position already held, each shrinking as the other fills

Set `transaction_type` to the side that opened the position, so a long
position is protected by asking for `buy`, and both exits are sells.
When one exit fills in part, the other is reduced by the same amount
rather than cancelled, so the position is never left unprotected. Both
exits rest at the exchange, so in a fast market both can fill before the
reduction lands; no exchange offers an order that prevents that. Give a
stop, a target or both, and a stop always needs its limit, because every
stop is a stop-limit. Both exits go to the broker that holds the
position, whatever the broker selector would choose, and UBI refuses
with HTTP 409 a position held at more than one broker or one smaller
than the order's `quantity`, since a fill could then open a position the
other way.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `OneCancelsOtherOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `stop_price`:

  The numeric trigger of the stop in rupees, or `NULL` for no stop.

- `stop_limit_price`:

  The numeric limit of the stop in rupees, required whenever
  `stop_price` is given, or `NULL`.

- `target_price`:

  The numeric limit of the target in rupees, or `NULL` for no target.

## Methods

### Public methods

- [`OneCancelsOtherOrder$new()`](#method-OneCancelsOtherOrder-initialize)

- [`OneCancelsOtherOrder$synthetic_fields()`](#method-OneCancelsOtherOrder-synthetic_fields)

- [`OneCancelsOtherOrder$clone()`](#method-OneCancelsOtherOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `OneCancelsOtherOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    OneCancelsOtherOrder$new(
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
      dry_run = FALSE,
      stop_price = NULL,
      stop_limit_price = NULL,
      target_price = NULL
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

- `stop_price`:

  The numeric trigger of the stop in rupees, or `NULL` for no stop.

- `stop_limit_price`:

  The numeric limit of the stop in rupees, required whenever
  `stop_price` is given, or `NULL`.

- `target_price`:

  The numeric limit of the target in rupees, or `NULL` for no target.

#### Returns

A new `OneCancelsOtherOrder` object.

------------------------------------------------------------------------

### `OneCancelsOtherOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    OneCancelsOtherOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `OneCancelsOtherOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OneCancelsOtherOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- OneCancelsOtherOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  stop_price = 990.0,
  stop_limit_price = 988.0,
  target_price = 1010.0,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
