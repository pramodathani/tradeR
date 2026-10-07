# An order that rests one slice at a time and places the next when that slice fills

Only one slice is ever visible, so the size of the whole order is hidden
from the book. `randomise_percent` varies each slice so that the pattern
is harder to spot. A randomised slice is brought to the nearest whole
number of lots, at least one, and a slice cancelled or rejected at the
broker ends the iceberg.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `IcebergOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `slice_quantity`:

  The integer size of each slice, at least 1 and smaller than the
  quantity.

- `randomise_percent`:

  The numeric percentage by which each slice may vary either way, at or
  above 0 and below 100, or `NULL` to let UBI use 0.

## Methods

### Public methods

- [`IcebergOrder$new()`](#method-IcebergOrder-initialize)

- [`IcebergOrder$synthetic_fields()`](#method-IcebergOrder-synthetic_fields)

- [`IcebergOrder$clone()`](#method-IcebergOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `IcebergOrder$new()`

Initialises the order template and this type's own settings.

#### Usage

    IcebergOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      slice_quantity,
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
      randomise_percent = NULL
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

- `slice_quantity`:

  The integer size of each slice, at least 1 and smaller than the
  quantity.

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

- `randomise_percent`:

  The numeric percentage by which each slice may vary either way, at or
  above 0 and below 100, or `NULL` to let UBI use 0.

#### Returns

A new `IcebergOrder` object.

------------------------------------------------------------------------

### `IcebergOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    IcebergOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, where a value of `NULL` means
the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- IcebergOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 10,
      price = 13.0,
      slice_quantity = 2
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- IcebergOrder$new(
      share,
      transaction_type = "sell",
      product = "mis",
      order_type = "limit",
      quantity = 100,
      price = 14.0,
      slice_quantity = 15,
      randomise_percent = 20
    )
    fields <- order$synthetic_fields()
    slices <- order$quantity %/% fields[["slice_quantity"]]
    if (order$quantity %% fields[["slice_quantity"]] != 0) {
      slices <- slices + 1
    }
    cat(sprintf(
      "About %d slices, each within %s%%\n",
      slices,
      fields[["randomise_percent"]]
    ))

------------------------------------------------------------------------

### `IcebergOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    IcebergOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- IcebergOrder$new(
  share,
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 1000,
  price = 1000.0,
  slice_quantity = 100,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `IcebergOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- IcebergOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 13.0,
  slice_quantity = 2
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- IcebergOrder$new(
  share,
  transaction_type = "sell",
  product = "mis",
  order_type = "limit",
  quantity = 100,
  price = 14.0,
  slice_quantity = 15,
  randomise_percent = 20
)
fields <- order$synthetic_fields()
slices <- order$quantity %/% fields[["slice_quantity"]]
if (order$quantity %% fields[["slice_quantity"]] != 0) {
  slices <- slices + 1
}
cat(sprintf(
  "About %d slices, each within %s%%\n",
  slices,
  fields[["randomise_percent"]]
))
} # }
```
