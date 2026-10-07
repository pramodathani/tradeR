# A quantity that is a ratio of what the first plan of a `then` join has filled

The `parent_fill` quantity of a plan: what a `then` join's first plan
has filled, scaled by a ratio.

It is only for an order that is a `then` join's child, which UBI checks
as `parent_fill_needs_then`. The child is resized at every fill of the
first plan to `ratio` times what has filled, and with `whole_lots` the
result is rounded to whole lots of the child's own instrument, so a size
under one lot waits for more fills and is cancelled once the first plan
has finished. An order sized this way that names an instrument the first
plan trades is refused with HTTP 400, because it would only trade back
what was filled. This is how a hedge on another instrument follows an
entry.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `ParentFillQuantity`

## Public fields

- `ratio`:

  The numeric ratio above zero applied to what filled, or `NULL` for
  UBI's default of 1.

- `whole_lots`:

  A logical that is `TRUE` to round the result to whole lots of the
  order's own instrument.

## Methods

### Public methods

- [`ParentFillQuantity$new()`](#method-ParentFillQuantity-initialize)

- [`ParentFillQuantity$document()`](#method-ParentFillQuantity-document)

- [`ParentFillQuantity$clone()`](#method-ParentFillQuantity-clone)

------------------------------------------------------------------------

### `ParentFillQuantity$new()`

Initialises the quantity with its ratio.

#### Usage

    ParentFillQuantity$new(ratio = NULL, whole_lots = FALSE)

#### Arguments

- `ratio`:

  The numeric ratio above zero, such as 0.5 for half of what filled, or
  `NULL` for UBI's default of 1.

- `whole_lots`:

  A logical that is `TRUE` to round to whole lots of the order's own
  instrument, waiting for more fills while the size is under one lot and
  cancelling the order once the first plan has finished.

#### Returns

A new `ParentFillQuantity` object.

------------------------------------------------------------------------

### `ParentFillQuantity$document()`

Builds the `parent_fill` quantity UBI reads.

#### Usage

    ParentFillQuantity$document()

#### Returns

A named list with the single key `parent_fill`, whose value holds
`ratio` when it is not `NULL` and `whole_lots` when it is `TRUE`.

#### Examples

    part <- ThenPart$new(
      first = OrderPart$new(),
      each_fill = OrderPart$new(
        transaction_type = "sell",
        quantity = ParentFillQuantity$new(
          ratio = 0.5,
          whole_lots = TRUE
        )
      )
    )
    print(part$document())

    print(ParentFillQuantity$new()$document())

------------------------------------------------------------------------

### `ParentFillQuantity$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ParentFillQuantity$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- ThenPart$new(
  first = OrderPart$new(),
  each_fill = OrderPart$new(
    instrument = hedge,
    transaction_type = "sell",
    quantity = ParentFillQuantity$new(ratio = 0.5, whole_lots = TRUE)
  )
)
document <- part$document()
} # }

## ------------------------------------------------
## Method `ParentFillQuantity$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- ThenPart$new(
  first = OrderPart$new(),
  each_fill = OrderPart$new(
    transaction_type = "sell",
    quantity = ParentFillQuantity$new(
      ratio = 0.5,
      whole_lots = TRUE
    )
  )
)
print(part$document())

print(ParentFillQuantity$new()$document())
} # }
```
