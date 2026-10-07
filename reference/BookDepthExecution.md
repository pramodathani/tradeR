# An execution that waits for enough displayed size at or inside a price and then strikes

The `book_depth` execution of a plan: nothing shown until enough size is
displayed at an acceptable price, then a strike for what is there.

It adds up the displayed quantity at every level of the other side of
the book that is no worse than `limit_price`, and when that reaches
`minimum_quantity` it sends the smaller of what is shown and what is
left of the order. A strike that partly fills rests at its price, and
later strikes are only for what is neither traded nor resting. A strike
the broker rejects stops the order. The order starts watching the book
as soon as its trigger holds.

The strike's price comes from the order's pricing, so the
`liquidity_seeking` preset pairs this execution with a `FixedPricing` at
the same `limit_price`, and that is the usual way to write it out. It
does not nest, and cannot carry a resting stop.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `BookDepthExecution`

## Public fields

- `limit_price`:

  The numeric worst price in rupees the order will trade at.

- `minimum_quantity`:

  The integer displayed size, at least 1, that makes a strike
  worthwhile.

## Methods

### Public methods

- [`BookDepthExecution$new()`](#method-BookDepthExecution-initialize)

- [`BookDepthExecution$document()`](#method-BookDepthExecution-document)

- [`BookDepthExecution$clone()`](#method-BookDepthExecution-clone)

------------------------------------------------------------------------

### `BookDepthExecution$new()`

Initialises the execution with its price and its minimum size.

#### Usage

    BookDepthExecution$new(limit_price, minimum_quantity)

#### Arguments

- `limit_price`:

  The numeric worst price in rupees the order will trade at.

- `minimum_quantity`:

  The integer displayed size, at least 1, that makes a strike
  worthwhile.

#### Returns

A new `BookDepthExecution` object.

------------------------------------------------------------------------

### `BookDepthExecution$document()`

Builds the `book_depth` execution object UBI reads.

#### Usage

    BookDepthExecution$document()

#### Returns

A named list with the single key `book_depth`, whose value holds
`limit_price` and `minimum_quantity`.

#### Examples

    execution <- BookDepthExecution$new(
      limit_price = 1000.0,
      minimum_quantity = 500
    )
    print(execution$document())

    part <- OrderPart$new(
      pricing = FixedPricing$new(
        price = 1000.0,
        order_type = "LIMIT"
      ),
      execution = BookDepthExecution$new(
        limit_price = 1000.0,
        minimum_quantity = 500
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `BookDepthExecution$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BookDepthExecution$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
execution <- BookDepthExecution$new(
  limit_price = 1000.0,
  minimum_quantity = 500
)
part <- OrderPart$new(execution = execution)
document <- part$document()
} # }

## ------------------------------------------------
## Method `BookDepthExecution$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
execution <- BookDepthExecution$new(
  limit_price = 1000.0,
  minimum_quantity = 500
)
print(execution$document())

part <- OrderPart$new(
  pricing = FixedPricing$new(
    price = 1000.0,
    order_type = "LIMIT"
  ),
  execution = BookDepthExecution$new(
    limit_price = 1000.0,
    minimum_quantity = 500
  )
)
print(part$document())
} # }
```
