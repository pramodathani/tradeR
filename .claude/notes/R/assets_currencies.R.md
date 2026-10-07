# R/assets_currencies.R

Port of `src/tradingmachine/assets/currencies.py`, written on 2026-10-07 by following `R/assets_equities.R`. The six classes are `Currency`, `CurrencyFutures`, `CurrencyOption`, `CurrencyIndex`, `CurrencyIndexFutures` and `CurrencyIndexOption`, on the segments `currencies`, `currency_futures`, `currency_options`, `currency_indices`, `currency_index_futures` and `currency_index_options`. The Python note `.claude/notes/src/tradingmachine/assets/currencies.py.md` holds the live measurements.

## What carries over from Python

- **Half the family resolves nothing.** `currency_indices`, `currency_index_futures` and `currency_index_options` hold no rows on any exchange. The user chose on 2026-09-20 to write the three classes anyway, so every family has the same shape. They degrade on their own: a lookup becomes the class's own error, `expiries` and `strikes` return empty vectors, and `contracts`, `chain` and `search` return `NULL`. Their class descriptions say so.
- No class has holdings members, because `currencies` is not one of UBI's cash segments.
- A `Currency` cannot be ordered or quoted, although it inherits the methods for both.
- A quantity is counted in quotation units and must be a whole number of lots, as for commodities.
- **`lot_size` is not the lot an order is measured against.** It is the plurality of the brokers' figures, which gives 1 for NSE USDINR while orders are measured against the exchange's contract size. The family description warns against computing an order quantity from it.
- UBI stores no candles for any currency segment, and only the nse derivatives are quoted.

## Where the R version differs from Python

The same differences as `R/assets_fixed_income.R`: constants prefixed `CURRENCIES_` (such as `CURRENCIES_CURRENCY_SEGMENT`), no `SEGMENT` attribute, discovery functions written out on each generator and documented in the class descriptions, the module docstring placed in the `Currency` class description, and `self$format()` in place of `{self!r}`. The examples of the two `search` methods are in the class `@examples`. The Python examples loop over a two-element list of exchanges, which became a `c()` literal written one element per line.

## Checked against a fake client on 2026-10-07

No order was sent. The three populated classes built from canned details, and so did the three empty-segment classes when given hypothetical details, which shows they will work once UBI has rows. The segment checks and not-found answers gave each class's own error. An empty master and an empty search answer gave `Date` of length 0, `numeric(0)` and `NULL` without signalling, and each call named the right bare segment. `tests/testthat/test-assets_currencies.R` has 26 expectations, all passing.
