# An order whose execution's pieces each become a whole plan with the same extra presets and slot values

The `using` join of a plan: an order split into the pieces its execution
would send, each piece run as a whole plan of its own.

The `order` must be an `OrderPart` with exactly one execution whose
pieces are known in advance, `ladder`, `twap` or `front_loaded`, and a
timed execution must give `over_minutes` rather than `until`. UBI makes
one copy of the order per piece, writes `each_piece`'s presets and slot
values onto it, and gives each copy its piece's share: a ladder's copies
their rung's price, and a timed execution's copies their slice's turn.
So `each_piece` naming the `bracket` preset gives every rung of a ladder
its own bracket. `each_piece` takes no execution, a slot given in both
is refused, though presets are joined, a `quantity` in `each_piece` is
refused with the rule `using_piece_quantity` because it would be split
rather than given to each piece, a preset naming a type kept whole, such
as a `grid`, is refused with the rule `using_piece_kept_whole` because
it would ignore its piece's turn and price, and with a ladder neither
side takes a pricing. A using join is never resized, so it cannot be a
`then` join's child.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `UsingPart`

## Public fields

- `order`:

  The `PlanPart` `OrderPart` that is split, carrying one `ladder`,
  `twap` or `front_loaded` execution.

- `each_piece`:

  The `PlanPart` `OrderPart` whose presets and slot values are written
  onto every piece.

## Methods

### Public methods

- [`UsingPart$new()`](#method-UsingPart-initialize)

- [`UsingPart$document()`](#method-UsingPart-document)

- [`UsingPart$clone()`](#method-UsingPart-clone)

------------------------------------------------------------------------

### `UsingPart$new()`

Initialises the join with the order to split and what each piece is
given.

#### Usage

    UsingPart$new(order, each_piece)

#### Arguments

- `order`:

  The `PlanPart` to split, which must be an `OrderPart` with exactly one
  execution, a `LadderExecution`, a `TwapExecution` or a
  `FrontLoadedExecution`, and no `inner_execution`.

- `each_piece`:

  The `PlanPart` `OrderPart` holding the presets and slot values every
  piece is given; it takes no execution and no `quantity`, names no type
  kept whole, and must not repeat a slot `order` gives, though its
  presets are added after the order's.

#### Returns

A new `UsingPart` object.

------------------------------------------------------------------------

### `UsingPart$document()`

Builds the `using` node UBI reads.

UBI takes the contents of the two orders rather than order nodes, so the
`order` key of each part's document is unwrapped.

#### Usage

    UsingPart$document()

#### Returns

A named list with the single key `using`, whose value holds `order` and
`each_piece`, each the settings of its `OrderPart`.

#### Examples

    part <- UsingPart$new(
      order = OrderPart$new(
        execution = TwapExecution$new(slices = 4, over_minutes = 60)
      ),
      each_piece = OrderPart$new(
        presets = list(
          Preset$new(
            "bracket",
            stop_price = 990.0,
            stop_limit_price = 988.0,
            target_price = 1020.0
          )
        )
      )
    )
    print(part$document())

    part <- UsingPart$new(
      order = OrderPart$new(
        execution = TwapExecution$new(slices = 3, over_minutes = 30)
      ),
      each_piece = OrderPart$new(
        pricing = MarketablePricing$new(buffer_ticks = 2)
      )
    )
    print(part$document())

    part <- UsingPart$new(
      order = OrderPart$new(
        execution = LadderExecution$new(
          from_price = 1000.0,
          to_price = 980.0,
          steps = 5
        )
      ),
      each_piece = OrderPart$new(
        presets = list(
          Preset$new(
            "bracket",
            stop_price = 970.0,
            stop_limit_price = 968.0,
            target_price = 1020.0
          )
        )
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `UsingPart$clone()`

The objects of this class are cloneable with this method.

#### Usage

    UsingPart$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- UsingPart$new(
  order = OrderPart$new(
    execution = TwapExecution$new(slices = 4, over_minutes = 60)
  ),
  each_piece = OrderPart$new(
    presets = list(
      Preset$new(
        "bracket",
        stop_price = 990.0,
        stop_limit_price = 988.0,
        target_price = 1020.0
      )
    )
  )
)
document <- part$document()
} # }

## ------------------------------------------------
## Method `UsingPart$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- UsingPart$new(
  order = OrderPart$new(
    execution = TwapExecution$new(slices = 4, over_minutes = 60)
  ),
  each_piece = OrderPart$new(
    presets = list(
      Preset$new(
        "bracket",
        stop_price = 990.0,
        stop_limit_price = 988.0,
        target_price = 1020.0
      )
    )
  )
)
print(part$document())

part <- UsingPart$new(
  order = OrderPart$new(
    execution = TwapExecution$new(slices = 3, over_minutes = 30)
  ),
  each_piece = OrderPart$new(
    pricing = MarketablePricing$new(buffer_ticks = 2)
  )
)
print(part$document())

part <- UsingPart$new(
  order = OrderPart$new(
    execution = LadderExecution$new(
      from_price = 1000.0,
      to_price = 980.0,
      steps = 5
    )
  ),
  each_piece = OrderPart$new(
    presets = list(
      Preset$new(
        "bracket",
        stop_price = 970.0,
        stop_limit_price = 968.0,
        target_price = 1020.0
      )
    )
  )
)
print(part$document())
} # }
```
