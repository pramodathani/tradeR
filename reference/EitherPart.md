# Several plans run at once, joined by what a fill on one does to the others

The `either` join of a plan: two or more plans run at once, where a fill
on one acts on the others.

With the sibling rule `cancel`, the first child to fill cancels the
others, which is one-cancels-other between whole plans. With `reduce`,
the children share one quantity and each is kept at that quantity less
what its siblings have filled, which is how a stop and a target protect
one position; each child must then be a single `OrderPart`.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `EitherPart`

## Public fields

- `children`:

  The list of `PlanPart` nodes run at once.

- `sibling_rule`:

  The character rule, `cancel` or `reduce`, for what a fill on one child
  does to the others.

- `cancel_before_send`:

  A logical that is `TRUE` to have a child whose trigger holds cancel
  its siblings' resting orders before it is sent.

## Methods

### Public methods

- [`EitherPart$new()`](#method-EitherPart-initialize)

- [`EitherPart$document()`](#method-EitherPart-document)

- [`EitherPart$clone()`](#method-EitherPart-clone)

------------------------------------------------------------------------

### `EitherPart$new()`

Initialises the join with its children and its sibling rule.

#### Usage

    EitherPart$new(children, sibling_rule, cancel_before_send = FALSE)

#### Arguments

- `children`:

  A list of two or more `PlanPart` nodes to run at once.

- `sibling_rule`:

  The character rule, `cancel` for the first fill to cancel the others,
  or `reduce` for the children to share one quantity.

- `cancel_before_send`:

  A logical that is `TRUE` to have a child whose trigger holds cancel
  its siblings' resting orders before it is sent.

#### Returns

A new `EitherPart` object.

------------------------------------------------------------------------

### `EitherPart$document()`

Builds the `either` node UBI reads.

#### Usage

    EitherPart$document()

#### Returns

A named list with the single key `either`, whose value holds `children`,
`sibling_rule`, and `cancel_before_send` when it is `TRUE`.

#### Examples

    part <- EitherPart$new(
      children = list(
        OrderPart$new(
          side = "protect",
          pricing = NativeStopPricing$new(
            trigger_price = 990.0,
            limit_price = 988.0
          )
        ),
        OrderPart$new(
          side = "protect",
          pricing = FixedPricing$new(price = 1010.0, order_type = "LIMIT")
        )
      ),
      sibling_rule = "reduce"
    )
    print(part$document())

    part <- EitherPart$new(
      children = list(
        OrderPart$new(
          side = "buy",
          trigger = PriceCrosses$new(level = 1010.0, direction = "at_or_above")
        ),
        OrderPart$new(
          side = "sell",
          trigger = PriceCrosses$new(level = 990.0, direction = "at_or_below")
        )
      ),
      sibling_rule = "cancel",
      cancel_before_send = TRUE
    )
    print(part$document())

------------------------------------------------------------------------

### `EitherPart$clone()`

The objects of this class are cloneable with this method.

#### Usage

    EitherPart$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- EitherPart$new(
  children = list(
    stop_part,
    target_part
  ),
  sibling_rule = "reduce"
)
document <- part$document()
} # }

## ------------------------------------------------
## Method `EitherPart$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- EitherPart$new(
  children = list(
    OrderPart$new(
      side = "protect",
      pricing = NativeStopPricing$new(
        trigger_price = 990.0,
        limit_price = 988.0
      )
    ),
    OrderPart$new(
      side = "protect",
      pricing = FixedPricing$new(price = 1010.0, order_type = "LIMIT")
    )
  ),
  sibling_rule = "reduce"
)
print(part$document())

part <- EitherPart$new(
  children = list(
    OrderPart$new(
      side = "buy",
      trigger = PriceCrosses$new(level = 1010.0, direction = "at_or_above")
    ),
    OrderPart$new(
      side = "sell",
      trigger = PriceCrosses$new(level = 990.0, direction = "at_or_below")
    )
  ),
  sibling_rule = "cancel",
  cancel_before_send = TRUE
)
print(part$document())
} # }
```
