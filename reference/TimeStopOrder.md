# An entry placed now whose filled part is closed at a time of day, or after some minutes

When the time comes, the unfilled part of the entry is cancelled first
and only then is what filled closed, so the entry cannot go on buying
into the position being closed. It closes only what this order filled,
not everything held in the instrument. Give `until_time` or `minutes`,
not both. Times follow the instrument's exchange trading calendar: on a
weekend or an exchange holiday a time means that time on the next
trading day. On a closed day `minutes` is refused, because minutes from
now mean nothing until the market opens, so give `until_time` instead.
UBI refuses both, or neither, with HTTP 400, and closes what filled
whether the entry filled in part or completely. By default UBI holds a
limit entry in its virtual order book until the other side of the book
reaches its price, unless `hold_limits` is `FALSE`.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `TimeStopOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `until_time`:

  The character time of day to close at, as `HH:MM` or `HH:MM:SS` India
  time, or `NULL`.

- `minutes`:

  The numeric number of minutes after placing to close at, or `NULL`.

## Methods

### Public methods

- [`TimeStopOrder$new()`](#method-TimeStopOrder-initialize)

- [`TimeStopOrder$synthetic_fields()`](#method-TimeStopOrder-synthetic_fields)

- [`TimeStopOrder$clone()`](#method-TimeStopOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `TimeStopOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    TimeStopOrder$new(
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
      until_time = NULL,
      minutes = NULL
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

- `until_time`:

  The character time of day to close at, as `HH:MM` or `HH:MM:SS` India
  time, or `NULL`.

- `minutes`:

  The numeric number of minutes after placing to close at, or `NULL`.

#### Returns

A new `TimeStopOrder` object.

------------------------------------------------------------------------

### `TimeStopOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    TimeStopOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `TimeStopOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TimeStopOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- TimeStopOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  until_time = "15:10",
  dry_run = TRUE
)
answer <- order$place()
} # }
```
