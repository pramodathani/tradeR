# A quantity that is the position held when the order fires, on one product and one or more instruments

The `position` quantity of a plan: the size of the position held when
the order fires, read at that moment.

An order with this quantity closes a position rather than trading a
number named in advance, so its side must be `close`, and a `close` side
needs this quantity. UBI first cancels every order resting on the
instruments being closed, unless `cancel_resting_first` is `FALSE`, so a
stop or target left live cannot reopen the position, and then sends each
broker's share to the broker that holds it, as a limit two ticks past
the other side's touch. Such an order therefore takes no pricing or
execution of its own. Nothing held ends the part with the reason
`nothing_held` and the plan `completed` without an order.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `PositionQuantity`

## Public fields

- `product`:

  The character position product, `intraday`, `delivery` or `carry`, or
  `NULL` for the order's own product.

- `held_instruments`:

  The list of `Instrument` whose positions are closed, or `NULL` for the
  order's own instrument.

- `every_instrument`:

  A logical that is `TRUE` to close the position in every instrument
  held on the product.

- `ratio`:

  The integer ratio, 1 to close or 2 to close and open the same size the
  other way, or `NULL` for UBI's default of 1.

- `cancel_resting_first`:

  A logical that is `FALSE` to leave resting orders alone before
  closing, or `NULL` for UBI's default of `TRUE`.

## Methods

### Public methods

- [`PositionQuantity$new()`](#method-PositionQuantity-initialize)

- [`PositionQuantity$document()`](#method-PositionQuantity-document)

- [`PositionQuantity$clone()`](#method-PositionQuantity-clone)

------------------------------------------------------------------------

### `PositionQuantity$new()`

Initialises the quantity with the positions it reads.

#### Usage

    PositionQuantity$new(
      product = NULL,
      held_instruments = NULL,
      every_instrument = FALSE,
      ratio = NULL,
      cancel_resting_first = NULL
    )

#### Arguments

- `product`:

  The character product as UBI names a position's product, `intraday`,
  `delivery` or `carry`, rather than an order's `mis`, `cnc` or `nrml`,
  or `NULL` for the order's own product.

- `held_instruments`:

  A list of `Instrument` objects whose positions are closed, or `NULL`
  for the order's own instrument; UBI refuses it beside
  `every_instrument`.

- `every_instrument`:

  A logical that is `TRUE` to close every instrument held on the
  product.

- `ratio`:

  The integer 1 to close the position, 2 to close it and open the
  reverse in one order, or `NULL` for UBI's default of 1.

- `cancel_resting_first`:

  A logical that is `TRUE` to cancel every order resting on those
  instruments first, `FALSE` to leave them, or `NULL` for UBI's default
  of `TRUE`.

#### Returns

A new `PositionQuantity` object.

------------------------------------------------------------------------

### `PositionQuantity$document()`

Builds the `position` quantity UBI reads, holding every setting that is
set.

#### Usage

    PositionQuantity$document()

#### Returns

A named list with the single key `position`, whose value holds each of
`product`, `ratio` and `cancel_resting_first` that is not `NULL`, the
instruments as a list of their `instrument_ids`, and `every_instrument`
when it is `TRUE`.

#### Examples

    part <- OrderPart$new(
      trigger = TimeAt$new("15:15"),
      side = "close",
      quantity = PositionQuantity$new(
        product = "intraday",
        every_instrument = TRUE
      )
    )
    print(part$document())

    part <- OrderPart$new(
      trigger = PriceCrosses$new(level = 990.0, direction = "at_or_below"),
      side = "close",
      quantity = PositionQuantity$new(ratio = 2)
    )
    print(part$document())

------------------------------------------------------------------------

### `PositionQuantity$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PositionQuantity$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- OrderPart$new(
  trigger = TimeAt$new("15:15"),
  side = "close",
  quantity = PositionQuantity$new(product = "intraday")
)
document <- part$document()
} # }

## ------------------------------------------------
## Method `PositionQuantity$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- OrderPart$new(
  trigger = TimeAt$new("15:15"),
  side = "close",
  quantity = PositionQuantity$new(
    product = "intraday",
    every_instrument = TRUE
  )
)
print(part$document())

part <- OrderPart$new(
  trigger = PriceCrosses$new(level = 990.0, direction = "at_or_below"),
  side = "close",
  quantity = PositionQuantity$new(ratio = 2)
)
print(part$document())
} # }
```
