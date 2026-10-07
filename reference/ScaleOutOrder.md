# A bracket with several targets that take the position off in tranches, and a stop that moves to breakeven

The targets share the position between them, and only the stop shrinks
as each one fills, because the remaining targets already add up to what
is left. Once `breakeven_after` targets have filled, the stop is moved
to the average entry price rather than cancelled and replaced, so there
is never a moment without a stop at the exchange. By default UBI holds a
limit entry in its virtual order book until the other side of the book
reaches its price, answering HTTP 202 with an `outcome` of `armed`,
while the exits rest at the broker as the entry fills; give
`hold_limits` `FALSE` to send the entry at once. The breakeven stop is
rounded to the tick on the side that cannot lose, and a target or stop
off the tick is refused with HTTP 400 when the order is placed, and by a
dry run as well. An exit the broker refuses cancels the rest of the
entry, and the parent ends `failed`, because the position is left
without that exit.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `ScaleOutOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `target_prices`:

  The list of numeric target prices in rupees, at least two.

- `stop_price`:

  The numeric trigger of the stop in rupees.

- `stop_limit_price`:

  The numeric limit of the stop in rupees.

- `breakeven_after`:

  The integer number of targets that must fill before the stop moves to
  breakeven, or `NULL` to let UBI use 1.

## Methods

### Public methods

- [`ScaleOutOrder$new()`](#method-ScaleOutOrder-initialize)

- [`ScaleOutOrder$synthetic_fields()`](#method-ScaleOutOrder-synthetic_fields)

- [`ScaleOutOrder$clone()`](#method-ScaleOutOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `ScaleOutOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    ScaleOutOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      target_prices,
      stop_price,
      stop_limit_price,
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
      breakeven_after = NULL
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

- `target_prices`:

  A numeric vector or list of target prices in rupees, at least two.

- `stop_price`:

  The numeric trigger of the stop in rupees.

- `stop_limit_price`:

  The numeric limit of the stop in rupees.

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

- `breakeven_after`:

  The integer number of targets that must fill before the stop moves to
  breakeven, or `NULL` to let UBI use 1.

#### Returns

A new `ScaleOutOrder` object.

------------------------------------------------------------------------

### `ScaleOutOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    ScaleOutOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `ScaleOutOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ScaleOutOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- ScaleOutOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 9,
  price = 1000.0,
  target_prices = c(
    1010.0,
    1020.0,
    1030.0
  ),
  stop_price = 990.0,
  stop_limit_price = 988.0,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
