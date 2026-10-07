# Several plans run one after another, each starting once the one before is done

The `sequence` join of a plan: two to twenty-five plans run one after
another.

Each child starts only once the one before it is done, whether it filled
or ended, so a sequence is how a plan waits for one order to finish
before the next is even considered. A sequence join cannot be a `then`
join's child, because that child is sized to the first plan's fills.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `SequencePart`

## Public fields

- `children`:

  The list of `PlanPart` nodes, in the order they run.

## Methods

### Public methods

- [`SequencePart$new()`](#method-SequencePart-initialize)

- [`SequencePart$document()`](#method-SequencePart-document)

- [`SequencePart$clone()`](#method-SequencePart-clone)

------------------------------------------------------------------------

### `SequencePart$new()`

Initialises the join with its children.

#### Usage

    SequencePart$new(children)

#### Arguments

- `children`:

  A list of two to twenty-five `PlanPart` nodes, each an `OrderPart` or
  another join, in the order they run.

#### Returns

A new `SequencePart` object.

------------------------------------------------------------------------

### `SequencePart$document()`

Builds the `sequence` node UBI reads.

#### Usage

    SequencePart$document()

#### Returns

A named list with the single key `sequence`, whose value holds
`children`.

#### Examples

    part <- SequencePart$new(
      children = list(
        OrderPart$new(
          trigger = PriceCrosses$new(level = 995.0)
        ),
        OrderPart$new(
          trigger = PriceCrosses$new(level = 990.0)
        )
      )
    )
    print(part$document())

    part <- SequencePart$new(
      children = list(
        ThenPart$new(
          first = OrderPart$new(),
          each_fill = OrderPart$new(
            side = "protect",
            pricing = NativeStopPricing$new(
              trigger_price = 990.0,
              limit_price = 988.0
            )
          )
        ),
        OrderPart$new(trigger = TimeAt$new("14:00"))
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `SequencePart$clone()`

The objects of this class are cloneable with this method.

#### Usage

    SequencePart$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- SequencePart$new(
  children = list(
    OrderPart$new(trigger = TimeAt$new("10:00")),
    OrderPart$new(trigger = TimeAt$new("14:00"))
  )
)
document <- part$document()
} # }

## ------------------------------------------------
## Method `SequencePart$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- SequencePart$new(
  children = list(
    OrderPart$new(
      trigger = PriceCrosses$new(level = 995.0)
    ),
    OrderPart$new(
      trigger = PriceCrosses$new(level = 990.0)
    )
  )
)
print(part$document())

part <- SequencePart$new(
  children = list(
    ThenPart$new(
      first = OrderPart$new(),
      each_fill = OrderPart$new(
        side = "protect",
        pricing = NativeStopPricing$new(
          trigger_price = 990.0,
          limit_price = 988.0
        )
      )
    ),
    OrderPart$new(trigger = TimeAt$new("14:00"))
  )
)
print(part$document())
} # }
```
