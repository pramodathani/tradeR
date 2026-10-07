# R/assets_analysis_performance_measures.R

Port of `src/tradingmachine/assets/analysis/performance_measures.py`, ported on 2026-10-07. `PerformanceMeasures` is the last link of the analysis chain (see `assets_instruments.R.md`), so `Instrument` and `AssetBasket` both inherit it, which is what lets `nifty$sharpe_ratio()` and a basket's `sharpe_ratio()` be the same method on different candles.

## What carries over from the Python note

- Annualising: `day` candles scale by 252, a minute interval such as `5minute` by 252 sessions of 375 minutes (09:15 to 15:30) divided by the candle length. Any other interval signals `ValueError` before any request is sent. UBI serves no weekly or monthly candles, so there are no 52 or 12 period cases.
- The Sharpe and Sortino ratios use the arithmetic mean return times the periods a year, not the compound rate `annualised_return()` gives.
- `maximum_drawdown()` is a negative fraction; `calmar_ratio()` divides by its absolute value.
- `value_at_risk()` and `expected_shortfall()` are positive loss fractions.
- The capture ratios use the plain mean return on the candles where the benchmark rose or fell.
- `risk_free_rate` defaults to 0, because a built-in rate goes stale.
- `benchmark_beta()` is one number over the range; the rolling TA-Lib `beta()` lives in `StatisticFunctions`.
- Every public method fetches once; `performance_summary()` fetches once for the instrument and once for the benchmark.

## How the pandas calls were matched

| Python | R |
|---|---|
| `Series.std()`, `var()`, `cov()` (divisor n - 1) | `stats::sd()`, `stats::var()`, `stats::cov()`, also n - 1 |
| `Series.quantile(q)` (linear interpolation) | `stats::quantile(type = 7)`, the same rule |
| `statistics.NormalDist().inv_cdf()` | `stats::qnorm()` |
| `pct_change().dropna()` | the private `returns_of()`, `closes[-1] / closes[-n] - 1` |
| `merge(how="inner")` then `sort_values` then `dropna()` | `merge()`, `order()`, `complete.cases()` |
| `cummax()`, which skips missing values | the private `running_peak_of()` loop in `drawdowns()`, which also skips them, because base `cummax()` turns everything after an `NA` into `NA` |

## Differences from Python

- `performance_summary()` returns a named list rather than a pandas Series. A measure that cannot be calculated is a `NULL` element, kept in the list, so the names are always the same nine, or fifteen with a benchmark.
- The private helpers keep the Python names without the leading underscore (`closes`, `matched_returns`, `periods_per_year`, `sharpe_ratio_of` and so on). R6 private members are shared along the whole chain, so another analysis class must not define a private method with one of these names; none of the Python mixins does.
- Python's static helper methods became ordinary private methods, because they belong to this class.

## Verified on 2026-10-07

Every public measure, with risk-free rates of 0 and 0.065, `day` and `5minute` intervals, confidence levels of 0.9, 0.95 and 0.99 and both value at risk methods, was compared with the Python class on the parity fixtures (`candles.csv` against `benchmark_candles.csv`, both fed through an overridden `prices()`). The largest relative difference was 3.8e-15, and the `drawdowns()` frame matched to 5e-16. The scripts and the full table are in the session scratchpad under `parity/analysis_group_4/`. The tests in `tests/testthat/test-assets_analysis_performance_measures.R` hold values captured from that Python run, read from copies of the fixtures in `tests/testthat/fixtures/`.
