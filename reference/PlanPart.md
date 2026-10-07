# One piece of a plan order, which can describe itself as the object UBI's order engine reads

The shared base of every part of a plan order.

Every node, preset, trigger condition and pricing rule of a plan is a
`PlanPart`, whose `document()` method gives the piece of UBI's `plan`
object that the part stands for. The base holds no state of its own.

## Methods

### Public methods

- [`PlanPart$document()`](#method-PlanPart-document)

- [`PlanPart$clone()`](#method-PlanPart-clone)

------------------------------------------------------------------------

### `PlanPart$document()`

Builds the object UBI reads for this part.

#### Usage

    PlanPart$document()

#### Details

Errors: signals `NotImplementedError` when the part is the base class
itself, which stands for no part of a plan.

#### Returns

A named list holding exactly one key, the part's UBI name, whose value
is the part's settings. The few parts that are entries of a list rather
than named values, `Lifetime`, `PreOpenVenue`, `PaperVenue` and
`StageRule`, hold their settings directly instead.

#### Examples

    part <- PriceCrosses$new(level = 995.0)
    print(inherits(part, "PlanPart"))
    print(part$document())

    tryCatch(
      PlanPart$new()$document(),
      NotImplementedError = function(error) {
        print(sprintf("Refused: %s", conditionMessage(error)))
      }
    )

------------------------------------------------------------------------

### `PlanPart$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PlanPart$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- PriceCrosses$new(level = 995.0)
if (inherits(part, "PlanPart")) {
  document <- part$document()
}
} # }

## ------------------------------------------------
## Method `PlanPart$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- PriceCrosses$new(level = 995.0)
print(inherits(part, "PlanPart"))
print(part$document())

tryCatch(
  PlanPart$new()$document(),
  NotImplementedError = function(error) {
    print(sprintf("Refused: %s", conditionMessage(error)))
  }
)
} # }
```
