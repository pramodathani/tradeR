# Several plans started at once, each trading its own quantity

The `together` join of a plan: one to twenty-five plans started at once,
each trading its own quantity.

Unlike an `either` join, a fill on one child does nothing to the others,
so a together join is how a plan sends a basket, a pair or a spread
whose legs are independent. By default UBI's broker selector chooses a
broker that can afford the whole group, and `hedge_benefit` prices
hedged legs as one position. With `done_when` set to `any`, the rest are
cancelled once one child is done. A together join cannot be a `then`
join's child, because that child is sized to the first plan's fills.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `TogetherPart`

## Public fields

- `children`:

  The list of `PlanPart` nodes started at once.

- `group_margin`:

  A logical that is `FALSE` to let each child choose its broker alone,
  or `NULL` for UBI's default of `TRUE`.

- `hedge_benefit`:

  A logical that is `TRUE` to price hedged children together as one
  position when checking the broker can afford them.

- `done_when`:

  The character rule, `all` or `any`, for when the join is done, or
  `NULL` for UBI's default of `all`.

## Methods

### Public methods

- [`TogetherPart$new()`](#method-TogetherPart-initialize)

- [`TogetherPart$document()`](#method-TogetherPart-document)

- [`TogetherPart$clone()`](#method-TogetherPart-clone)

------------------------------------------------------------------------

### `TogetherPart$new()`

Initialises the join with its children and settings.

#### Usage

    TogetherPart$new(
      children,
      group_margin = NULL,
      hedge_benefit = FALSE,
      done_when = NULL
    )

#### Arguments

- `children`:

  A list of one to twenty-five `PlanPart` nodes, each an `OrderPart` or
  another join.

- `group_margin`:

  A logical that is `TRUE` for the broker selector to choose a broker
  that can afford the whole group, `FALSE` for each child to choose
  alone, or `NULL` for UBI's default of `TRUE`.

- `hedge_benefit`:

  A logical that is `TRUE` to price options and futures on one
  underlying and expiry together as one hedged position when checking
  the broker can afford the group.

- `done_when`:

  The character rule `all` for the join to be done once every child is
  done, `any` to cancel the rest once one child is done, or `NULL` for
  UBI's default of `all`.

#### Returns

A new `TogetherPart` object.

------------------------------------------------------------------------

### `TogetherPart$document()`

Builds the `together` node UBI reads.

#### Usage

    TogetherPart$document()

#### Returns

A named list with the single key `together`, whose value holds
`children`, `group_margin` and `done_when` when they are not `NULL`, and
`hedge_benefit` when it is `TRUE`.

#### Examples

    part <- TogetherPart$new(
      children = list(
        OrderPart$new(transaction_type = "buy", quantity = 10),
        OrderPart$new(transaction_type = "sell", quantity = 10)
      ),
      hedge_benefit = TRUE
    )
    print(part$document())

    part <- TogetherPart$new(
      children = list(
        OrderPart$new(
          trigger = PriceCrosses$new(level = 995.0)
        ),
        OrderPart$new(
          trigger = PriceCrosses$new(level = 990.0)
        )
      ),
      group_margin = FALSE,
      done_when = "any"
    )
    print(part$document())

------------------------------------------------------------------------

### `TogetherPart$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TogetherPart$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- TogetherPart$new(
  children = list(
    OrderPart$new(transaction_type = "buy"),
    OrderPart$new(transaction_type = "sell")
  ),
  hedge_benefit = TRUE
)
document <- part$document()
} # }

## ------------------------------------------------
## Method `TogetherPart$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- TogetherPart$new(
  children = list(
    OrderPart$new(transaction_type = "buy", quantity = 10),
    OrderPart$new(transaction_type = "sell", quantity = 10)
  ),
  hedge_benefit = TRUE
)
print(part$document())

part <- TogetherPart$new(
  children = list(
    OrderPart$new(
      trigger = PriceCrosses$new(level = 995.0)
    ),
    OrderPart$new(
      trigger = PriceCrosses$new(level = 990.0)
    )
  ),
  group_margin = FALSE,
  done_when = "any"
)
print(part$document())
} # }
```
