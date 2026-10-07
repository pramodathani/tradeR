# An order placed during the pre-open session, so it fills at the price the opening call auction discovers

This is market-on-open or limit-on-open, the Atlas's G1. UBI places it
at `at_time` while the pre-open is collecting orders, answering HTTP 202
with an `outcome` of `armed`, or at once, with the broker's answer, when
collection is already open. Only NSE and BSE equities and exchange
traded funds, until 09:10 for a limit and 09:05 for a market order, and
NSE stock and index futures, until 09:07 and 09:05, have a pre-open; UBI
refuses anything else with HTTP 400 rather than send it into continuous
trading, and refuses stop orders and `ioc` too. It does not check that a
future is the current month's, the only one with a pre-open. Times
follow the instrument's exchange trading calendar, so on a weekend or an
exchange holiday the order waits for the next trading day's pre-open.
Keep the `parent_id` from the answer, since nothing reaches a broker
until then.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `OpeningAuctionOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `at_time`:

  The character time to place the order, as `HH:MM` or `HH:MM:SS` India
  time, from 09:00 and before the pre-open stops collecting this order,
  or `NULL` to let UBI use `09:00:30`.

## Methods

### Public methods

- [`OpeningAuctionOrder$new()`](#method-OpeningAuctionOrder-initialize)

- [`OpeningAuctionOrder$synthetic_fields()`](#method-OpeningAuctionOrder-synthetic_fields)

- [`OpeningAuctionOrder$clone()`](#method-OpeningAuctionOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `OpeningAuctionOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    OpeningAuctionOrder$new(
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
      at_time = NULL
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

- `at_time`:

  The character time to place the order, as `HH:MM` or `HH:MM:SS` India
  time, from 09:00 and before the pre-open stops collecting this order,
  or `NULL` to let UBI use `09:00:30`.

#### Returns

A new `OpeningAuctionOrder` object.

------------------------------------------------------------------------

### `OpeningAuctionOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    OpeningAuctionOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `OpeningAuctionOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OpeningAuctionOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- OpeningAuctionOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
