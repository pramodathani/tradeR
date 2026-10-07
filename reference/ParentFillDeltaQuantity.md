# A quantity that is what an option entry filled times that option's delta

The `parent_fill_delta` quantity of a plan: what a `then` join's first
plan filled, scaled by the delta of the option the plan trades.

It is for a delta hedge. The plan's own instrument must be an option, or
UBI refuses the plan, and at each fill UBI works out the option's
Black-76 delta at `volatility` percent, using the last price of the
order's own instrument, usually the future, as the forward. The order
must be a `then` join's child (`parent_fill_needs_then`), and an order
with side `against_delta` must have this quantity
(`against_delta_needs_delta`); that side sells against a bought call and
buys against a bought put. With `whole_lots` the size is rounded to
whole lots of the order's own instrument. An expired option, or a
forward with no price, leaves the size as it was, and UBI tries again on
every tick until the order has started. An order sized this way that
names an instrument the first plan trades is refused with HTTP 400,
because it would only trade back what was filled.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `ParentFillDeltaQuantity`

## Public fields

- `volatility`:

  The numeric volatility in percent the delta is worked out at.

- `whole_lots`:

  A logical that is `TRUE` to round the result to whole lots of the
  order's own instrument.

## Methods

### Public methods

- [`ParentFillDeltaQuantity$new()`](#method-ParentFillDeltaQuantity-initialize)

- [`ParentFillDeltaQuantity$document()`](#method-ParentFillDeltaQuantity-document)

- [`ParentFillDeltaQuantity$clone()`](#method-ParentFillDeltaQuantity-clone)

------------------------------------------------------------------------

### `ParentFillDeltaQuantity$new()`

Initialises the quantity with the volatility its delta is worked out at.

#### Usage

    ParentFillDeltaQuantity$new(volatility, whole_lots = FALSE)

#### Arguments

- `volatility`:

  The numeric annual volatility in percent above zero, such as 12.5.

- `whole_lots`:

  A logical that is `TRUE` to round to whole lots of the order's own
  instrument.

#### Returns

A new `ParentFillDeltaQuantity` object.

------------------------------------------------------------------------

### `ParentFillDeltaQuantity$document()`

Builds the `parent_fill_delta` quantity UBI reads.

#### Usage

    ParentFillDeltaQuantity$document()

#### Returns

A named list with the single key `parent_fill_delta`, whose value holds
`volatility`, and `whole_lots` when it is `TRUE`.

#### Examples

    part <- ThenPart$new(
      first = OrderPart$new(),
      each_fill = OrderPart$new(
        side = "against_delta",
        quantity = ParentFillDeltaQuantity$new(
          volatility = 12.5,
          whole_lots = TRUE
        )
      )
    )
    print(part$document())

    quantity <- ParentFillDeltaQuantity$new(volatility = 18.0)
    print(quantity$document())

------------------------------------------------------------------------

### `ParentFillDeltaQuantity$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ParentFillDeltaQuantity$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- ThenPart$new(
  first = OrderPart$new(),
  each_fill = OrderPart$new(
    instrument = future,
    side = "against_delta",
    quantity = ParentFillDeltaQuantity$new(volatility = 12.5, whole_lots = TRUE)
  )
)
document <- part$document()
} # }

## ------------------------------------------------
## Method `ParentFillDeltaQuantity$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- ThenPart$new(
  first = OrderPart$new(),
  each_fill = OrderPart$new(
    side = "against_delta",
    quantity = ParentFillDeltaQuantity$new(
      volatility = 12.5,
      whole_lots = TRUE
    )
  )
)
print(part$document())

quantity <- ParentFillDeltaQuantity$new(volatility = 18.0)
print(quantity$document())
} # }
```
