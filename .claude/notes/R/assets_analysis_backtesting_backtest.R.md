# R/assets_analysis_backtesting_backtest.R

`Backtest` is the R counterpart of `backtesting.Backtest` from backtesting.py 0.6.5 (installed in the tradingmachine virtual environment at `.venv/lib/python3.14/site-packages/backtesting/`). It was written on 2026-10-07 for `StrategyBacktests$run_backtest()` and keeps only what that method exposes.

## The run loop, as in `Backtest.run()`

1. Build a `BacktestBroker` and the strategy, and call `initialize_strategy()` while the strategy sees every candle.
2. Start at candle `warmup + 2`, counting from 1, where `warmup` is the number of leading candles in which some indicator is still `NA`. backtesting.py starts at index `1 + warmup` counting from 0, which is the same candle.
3. On each candle the broker fills orders and records the equity first, then `next_candle()` runs. An equity at or below zero closes every trade at that close, sets the rest of the equity curve to 0 and ends the run.
4. Candles before the start take the first recorded equity (pandas `bfill`), and any candle still without one takes the final cash (`fillna(cash)`).
5. `BacktestStatistics` builds the table with a risk-free rate of 0.

Trades still open at the end are left open, as with backtesting.py's default `finalize_trades=False`: they count in the equity curve but not in the trade statistics, and a warning says so. The warning was reworded because the Python text names a `finalize_trades` argument the R engine does not have.

## Left out on purpose

The bid-ask `spread`, commission given as a tuple or a function, strategy parameters passed to `run(**kwargs)`, `finalize_trades`, `optimize()` and the `_Orders.cancel()` helper are not ported, because `run_backtest()` never uses them. backtesting.py's own checks are `assert` statements and `AssertionError`; here they signal `ValueError` or `TypeError` through `ErrorCatalogue`.

## Plotting

`plot()` writes the page described in `assets_analysis_backtesting_plot.R.md`. Without `results` it uses the latest run, running the backtest first if there has been none, which mirrors backtesting.py.

## Speed

The parity runs of 400 candles take 0.03 to 0.15 seconds each. A moving average cross over 10,000 synthetic 5-minute candles took 1.5 seconds. `self$data` and `self$indicators` copy the visible part on every access, so the cost grows with the square of the candle count for strategies that read them on every candle; a strategy on several years of 1-minute candles should read only what it needs.
