# R/assets_analysis_price_transforms.R

Port of `src/tradingmachine/assets/analysis/price_transforms.py`: `PriceTransforms`. The four TA-Lib price transforms, with unchanged column labels `avg_price`, `med_price`, `typ_price` and `wght_close`.

The class is a link in the single chain of analysis classes described in `assets_instruments.R.md`, inheriting `CycleIndicators`; keep that `inherit =` line, because the order of the chain is fixed across the fourteen analysis files.

## Calling TA-Lib from R

R's `talib` package (0.9.4) wraps the same TA-Lib C library as Python's `talib` (0.6.8). Its functions, here `AVGPRICE`, `MEDPRICE`, `TYPPRICE` and `WCLPRICE`, take a data.frame and find their inputs by column name through a formula in `cols`, defaulting to `~ high + low + close` and the like. Each method therefore builds a small data.frame whose columns carry exactly those default names, converted with `as.numeric()`, and calls the function without `cols`, so no formula or tidy evaluation is needed. The result is a one- or two-column data.frame carrying a `lookback` attribute; `as.numeric(indicator[[1]])` turns a column into a plain numeric vector and drops the attribute. During the lookback R's talib gives `NA` where Python's gives `NaN`, which is the same missing value in a data frame.

`average_price()` here is TA-Lib's average of each candle's open, high, low and close. It is unrelated to the `average_price` field in UBI's quote, which is the day's volume weighted average price and is read by `TradeableInstrument$volume_weighted_average_price`.

## Parity

Every method was run in Python and R on five fixtures in the session scratchpad (`parity/analysis_group_1/`): 400 synthetic candles, the same with missing closes and volumes, a second 400-candle series, three candles, and six identical candles. Every output column matched, with the largest relative difference about 4e-13 (in the Chaikin oscillator, whose exponential averages accumulate rounding); the rest were exact or within 1e-13. Missing inputs propagate the same way in both languages.
