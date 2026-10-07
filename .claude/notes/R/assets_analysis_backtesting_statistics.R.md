# R/assets_analysis_backtesting_statistics.R

`BacktestStatistics` is the R counterpart of `compute_stats()` and `compute_drawdown_duration_peaks()` in backtesting.py 0.6.5's `_stats.py`. Every statistic follows the Python formula, including the ones that look odd:

- `Return (Ann.) [%]` compounds the geometric mean of the daily equity returns, where the first day's missing return counts as zero in the mean.
- `Volatility (Ann.) [%]` uses the compounding formula from the paper backtesting.py cites (SSRN 3054517), with the variance of the daily returns.
- `CAGR [%]` divides the calendar days of the whole range by 252 (or 365), as backtesting.py does.
- The year has 252 periods, or 365 when weekend candles are more than 60 percent of the expected two days in seven; weekly, monthly and yearly candles use 52, 12 and 1. The candle gap is the median of the last 100 gaps.
- Daily returns take the last equity of each calendar day in India time, which is what pandas `resample("D").last()` does on an index in Asia/Kolkata. Weekly bins end on Sunday, as pandas `W` does.
- `Buy & Hold Return [%]` starts at the first candle on which every indicator has a value.
- `Alpha [%]` and `Beta` come from the log returns of the equity and of the close over every candle.
- `Avg. Trade [%]` is the geometric mean of the trade returns, and 0 when any trade lost everything.
- `Profit Factor`, `SQN` and `Sharpe Ratio` turn a zero divisor into `NaN`, as Python's `value or np.nan` does.

## Differences in form

- The result is a named list. `Start` and `End` are `POSIXct`; `Duration` and the four duration statistics are `difftime` values in days, rounded up to the candle resolution (whole days for day candles, whole minutes for minute candles), as backtesting.py's `Timedelta.ceil` does. A statistic that pandas gives as `NaT` is an `NA` `difftime`.
- `_equity_curve` is a `data.frame` with a `datetime` column first, because R data frames have no index; `_trades` likewise has `EntryTime` and `ExitTime` columns. `EntryBar` and `ExitBar` count from 1.
- Indicator columns in `_trades` are named `Entry_<name>` and `Exit_<name>` after the names the strategy gave, where Python names them after the function call, such as `Entry_SMA(C,10)`.
- When no drawdown ever ends, pandas returns the drawdown fractions themselves as the "durations", so `Max. Drawdown Duration` becomes a number rather than a time. The R version reproduces this literally (`are_durations` is then `FALSE`) so results match.
- The risk-free rate check was an `assert`; here it is a `ValueError`.
