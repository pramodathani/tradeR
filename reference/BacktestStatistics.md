# The statistics table of a finished backtest

The R counterpart of `compute_stats` in the Python `backtesting` package
(version 0.6.5). It turns the closed trades and the equity of every
candle into the same named statistics backtesting.py returns, in the
same order, from `Start` to `Kelly Criterion`, followed by `_strategy`,
`_equity_curve` and `_trades`.

Durations are `difftime` values in days, rounded up to the resolution of
the candles, so whole days for `day` candles and whole minutes for
minute candles, as backtesting.py rounds its `Timedelta` values. Candle
numbers in `_trades` count from 1.

## Public fields

- `trades`:

  A list of the closed `BacktestTrade` objects.

- `equity`:

  A numeric vector with the equity at the end of every candle.

- `candles`:

  The `data.frame` of candles with `datetime` and `Close` columns.

- `strategy`:

  The `BacktestStrategy` that ran, or `NULL`.

- `risk_free_rate`:

  The numeric annual risk-free rate as a fraction, above -1 and below 1.

## Methods

### Public methods

- [`BacktestStatistics$new()`](#method-BacktestStatistics-initialize)

- [`BacktestStatistics$trade_frame()`](#method-BacktestStatistics-trade_frame)

- [`BacktestStatistics$compute()`](#method-BacktestStatistics-compute)

- [`BacktestStatistics$clone()`](#method-BacktestStatistics-clone)

------------------------------------------------------------------------

### `BacktestStatistics$new()`

Collects what the statistics are calculated from.

#### Usage

    BacktestStatistics$new(
      trades,
      equity,
      candles,
      strategy = NULL,
      risk_free_rate = 0
    )

#### Arguments

- `trades`:

  A list of the closed `BacktestTrade` objects.

- `equity`:

  A numeric vector with the equity at the end of every candle, without
  missing values.

- `candles`:

  The `data.frame` of candles with `datetime` and `Close` columns.

- `strategy`:

  The `BacktestStrategy` that ran, or `NULL`.

- `risk_free_rate`:

  The numeric annual risk-free rate as a fraction.

#### Details

Errors: signals `ValueError` when `risk_free_rate` is not above -1 and
below 1.

#### Returns

A new `BacktestStatistics` object.

------------------------------------------------------------------------

### `BacktestStatistics$trade_frame()`

Builds the table of closed trades.

#### Usage

    BacktestStatistics$trade_frame()

#### Returns

A `data.frame` with one row per closed trade and the columns `Size`,
`EntryBar`, `ExitBar`, `EntryPrice`, `ExitPrice`, `SL`, `TP`, `PnL`,
`Commission`, `ReturnPct`, `EntryTime`, `ExitTime`, `Duration` and
`Tag`, then `Entry_<name>` and `Exit_<name>` for each indicator when
there are trades.

------------------------------------------------------------------------

### `BacktestStatistics$compute()`

Calculates every statistic.

#### Usage

    BacktestStatistics$compute()

#### Returns

A named list with the entries `Start`, `End`, `Duration`,
`Exposure Time [%]`, `Equity Final [$]`, `Equity Peak [$]`,
`Commissions [$]` when any commission was paid, `Return [%]`,
`Buy & Hold Return [%]`, `Return (Ann.) [%]`, `Volatility (Ann.) [%]`,
`CAGR [%]`, `Sharpe Ratio`, `Sortino Ratio`, `Calmar Ratio`,
`Alpha [%]`, `Beta`, `Max. Drawdown [%]`, `Avg. Drawdown [%]`,
`Max. Drawdown Duration`, `Avg. Drawdown Duration`, `# Trades`,
`Win Rate [%]`, `Best Trade [%]`, `Worst Trade [%]`, `Avg. Trade [%]`,
`Max. Trade Duration`, `Avg. Trade Duration`, `Profit Factor`,
`Expectancy [%]`, `SQN`, `Kelly Criterion`, `_strategy` (the strategy
object), `_equity_curve` (a `data.frame` with `datetime`, `Equity`,
`DrawdownPct` and `DrawdownDuration`) and `_trades` (from
`trade_frame()`). A value that cannot be calculated is `NaN` or `NA`.

------------------------------------------------------------------------

### `BacktestStatistics$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BacktestStatistics$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
backtest <- Backtest$new(candles, MovingAverageCross, cash = 100000)
statistics <- backtest$run()
statistics[["Sharpe Ratio"]]
head(statistics[["_trades"]])
} # }
```
