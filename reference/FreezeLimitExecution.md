# An execution that splits an order larger than the chosen broker's freeze quantity into equal orders sent together

The `freeze_limit` execution of a plan: an order above the exchange's
freeze quantity split into orders each below it, all sent at once to one
broker.

The broker is chosen first, because each broker publishes its freeze
quantity in its own units: for one MCX silver option, brokers with a lot
of 30 report 600 and brokers with a lot of 1 report 20, both meaning
twenty lots. The order's quantity in that broker's terms is compared
with that figure and split evenly into orders each within it, every one
sent to that broker at once. A broker that publishes no freeze quantity
gets the order whole, and an order needing more than 20 slices is
refused.

It takes no settings, is what UBI's `freeze_slicer` preset uses, and
does not nest, so an order above the freeze quantity that also wants
slicing over time cannot be built. It cannot carry a resting stop.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `FreezeLimitExecution`

## Methods

### Public methods

- [`FreezeLimitExecution$document()`](#method-FreezeLimitExecution-document)

- [`FreezeLimitExecution$clone()`](#method-FreezeLimitExecution-clone)

------------------------------------------------------------------------

### `FreezeLimitExecution$document()`

Builds the `freeze_limit` execution object UBI reads.

#### Usage

    FreezeLimitExecution$document()

#### Returns

A named list with the single key `freeze_limit`, whose value is an empty
named list, because the execution takes no settings.

#### Examples

    execution <- FreezeLimitExecution$new()
    print(execution$document())

    part <- OrderPart$new(
      quantity = 9000,
      pricing = MarketablePricing$new(buffer_ticks = 2),
      execution = FreezeLimitExecution$new()
    )
    print(part$document())

------------------------------------------------------------------------

### `FreezeLimitExecution$clone()`

The objects of this class are cloneable with this method.

#### Usage

    FreezeLimitExecution$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
execution <- FreezeLimitExecution$new()
part <- OrderPart$new(execution = execution)
document <- part$document()
} # }

## ------------------------------------------------
## Method `FreezeLimitExecution$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
execution <- FreezeLimitExecution$new()
print(execution$document())

part <- OrderPart$new(
  quantity = 9000,
  pricing = MarketablePricing$new(buffer_ticks = 2),
  execution = FreezeLimitExecution$new()
)
print(part$document())
} # }
```
