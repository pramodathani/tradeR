# A group of trigger conditions that must all hold

The `all` trigger of a plan: a group of conditions that holds when every
one of them holds.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `AllConditions`

## Public fields

- `conditions`:

  The list of `PlanPart` conditions in the group.

## Methods

### Public methods

- [`AllConditions$new()`](#method-AllConditions-initialize)

- [`AllConditions$document()`](#method-AllConditions-document)

- [`AllConditions$clone()`](#method-AllConditions-clone)

------------------------------------------------------------------------

### `AllConditions$new()`

Initialises the group with its conditions.

#### Usage

    AllConditions$new(conditions)

#### Arguments

- `conditions`:

  A list of `PlanPart` conditions, which may include other groups.

#### Returns

A new `AllConditions` object.

------------------------------------------------------------------------

### `AllConditions$document()`

Builds the `all` group UBI reads.

#### Usage

    AllConditions$document()

#### Returns

A named list with the single key `all`, whose value is the list of the
conditions' objects.

#### Examples

    condition <- AllConditions$new(
      list(
        TimeAfter$new("10:00"),
        PriceCrosses$new(level = 995.0)
      )
    )
    print(condition$document())

    condition <- AllConditions$new(
      list(
        TimeBefore$new("15:00"),
        AnyCondition$new(
          list(
            PriceCrosses$new(level = 995.0, field = "bid"),
            PriceCrosses$new(level = 995.0, field = "last")
          )
        )
      )
    )
    print(condition$document())

------------------------------------------------------------------------

### `AllConditions$clone()`

The objects of this class are cloneable with this method.

#### Usage

    AllConditions$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- AllConditions$new(
  list(
    TimeAfter$new("10:00"),
    PriceCrosses$new(level = 995.0)
  )
)
document <- condition$document()
} # }

## ------------------------------------------------
## Method `AllConditions$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
condition <- AllConditions$new(
  list(
    TimeAfter$new("10:00"),
    PriceCrosses$new(level = 995.0)
  )
)
print(condition$document())

condition <- AllConditions$new(
  list(
    TimeBefore$new("15:00"),
    AnyCondition$new(
      list(
        PriceCrosses$new(level = 995.0, field = "bid"),
        PriceCrosses$new(level = 995.0, field = "last")
      )
    )
  )
)
print(condition$document())
} # }
```
