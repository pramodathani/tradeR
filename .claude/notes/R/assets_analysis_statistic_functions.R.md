# R/assets_analysis_statistic_functions.R

Port of `src/tradingmachine/assets/analysis/statistic_functions.py`, ported on 2026-10-07. `StatisticFunctions` is the link of the analysis chain after `VolatilityIndicators` (see `assets_instruments.R.md`). Method names, argument order and column labels (`beta_<window>`, `corr_<window>`, `lin_regr_<window>`, `lin_regr_slope_<window>`, `lin_regr_int_<window>`, `lin_regr_angle_<window>`, `std_dev_<window>`, `var_<window>`, `benchmark_<column>`) are the Python ones.

## Carried over from the Python note

- `beta()` and `correlation_coefficient()` take a required `benchmark`, any object with a `prices()` method, and match its candles to the instrument's by `datetime`, keeping only moments both have. The benchmark's column stays in the frame as `benchmark_<column>`.
- TA-Lib's `BETA(x, y)` gives the beta of `y` measured against `x`, so the benchmark is passed first. This holds for the `talib` package too, because it wraps the same C function.
- `correlation_coefficient()` correlates returns (pandas `pct_change()`), not price levels.
- `variance()` passes `standard_deviations` to TA-Lib, which ignores it.

## Where each number comes from

| Method | Source in R | Why |
|---|---|---|
| `beta` | `talib::BETA` | Present in the `talib` package |
| `standard_deviation`, `variance` | `talib::STDDEV`, `talib::VAR` | Present; the multiple is the argument `deviations`, not Python's `nbdev` (an `nbdev =` would fall silently into `...`) |
| `correlation_coefficient` | Private `rolling_correlation()`, TA-Lib 0.6.4's `TA_CORREL` loop in R | See below |
| the four `linear_regression*` methods | Private `regression_lines()`, TA-Lib 0.6.4's `TA_LINEARREG*` loop in R | The `talib` package has no linear regression functions |

The `talib` package (0.9-4) bundles a newer TA-Lib than Python's `talib` 0.6.8, which bundles the C library 0.6.4. The newer library rewrote `CORREL`, `VAR` and `STDDEV` with shifted running sums and periodic reseeding, so its numbers differ from 0.6.4 in the last digits. Its `CORREL` also writes 0, not `NaN`, once a missing value has entered the window, while 0.6.4's running sums turn every later value into `NaN`. Porting 0.6.4's `CORREL` loop made the correlation identical to Python's to the last bit, including the missing-value behaviour. `BETA`, `STDDEV` and `VAR` were left on the `talib` package, as the task asked, because their differences are tiny and they treat missing values the same way as Python on every fixture tried.

`regression_lines()` follows 0.6.4's loop, which recomputes the sums for every window, in the same order of operations, and its values are identical to Python's. One helper computes all four lines, because the four TA-Lib functions share one loop and differ only in the last line.

## Missing values at the start

Python's `talib` wrapper skips the leading rows where any input is `NaN`, runs TA-Lib on the rest and pads the front with `NaN`. The `talib` package does not skip them: with `na.bridge = FALSE` it passes them to the C code, which for `CORREL` and `STDDEV` gives wrong or empty results (checked on 2026-10-07: `STDDEV` of a series starting with `NA` came back entirely `NA`). So every method here finds the first complete row with `first_complete_position()`, calls TA-Lib on the rows from there, and pads. This matters for `correlation_coefficient()`, whose first return is always missing.

## Other differences from Python

- The benchmark match uses `match()` on the moments, which keeps the instrument's row order as pandas' inner merge does. A benchmark with two candles at the same moment would give pandas two rows and R one.
- Python's regression functions raise `Exception("TA_LINEARREG function failed with error code 2: Bad Parameter (TA_BAD_PARAM)")` for a window below 2; R signals a plain error with the same text. `rolling_correlation()` does the same for a window below 1, as `TA_CORREL` allows 1.
- R coerces any column to numeric, so an integer column such as `volume` works on both sides.

## Parity check

On 2026-10-07 every method was run in Python and R on `parity/candles.csv` against `parity/benchmark_candles.csv`, with two windows and columns per method, and with a benchmark missing ten candles, and again on a five-row frame, a frame whose first three candles are missing, and a frame with missing values inside. Every output column matched. The largest differences were 0 for the correlation and the regressions, 3.4e-14 for beta (relative 2.3e-12), 9.3e-11 for the standard deviation (relative 5.4e-12) and 2.4e-9 for the variance of values near 1,000 (relative 1.1e-11). The scripts and results are in the session scratchpad's `parity/analysis_group_3/`.
