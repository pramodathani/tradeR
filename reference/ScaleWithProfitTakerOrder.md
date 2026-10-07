# A ladder whose every filled rung gets its own profit-taker, and is placed again once that profit is taken

This is the Atlas's G15, what Interactive Brokers sells as ScaleTrader.
The rungs are placed as a `LadderOrder` places them, shared out in whole
lots. Once a rung has filled completely, a limit for what it filled goes
out `profit_points` better, a sell above a filled buy or a buy below a
filled sell, and once that fills the rung is placed again at its own
price, until each rung has been placed again `most_cycles` times, so
each rung trades `most_cycles + 1` times. A rung that only partly fills
waits for the rest before its profit-taker goes out, and if it is
cancelled instead, the part that filled gets no profit-taker. A rung is
placed again only after its profit-taker has closed it, so the position
never grows past the ladder's own quantity. A profit-taker the broker
refuses leaves the other rungs working, and the parent stays `working`.
Without `most_cycles` the order does not finish on its own, so cancel it
with `cancel()` when you are done; with it, the parent completes once
every rung has used its cycles. By default UBI holds each rung in its
virtual order book until the other side of the book reaches its price,
and holds it again once its profit has been taken, answering HTTP 202
with nothing placed, while every profit-taker rests at the broker as
soon as its rung fills; give `hold_limits` `FALSE` to rest the rungs at
the broker.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `ScaleWithProfitTakerOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `from_price`:

  The numeric price of the first rung in rupees. Above zero.

- `to_price`:

  The numeric price of the last rung in rupees. Above zero, and
  different from `from_price`.

- `steps`:

  The integer number of rungs, from 2 to 20. The quantity must be at
  least this many lots.

- `profit_points`:

  The numeric distance in rupees past a filled rung's price at which its
  profit-taker is placed. Above zero.

- `most_cycles`:

  The integer number of times each rung is placed again after its profit
  is taken, at least 1, so each rung trades one time more than this, or
  `NULL` to let a rung cycle until the order is cancelled.

## Methods

### Public methods

- [`ScaleWithProfitTakerOrder$new()`](#method-ScaleWithProfitTakerOrder-initialize)

- [`ScaleWithProfitTakerOrder$synthetic_fields()`](#method-ScaleWithProfitTakerOrder-synthetic_fields)

- [`ScaleWithProfitTakerOrder$clone()`](#method-ScaleWithProfitTakerOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `ScaleWithProfitTakerOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    ScaleWithProfitTakerOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      from_price,
      to_price,
      steps,
      profit_points,
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
      most_cycles = NULL
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

- `from_price`:

  The numeric price of the first rung in rupees. Above zero.

- `to_price`:

  The numeric price of the last rung in rupees. Above zero, and
  different from `from_price`.

- `steps`:

  The integer number of rungs, from 2 to 20. The quantity must be at
  least this many lots.

- `profit_points`:

  The numeric distance in rupees past a filled rung's price at which its
  profit-taker is placed. Above zero.

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

- `most_cycles`:

  The integer number of times each rung is placed again after its profit
  is taken, at least 1, so each rung trades one time more than this, or
  `NULL` to let a rung cycle until the order is cancelled.

#### Returns

A new `ScaleWithProfitTakerOrder` object.

------------------------------------------------------------------------

### `ScaleWithProfitTakerOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    ScaleWithProfitTakerOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `ScaleWithProfitTakerOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ScaleWithProfitTakerOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- ScaleWithProfitTakerOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 30,
  price = 1000.0,
  from_price = 1000.0,
  to_price = 990.0,
  steps = 3,
  profit_points = 4.0,
  most_cycles = 5,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
