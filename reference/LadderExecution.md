# An execution that sends the order as several limit orders at evenly spaced prices, all at once

The `ladder` execution of a plan: the order spread over several limit
orders at evenly spaced prices.

Every rung is sent at once, `steps` of them, from 2 to 20, as limits
evenly spaced from `from_price` to `to_price`, which must differ. Each
rung is rounded to the tick on the passive side, so a range that does
not divide evenly into ticks gives rungs that rest rather than cross.
The quantity is shared as evenly as whole units allow, the first rungs
taking the remainder, so 100 over three rungs is 34, 33 and 33, and a
quantity smaller than `steps` is refused.

The rung prices replace whatever the order's pricing set, so a ladder
needs no pricing. It does not nest, and cannot carry a resting stop.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `LadderExecution`

## Public fields

- `from_price`:

  The numeric price in rupees of the first rung.

- `to_price`:

  The numeric price in rupees of the last rung, different from
  `from_price`.

- `steps`:

  The integer number of rungs, from 2 to 20.

## Methods

### Public methods

- [`LadderExecution$new()`](#method-LadderExecution-initialize)

- [`LadderExecution$document()`](#method-LadderExecution-document)

- [`LadderExecution$clone()`](#method-LadderExecution-clone)

------------------------------------------------------------------------

### `LadderExecution$new()`

Initialises the execution with its range and its number of rungs.

#### Usage

    LadderExecution$new(from_price, to_price, steps)

#### Arguments

- `from_price`:

  The numeric price in rupees of the first rung.

- `to_price`:

  The numeric price in rupees of the last rung, different from
  `from_price`.

- `steps`:

  The integer number of rungs, from 2 to 20.

#### Returns

A new `LadderExecution` object.

------------------------------------------------------------------------

### `LadderExecution$document()`

Builds the `ladder` execution object UBI reads.

#### Usage

    LadderExecution$document()

#### Returns

A named list with the single key `ladder`, whose value holds
`from_price`, `to_price` and `steps`.

#### Examples

    execution <- LadderExecution$new(
      from_price = 1000.0,
      to_price = 990.0,
      steps = 5
    )
    print(execution$document())

    part <- OrderPart$new(
      side = "protect",
      execution = LadderExecution$new(
        from_price = 1010.0,
        to_price = 1030.0,
        steps = 3
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `LadderExecution$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LadderExecution$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
execution <- LadderExecution$new(
  from_price = 1000.0,
  to_price = 990.0,
  steps = 5
)
part <- OrderPart$new(execution = execution)
document <- part$document()
} # }

## ------------------------------------------------
## Method `LadderExecution$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
execution <- LadderExecution$new(
  from_price = 1000.0,
  to_price = 990.0,
  steps = 5
)
print(execution$document())

part <- OrderPart$new(
  side = "protect",
  execution = LadderExecution$new(
    from_price = 1010.0,
    to_price = 1030.0,
    steps = 3
  )
)
print(part$document())
} # }
```
