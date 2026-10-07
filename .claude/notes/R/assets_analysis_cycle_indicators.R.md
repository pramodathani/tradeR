# R/assets_analysis_cycle_indicators.R

Port of `src/tradingmachine/assets/analysis/cycle_indicators.py`: `CycleIndicators`. The six Hilbert transform methods, with unchanged names and column labels. TA-Lib reports a lookback of 32 candles for `HT_DCPERIOD` and `HT_PHASOR`, and 63 for `HT_DCPHASE`, `HT_SINE`, `HT_TRENDMODE` and `HT_TRENDLINE`, so a short range returns columns that are mostly or entirely empty.

The class is a link in the single chain of analysis classes described in `assets_instruments.R.md`, inheriting `VolumeIndicators`; keep that `inherit =` line, because the order of the chain is fixed across the fourteen analysis files.

## Calling TA-Lib from R

R's `talib` package (0.9.4) wraps the same TA-Lib C library as Python's `talib` (0.6.8). Its functions, here `HT_DCPERIOD`, `HT_DCPHASE`, `HT_PHASOR`, `HT_SINE`, `HT_TRENDMODE` and `HT_TRENDLINE`, take a data.frame and find their inputs by column name through a formula in `cols`, defaulting to `~ high + low + close` and the like. Each method therefore builds a small data.frame whose columns carry exactly those default names, converted with `as.numeric()`, and calls the function without `cols`, so no formula or tidy evaluation is needed. The result is a one- or two-column data.frame carrying a `lookback` attribute; `as.numeric(indicator[[1]])` turns a column into a plain numeric vector and drops the attribute. During the lookback R's talib gives `NA` where Python's gives `NaN`, which is the same missing value in a data frame.

The one place R's talib and Python's differ in output is `HT_TRENDMODE`: Python's returns an integer array with `0` during the 63-candle warm-up, because a NumPy integer cannot hold `NaN`, while R's returns `NA` there. `hilbert_transform_trend_mode()` replaces those `NA`s with `0L`, so the column is an integer vector with the same values as Python's, and counting trending days with `sum()` works without `na.rm`. `HT_PHASOR` and `HT_SINE` return two columns, read by position into `inphase` and `quadrature`, and `sine` and `lead_sine`. The column is passed to TA-Lib under the name `close`, whichever candle column was chosen.

## Parity

Every method was run in Python and R on five fixtures in the session scratchpad (`parity/analysis_group_1/`): 400 synthetic candles, the same with missing closes and volumes, a second 400-candle series, three candles, and six identical candles. Every output column matched, with the largest relative difference about 4e-13 (in the Chaikin oscillator, whose exponential averages accumulate rounding); the rest were exact or within 1e-13. Missing inputs propagate the same way in both languages.
