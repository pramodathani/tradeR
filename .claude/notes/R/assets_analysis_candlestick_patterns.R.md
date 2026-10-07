# R/assets_analysis_candlestick_patterns.R

Port of `src/tradingmachine/assets/analysis/candlestick_patterns.py`, ported on 2026-10-07. `CandlestickPatterns` is the link of the analysis chain after `MathOperators`. It has the same 61 `candle_*` methods with the same column labels, including the Python label quirks the Python note lists: `candle_hanging_man` writes `candle_hangingman`, `candle_evening_doji_star` writes `candle_evening_dojistar`, and `candle_up_side_down_side_gap_three_methods` writes `candle_up_side_gap_three_methods`.

## How a pattern is computed

Each method calls the `talib` package's function of the same TA-Lib name, such as `talib::CDLHAMMER`, through the private `pattern_signals()`, which does three things to make the result match Python's `talib`:

1. The `talib` package reports a match as 1 or -1 by default. Its option `talib.normalize = FALSE` gives TA-Lib's own 100 and -100, so the option is set for the call and restored with `on.exit()`.
2. The `talib` package fills the first candles, which TA-Lib cannot judge, with `NA`, where Python's `talib` fills them with 0. They become 0, and the column is an integer vector as in Python.
3. Leading rows with a missing price are skipped, as Python's wrapper skips them, and get 0.

The `talib` package's candle settings (`talib.BodyLong.N` and so on) default to TA-Lib's own settings, which Python uses. Setting those options in a session would change R's answers and not Python's. The penetration defaults of the patterns that take one (0.3 for the abandoned baby, 0.5 for dark cloud cover, mat hold and the stars) are the same in both, and neither port passes one.

## Values the Python docstrings do not mention

Besides 100, -100 and 0, and 200 or -200 for a confirmed hikkake, which the Python note records, `candle_engulfing`, `candle_harami` and `candle_harami_cross` also give 80 and -80 in TA-Lib 0.6, seen on the stress fixture on 2026-10-07; `candle_modified_hikkake` gives 200 and -200 too. The docstrings were carried over unchanged, as the Python ones describe the common case.

## Generated

The 61 methods were written on 2026-10-07 by a one-off script in the session scratchpad (`group3/generate_candlestick_patterns.py`) from the Python source and the docstring translator. The Python examples come from eight templates, such as "print the dates of each match" or "average the next day's return"; the script rebuilt each Python example from its template and stopped unless the rebuild matched the original line for line, then filled in the R form of the same template. The intro sentence above each Python example was dropped, as in the other R files. The file is ordinary source from now on.

## Parity check

On 2026-10-07 every pattern was run in Python and R on `parity/candles.csv` (400 candles) and on a 20,000-candle stress fixture with gaps, dojis and long bodies made to reach rare patterns. Every signal matched on every row of both. On the 400-candle fixture 23 patterns never fire; on the stress fixture all but four do. The four that never fired on either, `candle_three_stars_in_the_south`, `candle_concealing_baby_swallow`, `candle_identical_three_crows` and `candle_mat_hold`, are only checked to give all zeros on both sides. The tests compare every pattern with Python's signals on the first 2,500 stress candles (`tests/testthat/fixtures/candlestick_candles.csv` and `candlestick_python_signals.csv`).
