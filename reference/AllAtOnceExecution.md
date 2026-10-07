# An execution that sends the order's whole quantity as one broker order, which is UBI's default

The `all_at_once` execution of a plan: the whole quantity sent as one
broker order.

This is what UBI does when an order names no execution, so it is needed
only to say so explicitly, or to replace an execution an earlier preset
gave. Under a join that changes how much the order should trade, the one
resting order is modified rather than another being sent, so a bracket's
exits grow and shrink in place. It is one of the two executions a
resting stop may have, the other being `DailyExecution`.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `AllAtOnceExecution`

## Methods

### Public methods

- [`AllAtOnceExecution$document()`](#method-AllAtOnceExecution-document)

- [`AllAtOnceExecution$clone()`](#method-AllAtOnceExecution-clone)

------------------------------------------------------------------------

### `AllAtOnceExecution$document()`

Builds the `all_at_once` execution object UBI reads.

#### Usage

    AllAtOnceExecution$document()

#### Returns

A named list with the single key `all_at_once`, whose value is an empty
named list, because the execution takes no settings.

#### Examples

    execution <- AllAtOnceExecution$new()
    print(execution$document())

    part <- OrderPart$new(
      side = "protect",
      pricing = NativeStopPricing$new(
        trigger_price = 990.0,
        limit_price = 989.0
      ),
      execution = AllAtOnceExecution$new()
    )
    print(part$document())

------------------------------------------------------------------------

### `AllAtOnceExecution$clone()`

The objects of this class are cloneable with this method.

#### Usage

    AllAtOnceExecution$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
execution <- AllAtOnceExecution$new()
part <- OrderPart$new(execution = execution)
document <- part$document()
} # }

## ------------------------------------------------
## Method `AllAtOnceExecution$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
execution <- AllAtOnceExecution$new()
print(execution$document())

part <- OrderPart$new(
  side = "protect",
  pricing = NativeStopPricing$new(
    trigger_price = 990.0,
    limit_price = 989.0
  ),
  execution = AllAtOnceExecution$new()
)
print(part$document())
} # }
```
