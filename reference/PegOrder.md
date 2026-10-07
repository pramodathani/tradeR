# A limit order kept re-priced to the bid, the offer or the midpoint as the book moves

Every re-price is a real modification that counts against the broker's
order limits, so UBI throttles them and never sends one that changes
nothing. A modification that changes the price loses the order's place
in the queue. The template's own price is not used: UBI places the order
where the reference is, sends a `market` template as a limit there, and
with no price for the reference yet answers HTTP 202 with an `outcome`
of `armed` and places it on the first tick that has one. `cap_price`
must be a whole number of ticks, or UBI refuses the order with HTTP 400.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `PegOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `reference`:

  The character price to follow, `own_touch` for your own side's best
  price, `mid` or `opposite_touch`, or `NULL` to let UBI use
  `own_touch`.

- `offset_ticks`:

  The integer number of ticks away from filling, where a negative number
  moves towards the market, or `NULL` to let UBI use 0.

- `cap_price`:

  The numeric price in rupees it never goes past, or `NULL`.

## Methods

### Public methods

- [`PegOrder$new()`](#method-PegOrder-initialize)

- [`PegOrder$synthetic_fields()`](#method-PegOrder-synthetic_fields)

- [`PegOrder$clone()`](#method-PegOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `PegOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    PegOrder$new(
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
      reference = NULL,
      offset_ticks = NULL,
      cap_price = NULL
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

- `reference`:

  The character price to follow, `own_touch` for your own side's best
  price, `mid` or `opposite_touch`, or `NULL` to let UBI use
  `own_touch`.

- `offset_ticks`:

  The integer number of ticks away from filling, where a negative number
  moves towards the market, or `NULL` to let UBI use 0.

- `cap_price`:

  The numeric price in rupees it never goes past, or `NULL`.

#### Returns

A new `PegOrder` object.

------------------------------------------------------------------------

### `PegOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    PegOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `PegOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PegOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- PegOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  reference = "mid",
  cap_price = 1005.0,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
