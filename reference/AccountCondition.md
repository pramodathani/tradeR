# A condition that holds when a figure from the account is at or past a level

The `account` trigger of a plan: a figure from the whole account
reaching a level, rather than a price.

The figure is `available_balance`, the free margin across every broker;
`day_pnl`, the day's realized and unrealized profit across every broker;
or `open_positions`, how many net positions are open. All three settings
are required, the direction too, because nothing about an order says
which way an account figure should move. The condition reads no quotes,
so UBI checks it once a second on the clock.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `AccountCondition`

## Public fields

- `field`:

  The character figure, `available_balance`, `day_pnl` or
  `open_positions`.

- `level`:

  The numeric level the figure is compared with, in rupees or, for
  `open_positions`, a count.

- `direction`:

  The character direction, `at_or_above` or `at_or_below`.

## Methods

### Public methods

- [`AccountCondition$new()`](#method-AccountCondition-initialize)

- [`AccountCondition$document()`](#method-AccountCondition-document)

- [`AccountCondition$clone()`](#method-AccountCondition-clone)

------------------------------------------------------------------------

### `AccountCondition$new()`

Initialises the condition with its figure, level and direction.

#### Usage

    AccountCondition$new(field, level, direction)

#### Arguments

- `field`:

  The character figure, `available_balance` for the free margin across
  every broker, `day_pnl` for the day's realized plus unrealized profit
  across every broker, or `open_positions` for the count of open net
  positions.

- `level`:

  The numeric level, in rupees for the two money figures and a count for
  `open_positions`.

- `direction`:

  The character direction, `at_or_above` or `at_or_below`, which is
  required.

#### Returns

A new `AccountCondition` object.

------------------------------------------------------------------------

### `AccountCondition$document()`

Builds the `account` condition UBI reads.

#### Usage

    AccountCondition$document()

#### Returns

A named list with the single key `account`, whose value holds `field`,
`level` and `direction`.

#### Examples

    condition <- AccountCondition$new(
      field = "day_pnl",
      level = -5000.0,
      direction = "at_or_below"
    )
    print(condition$document())

    part <- OrderPart$new(
      trigger = AccountCondition$new(
        field = "available_balance",
        level = 50000.0,
        direction = "at_or_above"
      )
    )
    print(part$document())

    condition <- AccountCondition$new(
      field = "open_positions",
      level = 0,
      direction = "at_or_below"
    )
    print(condition$document())

------------------------------------------------------------------------

### `AccountCondition$clone()`

The objects of this class are cloneable with this method.

#### Usage

    AccountCondition$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- AccountCondition$new(
  field = "day_pnl",
  level = -5000.0,
  direction = "at_or_below"
)
document <- condition$document()
} # }

## ------------------------------------------------
## Method `AccountCondition$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
condition <- AccountCondition$new(
  field = "day_pnl",
  level = -5000.0,
  direction = "at_or_below"
)
print(condition$document())

part <- OrderPart$new(
  trigger = AccountCondition$new(
    field = "available_balance",
    level = 50000.0,
    direction = "at_or_above"
  )
)
print(part$document())

condition <- AccountCondition$new(
  field = "open_positions",
  level = 0,
  direction = "at_or_below"
)
print(condition$document())
} # }
```
