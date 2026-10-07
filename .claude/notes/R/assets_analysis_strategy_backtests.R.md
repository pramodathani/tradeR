# R/assets_analysis_strategy_backtests.R

Port of `src/tradingmachine/assets/analysis/strategy_backtests.py`, ported on 2026-10-07. `run_backtest()` fetches candles with `prices()`, keeps `open`, `high`, `low`, `close` and `volume` by name (UBI also sends `oi` and `price_factor`), renames them to the capitalised names strategies use, and runs them through `Backtest`.

## Why there is a native engine

The Python method hands the candles to the Python `backtesting` package (backtesting.py 0.6.5). R has no package with the same interface, so the user's choice to port natively meant writing a small engine: `Backtest`, `BacktestBroker`, `BacktestStrategy`, `BacktestOrder`, `BacktestTrade`, `BacktestPosition`, `BacktestStatistics` and `BacktestPlot`, each in its own `R/assets_analysis_backtesting_*.R` file. Their notes describe how each follows backtesting.py.

## Differences from Python

- `strategy` is an R6 class generator inheriting `BacktestStrategy`, whose hooks are `initialize_strategy()` and `next_candle()` instead of `init()` and `next()`, and whose indicators are declared by name with `self$indicator(name, values)` and read back as `self$indicators$name`. See `assets_analysis_backtesting_strategy.R.md`.
- The result is a named list rather than a pandas Series, with the same names in the same order, durations as `difftime` values in days, and trade candle numbers counted from 1.
- `plot_filename` writes a plain, self-contained HTML page (line charts of the close with the entries and exits marked, and of the equity, plus the statistics and the trades) instead of backtesting.py's interactive Bokeh chart, because Bokeh has no R counterpart without new dependencies. As in Python, nothing is written when it is `NULL`, and the file is never opened.

## Verified on 2026-10-07

Fourteen backtests on the parity fixtures, covering a moving average cross with each of commission, `trade_on_close`, `exclusive_orders`, a margin of 0.5 and too little cash, buy and hold with commission, an RSI strategy, stop-loss and take-profit brackets, stop and limit entries with partial closes, fixed-size orders with and without hedging, and two runs on 5-minute candles, gave the same trades on the same candles at the same prices as backtesting.py. The largest relative difference in any statistic was 2.7e-14, and every duration matched to the second. The scripts and tables are in the session scratchpad under `parity/analysis_group_4/`.
