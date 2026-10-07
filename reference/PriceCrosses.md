# A condition that holds once a price reaches a level from the side that fires

The `price_crosses` trigger of a plan: a price reaching a level.

With no direction, an order sent as a buy waits for the price to fall to
the level and one sent as a sell for it to rise, which is
market-if-touched's meaning for an entry and a stop's meaning for an
order that protects a position. The price watched can be the order's own
instrument or another one.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `PriceCrosses`

## Public fields

- `level`:

  The numeric level in rupees.

- `direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` to
  take it from the order's side.

- `field`:

  The character price watched, such as `last`, `bid`, `ask` or `mid`, or
  `NULL` for `last`.

- `instrument`:

  The `Instrument` watched, or `NULL` for the order's own instrument.

- `confirm`:

  The character confirmation, `none`, `double_last` or `held`, or `NULL`
  for `none`.

- `hold_seconds`:

  The integer seconds the price must stay past the level under `held`,
  or `NULL`.

## Methods

### Public methods

- [`PriceCrosses$new()`](#method-PriceCrosses-initialize)

- [`PriceCrosses$document()`](#method-PriceCrosses-document)

- [`PriceCrosses$clone()`](#method-PriceCrosses-clone)

------------------------------------------------------------------------

### `PriceCrosses$new()`

Initialises the condition with its level and settings.

#### Usage

    PriceCrosses$new(
      level,
      direction = NULL,
      field = NULL,
      instrument = NULL,
      confirm = NULL,
      hold_seconds = NULL
    )

#### Arguments

- `level`:

  The numeric level in rupees.

- `direction`:

  The character direction, `at_or_above` or `at_or_below`, or `NULL` for
  a buy to wait for a fall and a sell for a rise.

- `field`:

  The character price watched, `last`, `bid`, `ask`, `mid`,
  `average_price`, `previous_close` or `opposite_touch`, or `NULL` for
  `last`.

- `instrument`:

  The `Instrument` to watch, or `NULL` to watch the order's own
  instrument.

- `confirm`:

  The character confirmation, `none`, `double_last` for two last prices
  in a row past the level, or `held` for the price to stay past it for
  `hold_seconds`, or `NULL` for `none`.

- `hold_seconds`:

  The integer seconds the price must stay past the level, required with
  `held`, or `NULL`.

#### Returns

A new `PriceCrosses` object.

------------------------------------------------------------------------

### `PriceCrosses$document()`

Builds the `price_crosses` condition UBI reads, holding every setting
that is not `NULL`.

#### Usage

    PriceCrosses$document()

#### Returns

A named list with the single key `price_crosses`, whose value holds
`level` and each other setting that is set, with the watched instrument
as its `instrument_id`.

#### Examples

    condition <- PriceCrosses$new(level = 995.0)
    print(condition$document())

    condition <- PriceCrosses$new(
      level = 1010.0,
      direction = "at_or_above",
      field = "bid",
      confirm = "held",
      hold_seconds = 10
    )
    print(condition$document())

    index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    condition <- PriceCrosses$new(
      level = 25000.0,
      direction = "at_or_above",
      instrument = index
    )
    print(condition$document())

------------------------------------------------------------------------

### `PriceCrosses$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PriceCrosses$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- PriceCrosses$new(level = 995.0, field = "bid")
document <- condition$document()
} # }

## ------------------------------------------------
## Method `PriceCrosses$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
condition <- PriceCrosses$new(level = 995.0)
print(condition$document())

condition <- PriceCrosses$new(
  level = 1010.0,
  direction = "at_or_above",
  field = "bid",
  confirm = "held",
  hold_seconds = 10
)
print(condition$document())

index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
condition <- PriceCrosses$new(
  level = 25000.0,
  direction = "at_or_above",
  instrument = index
)
print(condition$document())
} # }
```
