# An order that trades a fixed share of the volume the market itself trades

Trading as a share of volume keeps the order inconspicuous, because it
is never a large part of what is going through. It answers HTTP 202 with
an `outcome` of `armed` and sends nothing to a broker until it fires, so
keep the `parent_id` from the answer. Each slice is rounded down to
whole lots, and only the volume a slice accounts for is used up, so the
part it could not send counts towards the next slice; when the day's
volume falls, as it can when another broker's quote takes over, counting
starts again from there.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `ParticipationOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `participation_percent`:

  The numeric share of the market's volume to trade, above zero and at
  most 100.

- `most_slices`:

  The integer largest number of slices to send, or `NULL` to let UBI use
  60.

## Methods

### Public methods

- [`ParticipationOrder$new()`](#method-ParticipationOrder-initialize)

- [`ParticipationOrder$synthetic_fields()`](#method-ParticipationOrder-synthetic_fields)

- [`ParticipationOrder$clone()`](#method-ParticipationOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `ParticipationOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    ParticipationOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      participation_percent,
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
      most_slices = NULL
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

- `participation_percent`:

  The numeric share of the market's volume to trade, above zero and at
  most 100.

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

- `most_slices`:

  The integer largest number of slices to send, or `NULL` to let UBI use
  60.

#### Returns

A new `ParticipationOrder` object.

------------------------------------------------------------------------

### `ParticipationOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    ParticipationOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `ParticipationOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ParticipationOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- ParticipationOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 600,
  price_reference = list(
    kind = "marketable"
  ),
  participation_percent = 10.0,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
