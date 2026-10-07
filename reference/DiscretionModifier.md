# A modifier that lets a resting limit take a price up to `points` worse than the one it shows

The `discretion` modifier of a plan's pricing: a visible limit that
quietly takes a slightly worse price when one comes within reach.

The visible limit rests where the pricing rule put it. When the other
side comes within `points` of it, UBI first reduces or cancels the
resting order and then takes `quantity`, by default all that still
rests, with a limit two ticks past the other side's touch but never past
the visible price plus `points`. A buy resting at 1000 with 0.25 of
discretion takes an offer of 1000.20. It goes beside the one pricing
rule, as `OrderPart$new(pricing = ..., discretion = ...)`. It needs one
visible limit, so UBI refuses it on a stop with `discretion_needs_limit`
and with any execution other than all at once with
`discretion_not_sliced`.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `DiscretionModifier`

## Public fields

- `points`:

  The numeric distance in rupees past the visible price the order will
  go.

- `quantity`:

  The integer quantity taken when the chance comes, or `NULL` for all
  that still rests.

## Methods

### Public methods

- [`DiscretionModifier$new()`](#method-DiscretionModifier-initialize)

- [`DiscretionModifier$document()`](#method-DiscretionModifier-document)

- [`DiscretionModifier$clone()`](#method-DiscretionModifier-clone)

------------------------------------------------------------------------

### `DiscretionModifier$new()`

Initialises the discretion with its distance and quantity.

#### Usage

    DiscretionModifier$new(points, quantity = NULL)

#### Arguments

- `points`:

  The numeric distance in rupees past the visible price the order will
  go, above zero.

- `quantity`:

  The integer quantity taken when the chance comes, at least 1, or
  `NULL` for all that still rests.

#### Returns

A new `DiscretionModifier` object.

------------------------------------------------------------------------

### `DiscretionModifier$document()`

Builds the `discretion` modifier object UBI reads in an order's pricing
list.

#### Usage

    DiscretionModifier$document()

#### Returns

A named list with the single key `discretion`, whose value holds
`points`, and `quantity` when it is set.

#### Examples

    discretion <- DiscretionModifier$new(points = 0.25)
    print(discretion$document())

    part <- OrderPart$new(
      pricing = PegPricing$new(reference = "own_touch"),
      discretion = DiscretionModifier$new(
        points = 0.5,
        quantity = 50
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `DiscretionModifier$clone()`

The objects of this class are cloneable with this method.

#### Usage

    DiscretionModifier$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
discretion <- DiscretionModifier$new(points = 0.25)
document <- discretion$document()
} # }

## ------------------------------------------------
## Method `DiscretionModifier$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
discretion <- DiscretionModifier$new(points = 0.25)
print(discretion$document())

part <- OrderPart$new(
  pricing = PegPricing$new(reference = "own_touch"),
  discretion = DiscretionModifier$new(
    points = 0.5,
    quantity = 50
  )
)
print(part$document())
} # }
```
