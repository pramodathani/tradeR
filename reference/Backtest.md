# One backtest of a strategy over a table of candles

The R counterpart of `backtesting.Backtest` from the Python
`backtesting` package (version 0.6.5), kept to the features
`StrategyBacktests$run_backtest()` uses: starting cash, a commission as
a fraction of each fill, margin, filling market orders at the close,
hedging and exclusive orders. The bid-ask spread, commission functions,
strategy parameters, `finalize_trades` and optimisation are left out.

`run()` creates the strategy, calls its `initialize_strategy()`, then
walks the candles from the first one on which every indicator has a
value, plus one. On each candle the broker first fills the waiting
orders and records the equity, and then the strategy's `next_candle()`
decides what to do. Trades still open after the last candle are not
closed, so they count in the equity but not in the trade statistics, as
in backtesting.py.

## Public fields

- `candles`:

  The `data.frame` of candles with `datetime`, `Open`, `High`, `Low`,
  `Close` and `Volume` columns, oldest first.

- `strategy`:

  The R6 class generator of the strategy, a subclass of
  `BacktestStrategy`.

- `cash`:

  The numeric starting cash.

- `commission`:

  The numeric commission as a fraction of each fill's value.

- `margin`:

  The numeric margin as a fraction, where 1 means no leverage.

- `trade_on_close`:

  A logical that is `TRUE` to fill market orders at the current candle's
  close.

- `hedging`:

  A logical that is `TRUE` to allow long and short trades at the same
  time.

- `exclusive_orders`:

  A logical that is `TRUE` to close the open trades whenever a new order
  is placed.

- `results`:

  The named list of statistics from the latest `run()`, or `NULL` before
  the first run.

## Methods

### Public methods

- [`Backtest$new()`](#method-Backtest-initialize)

- [`Backtest$run()`](#method-Backtest-run)

- [`Backtest$plot()`](#method-Backtest-plot)

- [`Backtest$clone()`](#method-Backtest-clone)

------------------------------------------------------------------------

### `Backtest$new()`

Checks the candles and the strategy and stores the settings.

#### Usage

    Backtest$new(
      data,
      strategy,
      cash = 10000,
      commission = 0,
      margin = 1,
      trade_on_close = FALSE,
      hedging = FALSE,
      exclusive_orders = FALSE
    )

#### Arguments

- `data`:

  A `data.frame` with `datetime`, `Open`, `High`, `Low` and `Close`
  columns, and optionally `Volume`.

- `strategy`:

  The R6 class generator of a strategy that inherits `BacktestStrategy`.

- `cash`:

  The numeric starting cash.

- `commission`:

  The numeric commission charged on each fill, as a fraction of its
  value.

- `margin`:

  The numeric margin required, as a fraction, where 1.0 means no
  leverage.

- `trade_on_close`:

  A logical that is `TRUE` to fill market orders at the current candle's
  close rather than the next candle's open.

- `hedging`:

  A logical that is `TRUE` to allow long and short trades at the same
  time.

- `exclusive_orders`:

  A logical that is `TRUE` to close the open trade whenever a new order
  is placed.

#### Details

Errors: signals `TypeError` when `strategy` is not a class generator
inheriting `BacktestStrategy` or `data` is not a `data.frame`;
`ValueError` when `data` is empty, lacks a column or has a missing
price. Warns when a close is above the starting cash or the candles were
not in time order.

#### Returns

A new `Backtest` object.

------------------------------------------------------------------------

### `Backtest$run()`

Runs the strategy over the candles.

#### Usage

    Backtest$run()

#### Details

Errors: signals `ValueError` when the cash, commission or margin is
outside its allowed range, and passes on any error the strategy signals.
Warns when trades remain open at the end.

#### Returns

A named list of statistics, as `BacktestStatistics$compute()` describes,
from `Start` to `Kelly Criterion` followed by `_strategy`,
`_equity_curve` and `_trades`.

------------------------------------------------------------------------

### `Backtest$plot()`

Writes a standalone HTML page with the price, the trades, the equity
curve and the statistics of a run.

#### Usage

    Backtest$plot(results = NULL, filename = NULL)

#### Arguments

- `results`:

  The named list of statistics from `run()`, or `NULL` to use the latest
  run, running the backtest first when there is none.

- `filename`:

  The character path of the HTML file to write.

#### Details

Errors: signals `ValueError` when `filename` is `NULL`.

#### Returns

The character `filename`, invisibly.

------------------------------------------------------------------------

### `Backtest$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Backtest$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
BuyAndHold <- R6::R6Class(
  "BuyAndHold",
  inherit = BacktestStrategy,
  public = list(
    initialize_strategy = function() {
      invisible(NULL)
    },
    next_candle = function() {
      if (self$position$size == 0) {
        self$buy()
      }
    }
  )
)
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
prices <- nifty$prices(days = 365)
candles <- data.frame(
  datetime = prices$datetime,
  Open = prices$open,
  High = prices$high,
  Low = prices$low,
  Close = prices$close,
  Volume = prices$volume
)
backtest <- Backtest$new(candles, BuyAndHold, cash = 10000000)
statistics <- backtest$run()
statistics[["Return [%]"]]
backtest$plot(results = statistics, filename = file.path(tempdir(), "nifty.html"))
} # }
```
