# R/assets_analysis_signals.R

Port of `src/tradingmachine/assets/analysis/signals.py`, ported on 2026-10-07. `Signals` is the link of the analysis chain after `CandlestickPatterns`. It holds `is_cross_over()` and `is_cross_under()`, which work on a frame the caller passes and do not fetch candles.

## Carried over from the Python note

The methods use the textbook test the user chose on 2026-09-14: `is_cross_over` marks a row when, on the previous row, the first column was at or below the second and, on this row, it is above; `is_cross_under` is the mirror. The first row is never marked, and no helper column is added.

## Differences from Python

- pandas compares `NaN` as false, so a row next to a missing value is never marked. In R a comparison with `NA` is `NA`, so the result is turned into `FALSE` wherever it is missing, giving the same logical column.
- Python's `reset_index(drop = TRUE)` becomes `rownames(data) <- NULL`. R copies the frame on modification, so the caller's frame is unchanged, as in Python.
- Python raises `KeyError` for a missing column. R checks both columns first in `check_columns()` and signals `KeyError` through `ErrorCatalogue`, with the message "data has no column named 'x'".
- pandas `shift()` becomes the private `previous_values()`.

## Parity check

On 2026-10-07 both methods were run in Python and R on `parity/candles.csv`, comparing `close` with `open` (105 crossings over and 105 under) and `close` with the 14-candle regression line, whose first 13 values are missing (50 over, 51 under). The columns matched on every row, also on the five-row and missing-value variants.
