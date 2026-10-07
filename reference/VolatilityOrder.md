# An option order stated as an implied volatility, priced with the Black-76 model and re-priced as the underlying and time move

This is the Atlas's G7, an order such as "buy this call at 12.5
volatility". UBI works out the premium from the volatility, the option's
strike, expiry and type, the watched instrument's last price as the
forward, grown by `interest_rate` to expiry unless it is a future, and
the time to 15:30 on the expiry date, in years of 365 days. It follows
the watched instrument through the same step and throttle as an
`UnderlyingPegOrder`. The template must be a `limit` order, and its
`price` is the worst it accepts, the most a buy pays or the least a sell
takes; the model's premium is used whenever it is better. Changing the
order's price yourself makes it take the volatility your price implies
and carry on at that. `lowest_price` and `highest_price` never push the
order past that worst price, and an option that has already expired is
refused with HTTP 400.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `VolatilityOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `watch_instrument`:

  The `Instrument` that gives the forward price: the future of the same
  expiry for a true Black-76 forward, or the index.

- `volatility`:

  The numeric implied volatility as a percentage, above zero and at most
  500, such as 12.5.

- `interest_rate`:

  The numeric interest rate as a percentage, used to grow a watched
  index to expiry, or `NULL` to let UBI use 0.

- `lowest_price`:

  The numeric lowest price in rupees the order is moved to, above zero,
  or `NULL` for no floor.

- `highest_price`:

  The numeric highest price in rupees the order is moved to, above zero
  and not below `lowest_price`, or `NULL` for no ceiling.

- `step_ticks`:

  The integer smallest move in ticks worth a modification, at least 1,
  or `NULL` to let UBI use 1.

## Methods

### Public methods

- [`VolatilityOrder$new()`](#method-VolatilityOrder-initialize)

- [`VolatilityOrder$synthetic_fields()`](#method-VolatilityOrder-synthetic_fields)

- [`VolatilityOrder$clone()`](#method-VolatilityOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `VolatilityOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    VolatilityOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      watch_instrument,
      volatility,
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
      interest_rate = NULL,
      lowest_price = NULL,
      highest_price = NULL,
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

- `watch_instrument`:

  The `Instrument` that gives the forward price: the future of the same
  expiry for a true Black-76 forward, or the index.

- `volatility`:

  The numeric implied volatility as a percentage, above zero and at most
  500, such as 12.5.

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

- `interest_rate`:

  The numeric interest rate as a percentage, used to grow a watched
  index to expiry, or `NULL` to let UBI use 0.

- `lowest_price`:

  The numeric lowest price in rupees the order is moved to, above zero,
  or `NULL` for no floor.

- `highest_price`:

  The numeric highest price in rupees the order is moved to, above zero
  and not below `lowest_price`, or `NULL` for no ceiling.

- `step_ticks`:

  The integer smallest move in ticks worth a modification, at least 1,
  or `NULL` to let UBI use 1.

#### Returns

A new `VolatilityOrder` object.

------------------------------------------------------------------------

### `VolatilityOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    VolatilityOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `VolatilityOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    VolatilityOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- VolatilityOrder$new(
  nifty_call,
  transaction_type = "buy",
  product = "nrml",
  order_type = "limit",
  quantity = 75,
  price = 180.0,
  watch_instrument = nifty_future,
  volatility = 12.5,
  step_ticks = 4,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
