# A pricing rule that steps a limit from its own side of the book towards the other side

The `chase` pricing rule of a plan: a limit that starts on its own side
of the book and walks towards the other until it fills.

The order starts at its own touch, and every `step_seconds` it moves
`step_ticks` towards the market from where it actually is, never past
the other side's touch. With `cross_after_seconds`, once that long has
passed the order is moved to the other side's touch, where it fills
against what is resting. A cap beside the rule holds every step.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `ChasePricing`

## Public fields

- `step_ticks`:

  The integer number of ticks each step moves, at least 1, or `NULL` for
  UBI's default of 1.

- `step_seconds`:

  The numeric number of seconds between steps, above zero, or `NULL` for
  UBI's default of 5.

- `cross_after_seconds`:

  The numeric number of seconds after which the order is moved to the
  other side's touch, or `NULL` to walk until it reaches the touch.

## Methods

### Public methods

- [`ChasePricing$new()`](#method-ChasePricing-initialize)

- [`ChasePricing$document()`](#method-ChasePricing-document)

- [`ChasePricing$clone()`](#method-ChasePricing-clone)

------------------------------------------------------------------------

### `ChasePricing$new()`

Initialises the rule with its step and timing.

#### Usage

    ChasePricing$new(
      step_ticks = NULL,
      step_seconds = NULL,
      cross_after_seconds = NULL
    )

#### Arguments

- `step_ticks`:

  The integer number of ticks each step moves, at least 1, or `NULL` for
  UBI's default of 1.

- `step_seconds`:

  The numeric number of seconds between steps, above zero, or `NULL` for
  UBI's default of 5.

- `cross_after_seconds`:

  The numeric number of seconds after which the order is moved to the
  other side's touch, above zero, or `NULL` to keep walking.

#### Returns

A new `ChasePricing` object.

------------------------------------------------------------------------

### `ChasePricing$document()`

Builds the `chase` pricing object UBI reads, holding every setting that
is not `NULL`.

#### Usage

    ChasePricing$document()

#### Returns

A named list with the single key `chase`, whose value holds
`step_ticks`, `step_seconds` and `cross_after_seconds` when each is set.

#### Examples

    pricing <- ChasePricing$new()
    print(pricing$document())

    pricing <- ChasePricing$new(
      step_ticks = 2,
      step_seconds = 10,
      cross_after_seconds = 60
    )
    print(pricing$document())

------------------------------------------------------------------------

### `ChasePricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ChasePricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
pricing <- ChasePricing$new(step_ticks = 1, step_seconds = 5)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `ChasePricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
pricing <- ChasePricing$new()
print(pricing$document())

pricing <- ChasePricing$new(
  step_ticks = 2,
  step_seconds = 10,
  cross_after_seconds = 60
)
print(pricing$document())
} # }
```
