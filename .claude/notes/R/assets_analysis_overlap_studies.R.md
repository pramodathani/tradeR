# R/assets_analysis_overlap_studies.R

Port of `src/tradingmachine/assets/analysis/overlap_studies.py`, ported on 2026-10-07. `OverlapStudies` holds the twelve TA-Lib overlap studies. In R it is one link of the single analysis chain (`PriceStatistics` before it, `MomentumIndicators` after it), as `.claude/notes/R/assets_instruments.R.md` explains. Method names, argument names, argument order, defaults and the column labels the methods add are the same as in Python.

## Carried over from the Python note

- `triple_exponential_moving_average` calls TA-Lib's T3 (Tillson), not TEMA, and labels its column `t3_<window>`. The old name was kept on purpose.
- `bollinger_bands` adds `bb_upper_<window>`, `bb_middle_<window>` and `bb_lower_<window>`.
- `mesa_adaptive_moving_average` has no window; it takes only the two limits.
- Parameter renames from the old project (`standard_deviations_up` and `standard_deviations_down`, `volume_factor`, `fast_limit` and `slow_limit`) are kept.

## How TA-Lib is called from R

The CRAN package `talib` (version 0.9.4) wraps TA-Lib's C library, as Python's `talib` does. It is called in two ways.

| Input | Call | What comes back |
|---|---|---|
| One candle column | `talib::SMA(prices[[column]], timePeriod = window)`, the numeric method | A plain vector, or a matrix with named columns for several outputs |
| Several candle columns (SAR, MIDPRICE) | `talib::SAR(prices, cols = ~ high + low, ...)`, the data frame method with a literal formula | A data frame with one column per output |

Every result is wrapped in `as.numeric()`, which drops the `lookback` attribute `talib` attaches, so each new column is a plain numeric vector. Multi-output results are picked by `talib`'s output names (`UpperBand`, `MiddleBand`, `LowerBand`, `MAMA`, `FAMA`, `SAR`, `MIDPRICE`), never by position. The formulas are written out as literals rather than built from strings, so no tidy evaluation is involved.

The argument names differ from Python's `talib`: `timePeriod` for `timeperiod`, `deviationsUp` and `deviationsDown` for `nbdevup` and `nbdevdn`, `volumeFactor` for `vfactor`, `fastLimit` and `slowLimit` for `fastlimit` and `slowlimit`, and `accelerationFactor` and `afMaximum` for `acceleration` and `maximum`. `bollinger_bands` passes `maType = 0` explicitly, which is Python's default; `talib::BBANDS` also defaults to 0 but is not relied on. `talib::MAMA` has a `timePeriod` argument that it never passes to C, so it is left out.

## Differences from Python

- The warm-up rows that Python fills with `NaN` hold `NA` in R. The positions are the same for every method; the parity check confirmed this.
- `paste0()` builds the labels, so a window of `20` gives `sma_20`, as Python's f-string does. A window written as `1e5` would print as `1e+05`, which Python would not do, but windows that large are not meaningful.
- R's `talib` bundles TA-Lib C 0.8.1, while the Python environment links TA-Lib C 0.6.4. Some functions were rewritten between those versions, using fused multiply-add for example. The results therefore differ in the last few digits: the largest relative difference was 2.8e-13, for Bollinger bands. See `.claude/notes/R/assets_analysis_momentum_indicators.R.md` for the one case where the versions differ by more.

## Parity check

On 2026-10-07 every method was run in Python and in R on the 400 fixture candles in the session scratchpad (`parity/candles.csv`). Each method was run with its defaults, with non-default arguments and on an 8-candle frame shorter than most lookbacks. The scripts, the outputs and `summary.md` are in `parity/analysis_group_2/` in that scratchpad. All overlap cases matched within a relative difference of 1e-9, with identical column names and identical `NA` positions.
