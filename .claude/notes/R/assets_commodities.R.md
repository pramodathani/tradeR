# R/assets_commodities.R

Port of `src/tradingmachine/assets/commodities.py`, written on 2026-10-07 by following `R/assets_equities.R`. The six classes are `Commodity`, `CommodityFutures`, `CommodityOption`, `CommodityIndex`, `CommodityIndexFutures` and `CommodityIndexOption`, on the segments `commodities`, `commodity_futures`, `commodity_options`, `commodity_indices`, `commodity_index_futures` and `commodity_index_options`. The Python note `.claude/notes/src/tradingmachine/assets/commodities.py.md` holds the live measurements.

## What carries over from Python

- No class has holdings members, because UBI's cash segments do not include commodities, so a commodity can never be reported as a holding. Positions do cover the family.
- **A quantity is counted in quotation units and must be a whole number of lots.** `quantity = 1` on an MCX gold future is refused with HTTP 400, while `quantity = 100` is one lot. Nothing here checks it locally, because quantities go to UBI exactly as given. The constructors of the four derivative classes say so.
- A `Commodity` cannot be ordered or quoted, although it inherits every order method, because its rows are reference records rather than tradeable spot contracts. A `CommodityIndex` cannot be traded either.
- An order can be refused with HTTP 503 and a `contract_size_status` when UBI does not trust the contract's size that day.
- The four derivative classes are quoted and have candles, unlike the fixed income and currency families.
- The option classes find their underlying as the nearest future expiring on or after the option and price with Black-76; the futures classes have no default underlying. That logic lives in `R/assets_instruments.R`, in `INSTRUMENTS_UNDERLYING_SEGMENT_FOR_DERIVATIVE_SEGMENT`, not here.
- Unknown exchanges, such as a commodity on the `bse`, are not refused locally; UBI's not-found answer already gives the class's own error.

## Where the R version differs from Python

The same differences as `R/assets_fixed_income.R`: constants prefixed `COMMODITIES_` (such as `COMMODITIES_COMMODITY_SEGMENT`), no `SEGMENT` attribute, discovery functions written out on each generator and documented in the class descriptions, the module docstring placed in the `Commodity` class description, and `self$format()` in place of `{self!r}`. The Python module has examples only on the two `search` methods, and they are in the class `@examples` of `Commodity` and `CommodityIndex`.

## Checked against a fake client on 2026-10-07

No order was sent. All six classes built from canned details. The segment checks signalled `CommodityError` for an equity, `CommodityError` with a `TradeableInstrumentError` parent for an index asked for as a commodity, `CommodityIndexError` for a commodity asked for as an index, and `CommodityOptionError` for an index option. A not-found answer became each class's own error. Every discovery function sent the right bare segment, and a lower-case `underlying_symbol` such as `"gold"` still matched, because `InstrumentCatalogue` upper-cases it. `tests/testthat/test-assets_commodities.R` has 27 expectations, all passing.
