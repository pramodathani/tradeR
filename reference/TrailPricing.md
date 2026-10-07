# A pricing rule that rests a stop-limit at the broker and trails it behind the market

The `trail` pricing rule of a plan: a stop-limit at the broker that
follows the market and never moves back.

The stop is placed `points` behind the last price, or `percent` of it,
and is moved after the best price seen: a sell stop follows the highest
price up and a buy stop the lowest price down. It moves only when it can
move by at least `step_ticks`, and every move passes UBI's repricing
throttle and rate budget. Give exactly one of `points` and `percent`.

With `average_true_range`, the distance is a multiple of the average
true range of bars UBI builds from its own ticks since the order
started, and `points` is used until enough bars have closed, so this
form takes `points` rather than `percent`.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `TrailPricing`

## Public fields

- `limit_offset`:

  The numeric distance in rupees between the stop's trigger and its
  limit.

- `points`:

  The numeric trailing distance in rupees, or `NULL` when `percent` is
  given.

- `percent`:

  The numeric trailing distance as a percentage of the price, or `NULL`
  when `points` is given.

- `step_ticks`:

  The integer smallest move in ticks, or `NULL` for UBI's default of 1.

- `average_true_range`:

  A logical that is `TRUE` to trail by a multiple of the average true
  range rather than a fixed distance.

- `bar_minutes`:

  The numeric length in minutes of the bars the average true range is
  measured over, or `NULL` for UBI's default of 5.

- `periods`:

  The integer number of bars averaged, from 2 to 49 because UBI keeps
  the last 50 bars, or `NULL` for UBI's default of 14.

- `average_true_range_multiple`:

  The numeric multiple of the average true range to trail by, or `NULL`
  for UBI's default of 2.

## Methods

### Public methods

- [`TrailPricing$new()`](#method-TrailPricing-initialize)

- [`TrailPricing$document()`](#method-TrailPricing-document)

- [`TrailPricing$clone()`](#method-TrailPricing-clone)

------------------------------------------------------------------------

### `TrailPricing$new()`

Initialises the rule with its distance and limit offset.

#### Usage

    TrailPricing$new(
      limit_offset,
      points = NULL,
      percent = NULL,
      step_ticks = NULL,
      average_true_range = FALSE,
      bar_minutes = NULL,
      periods = NULL,
      average_true_range_multiple = NULL
    )

#### Arguments

- `limit_offset`:

  The numeric distance in rupees between the stop's trigger and its
  limit.

- `points`:

  The numeric trailing distance in rupees, or `NULL` when `percent` is
  given.

- `percent`:

  The numeric trailing distance as a percentage of the price, or `NULL`
  when `points` is given.

- `step_ticks`:

  The integer smallest move in ticks, or `NULL` for UBI's default of 1.

- `average_true_range`:

  A logical that is `TRUE` to trail by a multiple of the average true
  range, with `points` as the distance until enough bars have closed.

- `bar_minutes`:

  The numeric length in minutes of each bar, used with
  `average_true_range`, or `NULL` for UBI's default of 5.

- `periods`:

  The integer number of bars averaged, from 2 to 49, used with
  `average_true_range`, or `NULL` for UBI's default of 14.

- `average_true_range_multiple`:

  The numeric multiple of the average true range to trail by, used with
  `average_true_range`, or `NULL` for UBI's default of 2.

#### Returns

A new `TrailPricing` object.

------------------------------------------------------------------------

### `TrailPricing$document()`

Builds the `trail` pricing object UBI reads.

#### Usage

    TrailPricing$document()

#### Returns

A named list with the single key `trail`, whose value holds
`limit_offset`, whichever of `points` and `percent` is set, `step_ticks`
when it is set, and an `atr` object with `bar_minutes`, `periods` and
`multiple` when `average_true_range` is `TRUE`.

#### Examples

    pricing <- TrailPricing$new(points = 5.0, limit_offset = 1.0)
    print(pricing$document())

    pricing <- TrailPricing$new(
      percent = 2.0,
      limit_offset = 1.0,
      step_ticks = 4
    )
    print(pricing$document())

    pricing <- TrailPricing$new(
      points = 5.0,
      limit_offset = 1.0,
      average_true_range = TRUE,
      bar_minutes = 10,
      average_true_range_multiple = 3
    )
    print(pricing$document())

------------------------------------------------------------------------

### `TrailPricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TrailPricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
pricing <- TrailPricing$new(points = 5.0, limit_offset = 1.0)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `TrailPricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
pricing <- TrailPricing$new(points = 5.0, limit_offset = 1.0)
print(pricing$document())

pricing <- TrailPricing$new(
  percent = 2.0,
  limit_offset = 1.0,
  step_ticks = 4
)
print(pricing$document())

pricing <- TrailPricing$new(
  points = 5.0,
  limit_offset = 1.0,
  average_true_range = TRUE,
  bar_minutes = 10,
  average_true_range_multiple = 3
)
print(pricing$document())
} # }
```
