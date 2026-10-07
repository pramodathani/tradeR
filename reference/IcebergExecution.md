# An execution that shows a small piece of the order at a time and sends the next once it has filled

The `iceberg` execution of a plan: only part of the order shown at a
time.

The order is sent as pieces of `visible_quantity`, the next only once
the last has filled. Each piece may vary by up to `randomise_percent`
either way, worked out from the parent's id and the number of pieces
sent, so another trader cannot spot a repeating size; UBI's default is
0, no variation, and a varied piece is brought to the nearest whole
number of lots, at least one. A piece that is cancelled or rejected
rather than filled stops the iceberg.

An iceberg can nest on either side. As the outer execution it releases
its pieces as slices for an inner one to work, and as the inner
execution it shows each slice of a `TwapExecution`, `VwapExecution`,
`FrontLoadedExecution`, `ParticipationExecution` or another iceberg a
little at a time.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `IcebergExecution`

## Public fields

- `visible_quantity`:

  The integer size of each piece before any variation, at least 1.

- `randomise_percent`:

  The integer percentage, 0 to 99, by which a piece may vary either way,
  or `NULL` for UBI's default of 0.

## Methods

### Public methods

- [`IcebergExecution$new()`](#method-IcebergExecution-initialize)

- [`IcebergExecution$document()`](#method-IcebergExecution-document)

- [`IcebergExecution$clone()`](#method-IcebergExecution-clone)

------------------------------------------------------------------------

### `IcebergExecution$new()`

Initialises the execution with its piece size.

#### Usage

    IcebergExecution$new(visible_quantity, randomise_percent = NULL)

#### Arguments

- `visible_quantity`:

  The integer size of each piece before any variation, at least 1.

- `randomise_percent`:

  The integer percentage, 0 to 99, by which a piece may vary either way,
  or `NULL` for UBI's default of 0.

#### Returns

A new `IcebergExecution` object.

------------------------------------------------------------------------

### `IcebergExecution$document()`

Builds the `iceberg` execution object UBI reads.

#### Usage

    IcebergExecution$document()

#### Returns

A named list with the single key `iceberg`, whose value holds
`visible_quantity` and, when it is set, `randomise_percent`.

#### Examples

    execution <- IcebergExecution$new(visible_quantity = 10)
    print(execution$document())

    execution <- IcebergExecution$new(
      visible_quantity = 50,
      randomise_percent = 20
    )
    print(execution$document())

    part <- OrderPart$new(
      execution = TwapExecution$new(
        slices = 6,
        over_minutes = 60
      ),
      inner_execution = IcebergExecution$new(
        visible_quantity = 10
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `IcebergExecution$clone()`

The objects of this class are cloneable with this method.

#### Usage

    IcebergExecution$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
execution <- IcebergExecution$new(visible_quantity = 10)
part <- OrderPart$new(execution = execution)
document <- part$document()
} # }

## ------------------------------------------------
## Method `IcebergExecution$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
execution <- IcebergExecution$new(visible_quantity = 10)
print(execution$document())

execution <- IcebergExecution$new(
  visible_quantity = 50,
  randomise_percent = 20
)
print(execution$document())

part <- OrderPart$new(
  execution = TwapExecution$new(
    slices = 6,
    over_minutes = 60
  ),
  inner_execution = IcebergExecution$new(
    visible_quantity = 10
  )
)
print(part$document())
} # }
```
