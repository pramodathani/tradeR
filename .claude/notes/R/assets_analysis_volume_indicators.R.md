# R/assets_analysis_volume_indicators.R

Port of `src/tradingmachine/assets/analysis/volume_indicators.py`: `VolumeIndicators`. The three TA-Lib volume indicators, `chaikin_accumulation_distribution_line` (renamed from `chaikin_ad_line` in Python on 2026-09-14), `chaikin_accumulation_distribution_oscillator` (from `chaikin_ad_oscillator`) and `on_balance_volume`. The column labels `chaikin_ad`, `chaikin_adosc<fast>_<slow>` (no underscore before the fast period) and `obv` are unchanged.

The class is a link in the single chain of analysis classes described in `assets_instruments.R.md`, inheriting `MomentumIndicators`; keep that `inherit =` line, because the order of the chain is fixed across the fourteen analysis files.

## Calling TA-Lib from R

R's `talib` package (0.9.4) wraps the same TA-Lib C library as Python's `talib` (0.6.8). Its functions, here `AD`, `ADOSC` and `OBV`, take a data.frame and find their inputs by column name through a formula in `cols`, defaulting to `~ high + low + close` and the like. Each method therefore builds a small data.frame whose columns carry exactly those default names, converted with `as.numeric()`, and calls the function without `cols`, so no formula or tidy evaluation is needed. The result is a one- or two-column data.frame carrying a `lookback` attribute; `as.numeric(indicator[[1]])` turns a column into a plain numeric vector and drops the attribute. During the lookback R's talib gives `NA` where Python's gives `NaN`, which is the same missing value in a data frame.

UBI's candle `volume` is a whole number, or null where a value overflowed, so it may arrive as an R integer; every input is converted with `as.numeric()` before it reaches TA-Lib. `on_balance_volume(column = ...)` passes the chosen column to TA-Lib under the name `close`, because R's talib finds its inputs by column name. R's talib names the ADOSC arguments `fastPeriod` and `slowPeriod`; the R method keeps Python's `fast_period` and `slow_period`.

## Parity

Every method was run in Python and R on five fixtures in the session scratchpad (`parity/analysis_group_1/`): 400 synthetic candles, the same with missing closes and volumes, a second 400-candle series, three candles, and six identical candles. Every output column matched, with the largest relative difference about 4e-13 (in the Chaikin oscillator, whose exponential averages accumulate rounding); the rest were exact or within 1e-13. Missing inputs propagate the same way in both languages.
