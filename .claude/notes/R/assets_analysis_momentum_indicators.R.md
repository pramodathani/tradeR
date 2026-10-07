# R/assets_analysis_momentum_indicators.R

Port of `src/tradingmachine/assets/analysis/momentum_indicators.py`, ported on 2026-10-07. `MomentumIndicators` holds the 28 TA-Lib momentum indicators. In R it is one link of the single analysis chain (`OverlapStudies` before it, `VolumeIndicators` after it), as `.claude/notes/R/assets_instruments.R.md` explains. Method names, argument names, argument order, defaults and column labels are the same as in Python. How `talib` is called and how its argument names map to Python's is described in `.claude/notes/R/assets_analysis_overlap_studies.R.md`.

## Carried over from the Python note

- `stochastic_relative_strength_index` passes `window` (default 14) as the RSI length and `fast_k_period` as TA-Lib's fast %K period. This is the correction the user asked for on 2026-09-14.
- The two MACD methods label their columns differently: `macd_<f>_<s>_<g>_signal` and `macd_<f>_<s>_<g>_hist` for the plain one, and `macd_signal_<suffix>` and `macd_hist_<suffix>` for the extended one.
- Labels without an underscore are kept: `ppo<fast>_<slow>`, `stochf_fastk<n>`, `stochf_fastd<n>`, `stochrsi_fastk<n>` and `stochrsi_fastd<n>`.
- The default windows differ between methods: 10 for `average_directional_movement_index_rating` and `directional_movement_index`, and 14 for `average_directional_movement_index`.
- `ultimate_oscillator` keeps the names `fast_period`, `slow_period` and `signal_period` for its short, middle and long windows. They map to `talib`'s `firstPeriod`, `secondPeriod` and `thirdPeriod`.

## Moving average types

`talib` passes integer moving average codes straight to C through its `as.maType()`. Python's `matype` integers therefore select the same TA-Lib average in R, from 0 (simple) to 8 (T3). The parity check ran every code from 0 to 8 through `absolute_price_oscillator`, `percentage_price_oscillator`, `moving_average_convergence_divergence_extended`, `stochastic_oscillator`, `stochastic_fast_oscillator` and `stochastic_relative_strength_index`. `talib::APO` and `talib::PPO` default to code 1, while Python defaults to 0, but the methods always pass the argument explicitly.

## ROC and ROCP written in base R

`talib` has `ROCR` but no `ROC` or `ROCP`, so `rate_of_change` and `rate_of_change_percent` follow TA-Lib's C definitions directly.

| Method | Formula | Missing rows | When the earlier value is 0 |
|---|---|---|---|
| `rate_of_change` | `(value / earlier - 1) * 100` | the first `window` rows | 0 |
| `rate_of_change_percent` | `(value - earlier) / earlier` | the first `window` rows | 0 |

The private method `values_window_before()` shifts the column by `window` rows and checks that `window` is between 1 and 100000. Outside that range it signals an error whose message contains `TA_BAD_PARAM`, because Python's `talib` raises an exception for a bad period. The two formulas are kept separate because TA-Lib computes them in different orders, and keeping the same order keeps the results identical to the last bit. In the parity check the largest difference was 0.

## The one known difference: Kaufman smoothing of a stochastic

`stochastic_relative_strength_index` with `fast_d_moving_average_type = 6` (Kaufman adaptive) did not match Python on the fixture candles. The %K line matched exactly, but %D differed on 61 of 400 rows, by up to 12.9 points.

The cause is a change in TA-Lib itself, not in this port:

1. R's `talib` bundles TA-Lib C 0.8.1, while Python's `talib` 0.6.8 links TA-Lib C 0.6.4.
2. KAMA divides the net move over its window by the sum of absolute moves, which TA-Lib keeps as a running total by adding and subtracting. When the input is almost flat, such as %K pinned at 100 with one value of 99.99999999999999, both numbers are rounding residue. The ratio then lands anywhere between 0 (slowest smoothing) and 1 (fastest).
3. TA-Lib 0.8.1 changed this calculation on purpose. Its source notes "Fix #253": it counts exactly flat bars and resets the running total, and it uses fused multiply-add. A one-bit difference in the residue therefore sends the two versions to opposite ends of the smoothing range, and the gap closes again over the following rows.
4. Running Python's own `talib.KAMA` on the same %K values after a CSV round trip, which changed some values by one bit, also gave R's answer instead of Python's `STOCHRSI` answer. The result really does depend on noise at the level of one bit.

The fixture did not trigger the same difference for `stochastic_oscillator` or `stochastic_fast_oscillator` with code 6, but they can in principle hit it, because stochastic lines often sit at exactly 0 or 100. KAMA on raw prices with exactly flat stretches matched Python bit for bit in a separate check. Reproducing TA-Lib 0.6.4's KAMA in base R to imitate this rounding noise was judged not worth it. Every other momentum case matched within a relative difference of 5e-11.

## Parity check

On 2026-10-07 every method was run in Python and in R on the 400 fixture candles in the session scratchpad (`parity/candles.csv`). Each method was run with its defaults, with non-default arguments, with every moving average code and on an 8-candle frame. The scripts, the outputs and `summary.md` are in `parity/analysis_group_2/` in that scratchpad. Of 173 cases, 172 matched within 1e-9 relative, with identical column names and `NA` positions; the one exception is described above. The values the testthat tests check were captured from Python by `capture_test_values.py` in the same directory, on a 60-candle series built from a formula the tests rebuild.
