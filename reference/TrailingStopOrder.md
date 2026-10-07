# A real stop at the broker whose trigger follows the market up, never down

The stop sits at the exchange as a stop-limit, so it keeps protecting
the position while UBI is down, and UBI moves its trigger with
modifications as the best price improves. Give `trail_points` or
`trail_percent`, not both. With `activate_at`, it is a trailing
take-profit: nothing is placed until the last traded price reaches that
level, the answer is HTTP 202 with an `outcome` of `armed`, and the stop
then trails from there.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `TrailingStopOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `stop_limit_offset`:

  The numeric distance in rupees past the trigger that the stop's limit
  sits. Above zero.

- `trail_points`:

  The numeric fixed trailing distance in rupees, or `NULL`.

- `trail_percent`:

  The numeric trailing distance as a percentage of the best price seen,
  or `NULL`.

- `step_ticks`:

  The integer number of ticks the trigger must be able to move before it
  is moved, or `NULL` to let UBI use 1.

- `activate_at`:

  The numeric price in rupees the last traded price must reach before
  the stop is placed a trail's distance from it, which makes the order a
  trailing take-profit that answers HTTP 202 with an `outcome` of
  `armed`, or `NULL` to place the stop at once.

## Methods

### Public methods

- [`TrailingStopOrder$new()`](#method-TrailingStopOrder-initialize)

- [`TrailingStopOrder$synthetic_fields()`](#method-TrailingStopOrder-synthetic_fields)

- [`TrailingStopOrder$clone()`](#method-TrailingStopOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `TrailingStopOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    TrailingStopOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      stop_limit_offset,
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
      trail_points = NULL,
      trail_percent = NULL,
      step_ticks = NULL,
      activate_at = NULL
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

- `stop_limit_offset`:

  The numeric distance in rupees past the trigger that the stop's limit
  sits. Above zero.

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

- `trail_points`:

  The numeric fixed trailing distance in rupees, or `NULL`.

- `trail_percent`:

  The numeric trailing distance as a percentage of the best price seen,
  or `NULL`.

- `step_ticks`:

  The integer number of ticks the trigger must be able to move before it
  is moved, or `NULL` to let UBI use 1.

- `activate_at`:

  The numeric price in rupees the last traded price must reach before
  the stop is placed a trail's distance from it, which makes the order a
  trailing take-profit that answers HTTP 202 with an `outcome` of
  `armed`, or `NULL` to place the stop at once.

#### Returns

A new `TrailingStopOrder` object.

------------------------------------------------------------------------

### `TrailingStopOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    TrailingStopOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `TrailingStopOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TrailingStopOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- TrailingStopOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  trail_points = 5.0,
  stop_limit_offset = 2.0,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
