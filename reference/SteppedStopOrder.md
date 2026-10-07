# A native stop moved to set levels at set profits, and switched to trailing at the last

This is an adjustable stop, the Atlas's G8. The stop-limit is placed at
`stop_price`, and each rule names a `gain`, the profit in points from
`entry_price` that sets it off, and either a `stop_at_gain`, where to
move the stop measured from `entry_price`, or a `trail_points`, which
starts the stop trailing as a `TrailingStopOrder` does. A market that
jumps past several gains applies them all in one modification, a stop is
only ever moved in the position's favour, and a trailing rule must be
the last. Set `transaction_type` to the side that opened the position,
so a long position is protected by asking for `buy`.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `SteppedStopOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `entry_price`:

  The numeric price in rupees the position was opened at, which every
  gain is measured from. Above zero.

- `stop_price`:

  The numeric trigger price in rupees the stop starts at. Above zero.

- `stop_limit_offset`:

  The numeric distance in rupees past the trigger that the stop's limit
  sits. Above zero.

- `rules`:

  The list of 1 to 20 named list rules, each with a `gain` above zero
  and larger than the one before and exactly one of `stop_at_gain`, a
  number that may be negative to keep some risk, or `trail_points`,
  above zero, which only the last rule may have.

- `step_ticks`:

  The integer number of ticks the trigger must be able to move before it
  is moved once trailing, or `NULL` to let UBI use 1.

## Methods

### Public methods

- [`SteppedStopOrder$new()`](#method-SteppedStopOrder-initialize)

- [`SteppedStopOrder$synthetic_fields()`](#method-SteppedStopOrder-synthetic_fields)

- [`SteppedStopOrder$clone()`](#method-SteppedStopOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `SteppedStopOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    SteppedStopOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      entry_price,
      stop_price,
      stop_limit_offset,
      rules,
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
      step_ticks = NULL
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

- `entry_price`:

  The numeric price in rupees the position was opened at, which every
  gain is measured from. Above zero.

- `stop_price`:

  The numeric trigger price in rupees the stop starts at. Above zero.

- `stop_limit_offset`:

  The numeric distance in rupees past the trigger that the stop's limit
  sits. Above zero.

- `rules`:

  The list of 1 to 20 named list rules, each with a `gain` above zero
  and larger than the one before and exactly one of `stop_at_gain`, a
  number that may be negative to keep some risk, or `trail_points`,
  above zero, which only the last rule may have.

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

- `step_ticks`:

  The integer number of ticks the trigger must be able to move before it
  is moved once trailing, or `NULL` to let UBI use 1.

#### Returns

A new `SteppedStopOrder` object.

------------------------------------------------------------------------

### `SteppedStopOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    SteppedStopOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `SteppedStopOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    SteppedStopOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- SteppedStopOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  entry_price = 1000.0,
  stop_price = 990.0,
  stop_limit_offset = 2.0,
  rules = list(
    list(
      gain = 20,
      stop_at_gain = 0
    ),
    list(
      gain = 60,
      trail_points = 25
    )
  ),
  dry_run = TRUE
)
answer <- order$place()
} # }
```
