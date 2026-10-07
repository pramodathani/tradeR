# A group of trigger conditions of which any one is enough

The `any` trigger of a plan: a group of conditions that holds when any
one of them holds.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `AnyCondition`

## Public fields

- `conditions`:

  The list of `PlanPart` conditions in the group.

## Methods

### Public methods

- [`AnyCondition$new()`](#method-AnyCondition-initialize)

- [`AnyCondition$document()`](#method-AnyCondition-document)

- [`AnyCondition$clone()`](#method-AnyCondition-clone)

------------------------------------------------------------------------

### `AnyCondition$new()`

Initialises the group with its conditions.

#### Usage

    AnyCondition$new(conditions)

#### Arguments

- `conditions`:

  A list of `PlanPart` conditions, which may include other groups.

#### Returns

A new `AnyCondition` object.

------------------------------------------------------------------------

### `AnyCondition$document()`

Builds the `any` group UBI reads.

#### Usage

    AnyCondition$document()

#### Returns

A named list with the single key `any`, whose value is the list of the
conditions' objects.

#### Examples

    condition <- AnyCondition$new(
      list(
        PriceCrosses$new(level = 990.0, direction = "at_or_below"),
        TimeAt$new("15:10")
      )
    )
    print(condition$document())

    condition <- AnyCondition$new(
      list(
        Trails$new(points = 5.0),
        PriceCrosses$new(level = 990.0, direction = "at_or_below")
      )
    )
    print(condition$document())

------------------------------------------------------------------------

### `AnyCondition$clone()`

The objects of this class are cloneable with this method.

#### Usage

    AnyCondition$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- AnyCondition$new(
  list(
    PriceCrosses$new(level = 990.0, direction = "at_or_below"),
    TimeAt$new("15:10")
  )
)
document <- condition$document()
} # }

## ------------------------------------------------
## Method `AnyCondition$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
condition <- AnyCondition$new(
  list(
    PriceCrosses$new(level = 990.0, direction = "at_or_below"),
    TimeAt$new("15:10")
  )
)
print(condition$document())

condition <- AnyCondition$new(
  list(
    Trails$new(points = 5.0),
    PriceCrosses$new(level = 990.0, direction = "at_or_below")
  )
)
print(condition$document())
} # }
```
