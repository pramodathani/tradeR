# A time-sliced order whose slice sizes follow the shape of the day's volume

It works like a `TimeWeightedAveragePriceOrder`, but trades more where
the market usually trades more, so the average paid tracks the day's
volume-weighted average price. Slices are shared out in whole lots, and
a slice that comes to nothing, as it does when the order has fewer lots
than slices, is skipped and the schedule moves on.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `VolumeWeightedAveragePriceOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `slices`:

  The integer number of slices, from 2 to 60. A quantity of fewer lots
  than this is accepted, and the empty slices are skipped.

- `over_minutes`:

  The numeric number of minutes to spread the slices over. Above zero.

- `volume_profile`:

  The list of numeric relative weights, kept as a list so it is sent as
  a JSON array even when it holds one weight, one per half hour from the
  open, none negative and adding up to more than zero, or `NULL` to let
  UBI use its own.

## Methods

### Public methods

- [`VolumeWeightedAveragePriceOrder$new()`](#method-VolumeWeightedAveragePriceOrder-initialize)

- [`VolumeWeightedAveragePriceOrder$synthetic_fields()`](#method-VolumeWeightedAveragePriceOrder-synthetic_fields)

- [`VolumeWeightedAveragePriceOrder$clone()`](#method-VolumeWeightedAveragePriceOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `VolumeWeightedAveragePriceOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    VolumeWeightedAveragePriceOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      slices,
      over_minutes,
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
      volume_profile = NULL
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

- `slices`:

  The integer number of slices, from 2 to 60. A quantity of fewer lots
  than this is accepted, and the empty slices are skipped.

- `over_minutes`:

  The numeric number of minutes to spread the slices over. Above zero.

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

- `volume_profile`:

  A numeric vector or list of relative weights, one per half hour from
  the open, none negative and adding up to more than zero, or `NULL` to
  let UBI use its own.

#### Returns

A new `VolumeWeightedAveragePriceOrder` object.

------------------------------------------------------------------------

### `VolumeWeightedAveragePriceOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    VolumeWeightedAveragePriceOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `VolumeWeightedAveragePriceOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    VolumeWeightedAveragePriceOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- VolumeWeightedAveragePriceOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 600,
  price_reference = list(
    kind = "marketable"
  ),
  slices = 6,
  over_minutes = 60.0,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
