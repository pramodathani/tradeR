# One milestone of a stepped stop, an entry of the `rules` list of `StagesPricing`

One milestone of a `stages` stop: a gain that, once reached, moves the
stop or hands it to a trail.

The `gain` is measured from the stop's entry price in the position's
favour. A rule with `stop_at_gain` moves the stop to that gain measured
the same way, so 0 is breakeven, and a rule with `trail_points` hands
the rest of the trade to an ordinary trail that many rupees behind. A
rule takes exactly one of the two, and a trailing rule must be the last
one.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `StageRule`

## Public fields

- `gain`:

  The numeric gain in rupees, from the entry price in the position's
  favour, that applies the rule.

- `stop_at_gain`:

  The numeric gain in rupees where the stop goes, below `gain`, with 0
  for breakeven, or `NULL` when `trail_points` is given.

- `trail_points`:

  The numeric distance in rupees the stop trails from here on, or `NULL`
  when `stop_at_gain` is given.

## Methods

### Public methods

- [`StageRule$new()`](#method-StageRule-initialize)

- [`StageRule$document()`](#method-StageRule-document)

- [`StageRule$clone()`](#method-StageRule-clone)

------------------------------------------------------------------------

### `StageRule$new()`

Initialises the milestone with its gain and what happens there.

#### Usage

    StageRule$new(gain, stop_at_gain = NULL, trail_points = NULL)

#### Arguments

- `gain`:

  The numeric gain in rupees, above zero, from the entry price in the
  position's favour, that applies the rule.

- `stop_at_gain`:

  The numeric gain in rupees where the stop goes, below `gain`, with 0
  for breakeven and a negative value for a smaller loss, or `NULL` when
  `trail_points` is given.

- `trail_points`:

  The numeric distance in rupees the stop trails behind the market from
  here on, or `NULL` when `stop_at_gain` is given.

#### Returns

A new `StageRule` object.

------------------------------------------------------------------------

### `StageRule$document()`

Builds the milestone object UBI reads as one entry of a `stages` rule
list.

#### Usage

    StageRule$document()

#### Returns

A named list holding `gain` and whichever of `stop_at_gain` and
`trail_points` is set, directly rather than under a name, because it is
an entry of a list.

#### Examples

    rule <- StageRule$new(gain = 10.0, stop_at_gain = 0.0)
    print(rule$document())

    rule <- StageRule$new(gain = 30.0, trail_points = 5.0)
    print(rule$document())

------------------------------------------------------------------------

### `StageRule$clone()`

The objects of this class are cloneable with this method.

#### Usage

    StageRule$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
rule <- StageRule$new(gain = 10.0, stop_at_gain = 0.0)
entry <- rule$document()
} # }

## ------------------------------------------------
## Method `StageRule$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
rule <- StageRule$new(gain = 10.0, stop_at_gain = 0.0)
print(rule$document())

rule <- StageRule$new(gain = 30.0, trail_points = 5.0)
print(rule$document())
} # }
```
