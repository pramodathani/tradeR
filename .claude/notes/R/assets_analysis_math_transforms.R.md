# R/assets_analysis_math_transforms.R

Port of `src/tradingmachine/assets/analysis/math_transforms.py`, ported on 2026-10-07. `MathTransforms` is the link of the analysis chain after `StatisticFunctions`. The fifteen method names and their column labels (`acos`, `asin`, `atan`, `ceil`, `cos`, `cosh`, `exp`, `floor`, `ln`, `log10`, `sin`, `sinh`, `sqrt`, `tan`, `tanh`) are the Python ones; the Python note has the table of old and new names.

## Computed in base R

The `talib` package has none of TA-Lib's math transforms. TA-Lib's C code for each is one call to the C library function of the same name, such as `acos()` or `log10()`, with a lookback of 0, so the R methods call the base R function that wraps the same C function. On the parity fixture every value was identical to Python's, including the infinities.

Base R warns ("NaNs produced") when `acos()`, `asin()`, `log()`, `log10()` or `sqrt()` is given a value outside its domain, where C and Python stay silent. Those five methods therefore compute only the values inside the domain and fill the rest with `NaN`, which gives the same column without a warning. `log(0)` is `-Inf` in both languages and is kept.

Python's wrapper skips leading `NaN` rows, but for a function with no lookback that changes nothing: those rows are `NaN` either way.

## Carried over from the Python note

Applied to raw prices most of these produce nothing useful: `acos` and `asin` are entirely `NaN` for prices around 1,000, and `exp`, `cosh` and `sinh` overflow to infinity above about 710. They are meant for small columns, such as returns, passed through `column`. The R docstrings say so for the domain-limited ones.

## Parity check

On 2026-10-07 every method was run in Python and R on `parity/candles.csv`, once on `close` and once on a column `(close - 1060) / 100`, which ranges from about -1.4 to 1.4 and so tests both sides of each domain edge. Every value matched exactly, also on the five-row, leading-missing and inner-missing variants.
