# R/assets_analysis_price_statistics.R

Port of `src/tradingmachine/assets/analysis/price_statistics.py`: `PriceStatistics`, the 39 summary statistics, in the same order and with the same names, arguments and defaults. It is the first link after `PriceAnalysis` in the analysis chain described in `assets_instruments.R.md`, so its `inherit = PriceAnalysis` line must stay.

## What carries over from Python

The methods form three families, each built on the one before:

```
prices()  ──►  price_high, price_low, price_mean ... price_histogram      (12)
          ──►  volumes()  ──►  volume_total, volume_high ... volume_histogram   (1 + 13)
          ──►  returns(column)  ──►  returns_high ... returns_summary       (1 + 12)
```

`volumes()` and `returns()` return a narrowed frame of `exchange`, `segment`, `datetime`, `interval` and the one value column. `returns()` divides each value by the one before, so the first row is always `NA`. `price_high()` and `price_low()` always read the `high` and `low` columns and take no `column` argument, as in Python.

## How each pandas reduction was reproduced

Base R's defaults differ from pandas' in several places, so each statistic was written to follow pandas exactly. The parity run in the session scratchpad (`parity/analysis_group_1/`) checked every method against the Python library on 400 synthetic candles, the same candles with missing closes and volumes, three candles, and six identical candles, and the largest relative difference was about 1e-13.

| Statistic | pandas | R here |
|---|---|---|
| missing values | skipped by every reduction | `NA` removed first, through the private `price_statistics_present()` |
| `max()` / `min()` with nothing present | `NaN` | `NA`, through `price_statistics_largest()` and `price_statistics_smallest()`, instead of base R's `-Inf` with a warning |
| `std()` / `var()` | sample (`ddof=1`) | `stats::sd()` / `stats::var()`, also sample |
| `skew()` | adjusted Fisher-Pearson, `0` for constant values, `NaN` below three values, with pandas' rounding guard on the moments | `price_statistics_skewness()`, the same formula and guard |
| `kurtosis()` / `kurt()` | bias-corrected excess kurtosis, `0` for constant values, `NaN` below four values | `price_statistics_kurtosis()`, the same formula and guard |
| `quantile()` | linear interpolation | `stats::quantile(type = 7)`, the same rule |
| `pct_change()` | pandas 3 no longer pads missing values, so a gap gives `NaN` on both sides of it | plain division by the previous value, which gives the same `NA`s |
| `sum()` of volume | whole numbers stay whole | `sum(as.numeric(...))`, because an R integer sum overflows to `NA` above about 2.1 billion |

## Differences from Python

- `price_summary()`, `volume_summary()` and `returns_summary()` return a named numeric vector with the names `count`, `mean`, `std`, `min`, `25%`, `50%`, `75%` and `max`, where Python returns a pandas Series with that index. `summary[["mean"]]` reads the same figure as Python's `summary["mean"]`.
- The histogram methods draw with `graphics::hist()` on the current graphics device and return its `histogram` object, where Python draws with matplotlib and returns the Axes. The bins copy NumPy's: equal widths from the smallest to the largest value (half a unit either side when every value is the same), each bin closed on the left and open on the right except the last, which is closed on both sides. The parity run found the same bar heights and edges as matplotlib's patches. A bar's edges are `histogram$breaks[[bar]]` and `histogram$breaks[[bar + 1]]`, and its height is `histogram$counts[[bar]]`. As with any R plotting function, the returned value is invisible.
- The private helpers are named with a `price_statistics_` prefix because every analysis class shares one R6 chain, and a private method of the same name in a later class would replace these.
- Examples that use a `Watchlist` assume the R port of `tradingmachine.asset_baskets.watchlist.Watchlist` keeps the constructor arguments `name` and `instruments`.

## Documentation

The roxygen blocks were generated on 2026-10-07 from the Python docstrings by the session's `docstring_translator.py`, then assembled with the hand-translated examples by a one-off script in the session scratchpad. The file is ordinary source from now on. The private methods carry `@param` and `@return` lines like the other files in the package, which roxygen reports as "can't find matching R6 method" but otherwise ignores.
