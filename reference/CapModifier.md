# A bound on the price a pricing rule may set

The `cap` modifier of a plan's pricing: the most a buy will pay and the
least a sell will take.

A cap is not a pricing rule of its own but a bound on one. Whatever the
rule works out, when the order is sent and every time it is moved, a
buy's limit is held at or below `worst_price` and a sell's at or above
it. It goes beside the one pricing rule, as
`OrderPart$new(pricing = ..., cap = ...)`, and an order has at most one
cap. A market order has no limit to cap.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `CapModifier`

## Public fields

- `worst_price`:

  The numeric worst price in rupees, the most a buy pays or the least a
  sell takes.

## Methods

### Public methods

- [`CapModifier$new()`](#method-CapModifier-initialize)

- [`CapModifier$document()`](#method-CapModifier-document)

- [`CapModifier$clone()`](#method-CapModifier-clone)

------------------------------------------------------------------------

### `CapModifier$new()`

Initialises the cap with its worst price.

#### Usage

    CapModifier$new(worst_price)

#### Arguments

- `worst_price`:

  The numeric worst price in rupees, above zero, the most a buy pays or
  the least a sell takes.

#### Returns

A new `CapModifier` object.

------------------------------------------------------------------------

### `CapModifier$document()`

Builds the `cap` modifier object UBI reads in an order's pricing list.

#### Usage

    CapModifier$document()

#### Returns

A named list with the single key `cap`, whose value holds `worst_price`.

#### Examples

    cap <- CapModifier$new(worst_price = 1010.0)
    print(cap$document())

    part <- OrderPart$new(
      pricing = ChasePricing$new(step_ticks = 1, step_seconds = 5),
      cap = CapModifier$new(worst_price = 1010.0)
    )
    print(part$document())

------------------------------------------------------------------------

### `CapModifier$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CapModifier$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
cap <- CapModifier$new(worst_price = 1010.0)
document <- cap$document()
} # }

## ------------------------------------------------
## Method `CapModifier$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
cap <- CapModifier$new(worst_price = 1010.0)
print(cap$document())

part <- OrderPart$new(
  pricing = ChasePricing$new(step_ticks = 1, step_seconds = 5),
  cap = CapModifier$new(worst_price = 1010.0)
)
print(part$document())
} # }
```
