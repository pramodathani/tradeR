# The sum of a backtest's open trades

The R counterpart of `backtesting.Position` from the Python
`backtesting` package (version 0.6.5). A strategy reads it through
`BacktestStrategy$position` to learn how many units it holds and how
much they have made, and calls
[`close()`](https://rdrr.io/r/base/connections.html) to close every open
trade.

Python's `if not self.position:` becomes `if (self$position$size == 0)`,
because an R object cannot stand for a logical value.

## Active bindings

- `size`:

  The numeric number of units held: positive when long, negative when
  short and zero when flat.

- `pl`:

  The numeric profit or loss of the open trades in cash.

- `pl_pct`:

  The numeric profit or loss of the open trades in percent of what they
  cost, such as 5 for five percent, or 0 when flat.

- `is_long`:

  A logical that is `TRUE` when the position is long.

- `is_short`:

  A logical that is `TRUE` when the position is short.

## Methods

### Public methods

- [`BacktestPosition$new()`](#method-BacktestPosition-initialize)

- [`BacktestPosition$close()`](#method-BacktestPosition-close)

- [`BacktestPosition$format()`](#method-BacktestPosition-format)

- [`BacktestPosition$print()`](#method-BacktestPosition-print)

- [`BacktestPosition$clone()`](#method-BacktestPosition-clone)

------------------------------------------------------------------------

### `BacktestPosition$new()`

Creates the position of a broker; `BacktestBroker` does this once.

#### Usage

    BacktestPosition$new(broker)

#### Arguments

- `broker`:

  The `BacktestBroker` whose open trades make up the position.

#### Returns

A new `BacktestPosition` object.

------------------------------------------------------------------------

### `BacktestPosition$close()`

Places orders that close all or part of every open trade on the next
fill.

#### Usage

    BacktestPosition$close(portion = 1)

#### Arguments

- `portion`:

  The numeric fraction of each trade to close, above 0 and at most 1.

#### Details

Errors: signals `ValueError` when `portion` is not above 0 and at most
1.

#### Returns

`NULL`, invisibly.

------------------------------------------------------------------------

### `BacktestPosition$format()`

Describes the position in one line, as Python's `repr` does.

#### Usage

    BacktestPosition$format(...)

#### Arguments

- `...`:

  Ignored; present for compatibility with
  [`format()`](https://rdrr.io/r/base/format.html).

#### Returns

A character value such as `"<Position: 10 (1 trades)>"`.

------------------------------------------------------------------------

### `BacktestPosition$print()`

Prints the one-line description of the position.

#### Usage

    BacktestPosition$print(...)

#### Arguments

- `...`:

  Ignored; present for compatibility with
  [`print()`](https://rdrr.io/r/base/print.html).

#### Returns

The position, invisibly.

------------------------------------------------------------------------

### `BacktestPosition$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BacktestPosition$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
TakeProfitAtFivePercent <- R6::R6Class(
  "TakeProfitAtFivePercent",
  inherit = BacktestStrategy,
  public = list(
    initialize_strategy = function() {
      invisible(NULL)
    },
    next_candle = function() {
      if (self$position$size == 0) {
        self$buy()
      } else if (self$position$pl_pct > 5) {
        self$position$close()
      }
    }
  )
)
} # }
```
