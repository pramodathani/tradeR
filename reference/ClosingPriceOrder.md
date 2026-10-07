# An order sliced by volume through the half hour the day's closing price is computed from

This is market-on-close or limit-on-close, the Atlas's G2. NSE and BSE
compute an equity's closing price as the volume weighted average of the
trades from 15:00 to 15:30, so this is a volume weighted order spread
across that window, which is the nearest there is for futures, options
and intraday orders; only the cash segment's post-closing session fills
at the closing price exactly, and it takes only delivery orders. The
length is worked out from the window, so there is no `over_minutes`. An
order sent before the window answers HTTP 202 with an `outcome` of
`armed` and sends its first slice when the window opens, one sent inside
the window sends its first slice at once and spreads the rest over what
is left, and one sent after 15:30 is refused with HTTP 400. The window
follows the instrument's exchange trading calendar. Slices are shared
out in whole lots, and a slice that comes to nothing, as it does when
the order has fewer lots than slices, is skipped and the schedule moves
on.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `ClosingPriceOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `slices`:

  The integer number of slices, from 2 to 60, or `NULL` to let UBI use
  6, one every five minutes across the default window. A quantity of
  fewer lots than this is accepted, and the empty slices are skipped.

- `window_start`:

  The character time the window opens, as `HH:MM` or `HH:MM:SS` India
  time, from 09:15 and before 15:30, or `NULL` to let UBI use `15:00`.

- `volume_profile`:

  The list of numeric relative weights, kept as a list so it is sent as
  a JSON array even when it holds one weight, one per half hour from the
  open, none negative and adding up to more than zero, or `NULL` to let
  UBI use its own.

## Methods

### Public methods

- [`ClosingPriceOrder$new()`](#method-ClosingPriceOrder-initialize)

- [`ClosingPriceOrder$synthetic_fields()`](#method-ClosingPriceOrder-synthetic_fields)

- [`ClosingPriceOrder$clone()`](#method-ClosingPriceOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `ClosingPriceOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    ClosingPriceOrder$new(
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
      slices = NULL,
      window_start = NULL,
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

- `slices`:

  The integer number of slices, from 2 to 60, or `NULL` to let UBI use
  6, one every five minutes across the default window. A quantity of
  fewer lots than this is accepted, and the empty slices are skipped.

- `window_start`:

  The character time the window opens, as `HH:MM` or `HH:MM:SS` India
  time, from 09:15 and before 15:30, or `NULL` to let UBI use `15:00`.

- `volume_profile`:

  A numeric vector or list of relative weights, one per half hour from
  the open, none negative and adding up to more than zero, or `NULL` to
  let UBI use its own.

#### Returns

A new `ClosingPriceOrder` object.

------------------------------------------------------------------------

### `ClosingPriceOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    ClosingPriceOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- ClosingPriceOrder$new(
      share,
      transaction_type = "buy",
      product = "cnc",
      order_type = "limit",
      quantity = 10,
      price = 13.0,
      slices = 10
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- ClosingPriceOrder$new(
      share,
      transaction_type = "buy",
      product = "cnc",
      order_type = "limit",
      quantity = 12,
      price = 13.0,
      slices = 6,
      window_start = "14:45",
      volume_profile = list(
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        3.0
      )
    )
    print(order$synthetic)

------------------------------------------------------------------------

### `ClosingPriceOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ClosingPriceOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- ClosingPriceOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 600,
  price = 1000.0,
  slices = 6,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `ClosingPriceOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- ClosingPriceOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 10,
  price = 13.0,
  slices = 10
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- ClosingPriceOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 12,
  price = 13.0,
  slices = 6,
  window_start = "14:45",
  volume_profile = list(
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    1.0,
    3.0
  )
)
print(order$synthetic)
} # }
```
