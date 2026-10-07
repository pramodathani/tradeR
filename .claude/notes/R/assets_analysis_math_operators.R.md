# R/assets_analysis_math_operators.R

Port of `src/tradingmachine/assets/analysis/math_operators.py`, ported on 2026-10-07. `MathOperators` is the link of the analysis chain after `MathTransforms`. Method names, argument order and column labels are the Python ones; the Python note has the table of old and new names.

## Carried over from the Python note

- The two-column methods default to `first_column = "high"` and `second_column = "low"`.
- The rolling methods take `column` before `window`, the reverse of most analysis methods.
- `minimum_maximum()` writes the same `min` and `max` columns as `minimum()` and `maximum()`.

## Everything is computed in R

The `talib` package has `MAX` and `MIN` but none of `ADD`, `SUB`, `MULT`, `DIV`, `MINMAX`, `MAXINDEX`, `MININDEX` or `MINMAXINDEX`.

- The four arithmetic methods use R's operators. TA-Lib's C code is the same single operation, so the values are identical, including division by zero.
- The rolling methods follow TA-Lib 0.6.4's `TA_MAX`/`TA_MAXINDEX` and `TA_MIN`/`TA_MININDEX` loops step by step in `scan_highest()` and `scan_lowest()`. The loop matters for ties and missing values: a rescan of the window keeps the earliest of equal values, an incoming value equal to the current extreme replaces it, and a comparison with `NaN` is false, which in R is written `isTRUE(...)`. `MINMAX` and `MINMAXINDEX` are the same two loops run together, so they are built from the single ones.
- `talib::MAX` and `talib::MIN` were used at first, but the `talib` package bundles a newer TA-Lib whose `MAX` and `MIN` treat a missing value inside the data differently (for `1, 2, NA, 4, 5, 6, 7` with a window of 2, `talib::MAX` gave `NA, 2, 2, 4, 5, 6, 7` and Python's `talib.MAX` gave `NaN, 2, 2, NaN, 5, 6, 7`, checked on 2026-10-07), so they were replaced by the scans on 2026-10-07 to keep Python's behaviour.

## Positions counted from 0

The index methods return what Python's return: integer positions counted from 0 for the first candle of the fetched range, with 0 in the rows before the first full window, because Python's `talib` fills the lookback of an integer output with 0, not `NaN`. In R the row is the position plus 1, which the docstrings and the translated examples say. When candles at the start are missing, Python's wrapper skips them and still reports positions counted from the first row of the whole frame; the scans do the same.

Python's index functions raise `Exception("TA_MAXINDEX function failed with error code 2: Bad Parameter (TA_BAD_PARAM)")` for a window below 2; `check_window()` signals a plain error with the same text, naming `TA_MAX`, `TA_MIN`, `TA_MINMAX`, `TA_MAXINDEX`, `TA_MININDEX` or `TA_MINMAXINDEX` as Python would.

## Generated

The file was written on 2026-10-07 by a one-off script in the session scratchpad (`group3/generate_math_operators.py`), which held the hand-translated examples; it is ordinary source from now on.

## Parity check

On 2026-10-07 every method was run in Python and R on `parity/candles.csv` with default arguments and with `column = "high", window = 20` (and `close` against `open` for the arithmetic), and again on the five-row, leading-missing and inner-missing variants. Every value matched exactly. The private scans were also checked against Python on the short series `1, NaN, 3, 2, 5, 4` and `NaN, 1, 3, 2, 5, 4`, which the tests keep.
