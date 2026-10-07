# A pricing rule that rests a stop-limit at the broker and steps it through profit milestones

The `stages` pricing rule of a plan: a stop-limit at the broker that
profit milestones move in the position's favour.

The stop starts at `stop_price`, with its limit `limit_offset` past the
trigger, and rests at the broker the whole time. Each `StageRule` names
a gain from `entry_price`, and once the market reaches it the stop is
modified to the rule's `stop_at_gain`, or handed to a trail of
`trail_points`. The stop only ever moves in the position's favour, by at
least `step_ticks`, so a rule that would loosen it is skipped. UBI takes
1 to 20 rules with rising gains, each with exactly one of `stop_at_gain`
and `trail_points`, and only the last may trail. Like every stop, it
cannot be split into pieces.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `StagesPricing`

## Public fields

- `entry_price`:

  The numeric price in rupees the gains are measured from.

- `stop_price`:

  The numeric price in rupees where the stop starts.

- `limit_offset`:

  The numeric distance in rupees between the stop's trigger and its
  limit.

- `rules`:

  The list of `PlanPart` milestones, `StageRule` objects, in order of
  rising gain.

- `step_ticks`:

  The integer smallest move in ticks, or `NULL` for UBI's default of 1.

## Methods

### Public methods

- [`StagesPricing$new()`](#method-StagesPricing-initialize)

- [`StagesPricing$document()`](#method-StagesPricing-document)

- [`StagesPricing$clone()`](#method-StagesPricing-clone)

------------------------------------------------------------------------

### `StagesPricing$new()`

Initialises the rule with its prices and milestones.

#### Usage

    StagesPricing$new(
      entry_price,
      stop_price,
      limit_offset,
      rules,
      step_ticks = NULL
    )

#### Arguments

- `entry_price`:

  The numeric price in rupees the gains are measured from, usually where
  the position was opened.

- `stop_price`:

  The numeric price in rupees where the stop starts.

- `limit_offset`:

  The numeric distance in rupees between the stop's trigger and its
  limit.

- `rules`:

  A list of 1 to 20 `StageRule` objects, each with a larger gain than
  the one before, of which only the last may trail.

- `step_ticks`:

  The integer smallest move in ticks, or `NULL` for UBI's default of 1.

#### Returns

A new `StagesPricing` object.

------------------------------------------------------------------------

### `StagesPricing$document()`

Builds the `stages` pricing object UBI reads.

#### Usage

    StagesPricing$document()

#### Returns

A named list with the single key `stages`, whose value holds
`entry_price`, `stop_price`, `limit_offset`, `step_ticks` when it is
set, and `rules` as a list of each milestone's object.

#### Examples

    pricing <- StagesPricing$new(
      entry_price = 1000.0,
      stop_price = 990.0,
      limit_offset = 1.0,
      rules = list(
        StageRule$new(gain = 10.0, stop_at_gain = 0.0),
        StageRule$new(gain = 20.0, stop_at_gain = 5.0)
      )
    )
    print(pricing$document())

    pricing <- StagesPricing$new(
      entry_price = 1000.0,
      stop_price = 990.0,
      limit_offset = 1.0,
      rules = list(
        StageRule$new(gain = 10.0, stop_at_gain = 0.0),
        StageRule$new(gain = 25.0, trail_points = 8.0)
      ),
      step_ticks = 2
    )
    print(pricing$document())

------------------------------------------------------------------------

### `StagesPricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    StagesPricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
pricing <- StagesPricing$new(
  entry_price = 1000.0,
  stop_price = 990.0,
  limit_offset = 1.0,
  rules = list(
    StageRule$new(gain = 10.0, stop_at_gain = 0.0),
    StageRule$new(gain = 25.0, trail_points = 8.0)
  )
)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `StagesPricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
pricing <- StagesPricing$new(
  entry_price = 1000.0,
  stop_price = 990.0,
  limit_offset = 1.0,
  rules = list(
    StageRule$new(gain = 10.0, stop_at_gain = 0.0),
    StageRule$new(gain = 20.0, stop_at_gain = 5.0)
  )
)
print(pricing$document())

pricing <- StagesPricing$new(
  entry_price = 1000.0,
  stop_price = 990.0,
  limit_offset = 1.0,
  rules = list(
    StageRule$new(gain = 10.0, stop_at_gain = 0.0),
    StageRule$new(gain = 25.0, trail_points = 8.0)
  ),
  step_ticks = 2
)
print(pricing$document())
} # }
```
