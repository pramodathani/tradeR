# The day's positions on one product, closed with limit orders at a time of day after their resting orders are cancelled

UBI decides the side, the order type and the quantity of every closing
order from the positions, so the template carries placeholders for them.
The instrument only anchors the request; it does not limit what is
closed. It answers HTTP 202 with an `outcome` of `armed` and sends
nothing until `at_time`, so keep the `parent_id` from the answer. At
that time UBI cancels every open order on each instrument it closes,
including stops still waiting for their trigger, and sends each closing
order on the product of the position it closes. Times follow the
instrument's exchange trading calendar: on a weekend or an exchange
holiday a time means that time on the next trading day.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `SquareOffOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `at_time`:

  The character time of day to square off, as `HH:MM` or `HH:MM:SS`
  India time.

- `only_instruments`:

  The list of `TradeableInstrument` to limit the square-off to, or
  `NULL` for every position on the product.

## Methods

### Public methods

- [`SquareOffOrder$new()`](#method-SquareOffOrder-initialize)

- [`SquareOffOrder$synthetic_fields()`](#method-SquareOffOrder-synthetic_fields)

- [`SquareOffOrder$clone()`](#method-SquareOffOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `SquareOffOrder$new()`

Initialises the square-off.

#### Usage

    SquareOffOrder$new(
      instrument,
      at_time,
      product = "mis",
      only_instruments = NULL,
      validity = NULL,
      tag = NULL,
      closes_position = TRUE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE
    )

#### Arguments

- `instrument`:

  The `TradeableInstrument` that anchors the request, which does not
  limit what is closed.

- `at_time`:

  The character time of day to square off, as `HH:MM` or `HH:MM:SS`
  India time, later today and well before the broker's own square-off.

- `product`:

  The character order product of the positions to close and of the
  closing orders, `"cnc"`, `"mis"` or `"nrml"`.

- `only_instruments`:

  The list of `TradeableInstrument` to limit the square-off to, or
  `NULL` for every position on the product.

- `validity`:

  The character validity of the closing orders, `"day"` or `"ioc"`, or
  `NULL` to let UBI use `"day"`.

- `tag`:

  A character label of up to twenty letters and digits to label the
  request with, or `NULL`.

- `closes_position`:

  A logical that is `TRUE` to let the closing orders use the share of a
  broker's daily order cap kept for exits, which is what a square-off
  is.

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

  A logical that is `TRUE` to have UBI check the request and return it
  without recording or sending anything.

#### Returns

A new `SquareOffOrder` object.

------------------------------------------------------------------------

### `SquareOffOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

UBI filters positions by their product as the positions route spells it,
so the order product is translated: `mis` becomes `intraday`, `cnc`
becomes `delivery` and `nrml` becomes `carry`. A product with no
translation is sent as given.

#### Usage

    SquareOffOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

------------------------------------------------------------------------

### `SquareOffOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    SquareOffOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- SquareOffOrder$new(
  share,
  at_time = "15:05",
  product = "mis",
  dry_run = TRUE
)
answer <- order$place()
} # }
```
