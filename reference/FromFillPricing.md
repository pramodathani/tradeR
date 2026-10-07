# A pricing rule for an exit set a distance from the fill that opened its position

The `from_fill` pricing rule of a plan: an exit placed a distance from
the price its position was opened at.

UBI prices the exit from the average fill of the orders that opened the
position, in the direction that suits the side it is sent on, so one
setting suits a position opened either way. When both sides of a
two-sided entry filled, only the fills on the side the position is held
on count, so a short opened at 990 and partly bought back at 1010 keeps
its exits measured from 990. With `stop_distance` the exit is a native
stop-limit that far beyond the fill against the position, with its limit
`stop_limit_offset` further on; with `target_distance` it is a limit
that far beyond the fill in the position's favour. Give the stop pair or
the target, not both. Prices are rounded to the tick, and nothing is
sent until the opening order has filled. The order must sit under a
`ThenPart`'s `each_fill` or `on_complete` child, or UBI refuses the plan
with `from_fill_needs_then`.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `FromFillPricing`

## Public fields

- `stop_distance`:

  The numeric distance in rupees from the fill to the stop's trigger, or
  `NULL` for a target.

- `stop_limit_offset`:

  The numeric distance in rupees past the stop's trigger to its limit,
  or `NULL` for a target.

- `target_distance`:

  The numeric distance in rupees from the fill to the target's limit, or
  `NULL` for a stop.

## Methods

### Public methods

- [`FromFillPricing$new()`](#method-FromFillPricing-initialize)

- [`FromFillPricing$document()`](#method-FromFillPricing-document)

- [`FromFillPricing$clone()`](#method-FromFillPricing-clone)

------------------------------------------------------------------------

### `FromFillPricing$new()`

Initialises the rule as a stop or as a target.

#### Usage

    FromFillPricing$new(
      stop_distance = NULL,
      stop_limit_offset = NULL,
      target_distance = NULL
    )

#### Arguments

- `stop_distance`:

  The numeric distance in rupees from the fill to the stop's trigger,
  given with `stop_limit_offset`, or `NULL` for a target.

- `stop_limit_offset`:

  The numeric distance in rupees past the stop's trigger to its limit,
  given with `stop_distance`, or `NULL` for a target.

- `target_distance`:

  The numeric distance in rupees from the fill to the target's limit, or
  `NULL` for a stop.

#### Returns

A new `FromFillPricing` object.

------------------------------------------------------------------------

### `FromFillPricing$document()`

Builds the `from_fill` pricing object UBI reads, holding every setting
that is not `NULL`.

#### Usage

    FromFillPricing$document()

#### Returns

A named list with the single key `from_fill`, whose value holds
`stop_distance`, `stop_limit_offset` and `target_distance` when each is
set.

#### Examples

    pricing <- FromFillPricing$new(
      stop_distance = 10.0,
      stop_limit_offset = 1.0
    )
    print(pricing$document())

    part <- ThenPart$new(
      first = OrderPart$new(),
      each_fill = EitherPart$new(
        children = list(
          OrderPart$new(
            side = "protect",
            pricing = FromFillPricing$new(
              stop_distance = 10.0,
              stop_limit_offset = 1.0
            )
          ),
          OrderPart$new(
            side = "protect",
            pricing = FromFillPricing$new(
              target_distance = 20.0
            )
          )
        ),
        sibling_rule = "reduce"
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `FromFillPricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    FromFillPricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
pricing <- FromFillPricing$new(
  stop_distance = 10.0,
  stop_limit_offset = 1.0
)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `FromFillPricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
pricing <- FromFillPricing$new(
  stop_distance = 10.0,
  stop_limit_offset = 1.0
)
print(pricing$document())

part <- ThenPart$new(
  first = OrderPart$new(),
  each_fill = EitherPart$new(
    children = list(
      OrderPart$new(
        side = "protect",
        pricing = FromFillPricing$new(
          stop_distance = 10.0,
          stop_limit_offset = 1.0
        )
      ),
      OrderPart$new(
        side = "protect",
        pricing = FromFillPricing$new(
          target_distance = 20.0
        )
      )
    ),
    sibling_rule = "reduce"
  )
)
print(part$document())
} # }
```
