# A pricing rule that sends a limit a few ticks past the opposite touch

The `marketable` pricing rule of a plan: a limit a few ticks past the
other side of the book.

UBI reads the opposite touch when it sends the order, the best offer for
a buy and the best bid for a sell, and sets the limit `buffer_ticks`
past it, so the order trades at once like a market order but cannot fill
far from the book. With no book to price against, or a quote marked
stale, the order waits for the next tick, even an order sent only when a
fill arrives, such as a hedge.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `MarketablePricing`

## Public fields

- `buffer_ticks`:

  The integer number of ticks past the opposite touch, or `NULL` for
  UBI's default of 2.

## Methods

### Public methods

- [`MarketablePricing$new()`](#method-MarketablePricing-initialize)

- [`MarketablePricing$document()`](#method-MarketablePricing-document)

- [`MarketablePricing$clone()`](#method-MarketablePricing-clone)

------------------------------------------------------------------------

### `MarketablePricing$new()`

Initialises the rule with its buffer.

#### Usage

    MarketablePricing$new(buffer_ticks = NULL)

#### Arguments

- `buffer_ticks`:

  The integer number of ticks past the opposite touch, or `NULL` for
  UBI's default of 2.

#### Returns

A new `MarketablePricing` object.

------------------------------------------------------------------------

### `MarketablePricing$document()`

Builds the `marketable` pricing object UBI reads.

#### Usage

    MarketablePricing$document()

#### Returns

A named list with the single key `marketable`, whose value holds
`buffer_ticks` when it is set.

#### Examples

    print(MarketablePricing$new()$document())

    print(MarketablePricing$new(buffer_ticks = 5)$document())

------------------------------------------------------------------------

### `MarketablePricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MarketablePricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
pricing <- MarketablePricing$new(buffer_ticks = 2)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `MarketablePricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
print(MarketablePricing$new()$document())

print(MarketablePricing$new(buffer_ticks = 5)$document())
} # }
```
