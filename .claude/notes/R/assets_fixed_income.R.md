# R/assets_fixed_income.R

Port of `src/tradingmachine/assets/fixed_income.py`, written on 2026-10-07 by following `R/assets_equities.R`. The six classes are `FixedIncome`, `FixedIncomeFutures`, `FixedIncomeOption`, `FixedIncomeIndex`, `FixedIncomeIndexFutures` and `FixedIncomeIndexOption`. The Python note `.claude/notes/src/tradingmachine/assets/fixed_income.py.md` holds the full history and live measurements; the parts that still apply are summarised here.

| Class | Base class | UBI segment | Constructor takes |
|---|---|---|---|
| `FixedIncome` | `TradeableInstrument` | `fixed_income` | `exchange`, `symbol` |
| `FixedIncomeFutures` | `Futures` | `fixed_income_futures` | `exchange`, `underlying_symbol`, `expiry_date`, `underlying` |
| `FixedIncomeOption` | `Option` | `fixed_income_options` | those plus `strike_price`, `option_type` |
| `FixedIncomeIndex` | `NonTradeableInstrument` | `fixed_income_indices` | `exchange`, `symbol` |
| `FixedIncomeIndexFutures` | `IndexFutures` | `fixed_income_index_futures` | as `FixedIncomeFutures` |
| `FixedIncomeIndexOption` | `IndexOption` | `fixed_income_index_options` | as `FixedIncomeOption` |

## What carries over from Python

- The module is a copy of the equities module rather than a generalisation, as the user chose on 2026-09-20, so the holdings mechanism is written out again inside `FixedIncome` and nowhere else in the file.
- The cash segment is `fixed_income`, not pluralised. It must not be tidied, because the string is baked into UBI's cash segments, its Redis keys and the `segment` column of `unified.instruments`.
- A bond is named by its ISIN; only about 79 nse interest rate underlyings, such as `633GS2035`, use a rate code. A holding row's `symbol` and `isin` are therefore the same string, and a bond held only at Groww is never reported.
- No broker that serves quotes carries a cash bond or a rate index, and UBI stores no candles for any fixed income segment.
- `fixed_income_index_options` is a name no broker fills, so `FixedIncomeIndexOption` resolves nothing today; it was written anyway so the family is complete, and it degrades cleanly.
- **The holdings methods differ from `Equity` in two ways.** Limit orders pass `hold = FALSE` (since 2026-09-27) and market orders pass `as_marketable_limit = FALSE` (since 2026-10-06), so both send `synthetic = list(type = "simple")` and go to a broker at once. Without them a cash bond's order would be held all day waiting for a quote that never comes, or refused with HTTP 409.
- UBI's own order routing for fixed income derivatives looks wrong (the `NFO` venue rather than `CDS`, units rather than lots, a 16:00 session close). This is inference from UBI's source, never verified with an order, and the fix belongs in UBI.

## Where the R version differs from Python

- The constants carry the file prefix `FIXED_INCOME_`, as the coordinator's rule asks, which gives doubled names such as `FIXED_INCOME_FIXED_INCOME_SEGMENT`. This matches `EQUITIES_EQUITY_SEGMENT` in the equities file. Several names exceed lintr's 30-character limit for the same reason.
- The Python `SEGMENT` class attribute on the derivative classes is not ported, because each discovery function names its segment constant directly, as in `R/assets_equities.R`.
- The discovery functions (`search`, `expiries`, `contracts`, `strikes`, `chain`) are written out on each class generator, because R6 generators do not inherit them, and they are documented in each class's `@description`, because roxygen documents only R6 members.
- The family description that Python keeps in the module docstring is in the `FixedIncome` class description, as `Equity` does for its family.
- The Python examples of the three holdings methods are translated into each method's `@examples`. The Python examples of `search` are in the class `@examples`, because the generator functions have no roxygen block of their own.
- In error messages `{self!r}` becomes `self$format()`, and `{quantity}`, `{expiry_date}` and `{strike_price}` are printed with `format()`.

## Checked against a fake client on 2026-10-07

The checks used the scratchpad `FakeClient` and the test helper's `FakeClient`, never the live UBI, and **no order was sent anywhere**.

- All six classes built from canned details and printed the expected `format()` text, and the details request asked for the bare segment, such as `fixed_income`.
- An equity's details given to `FixedIncome` signalled `FixedIncomeError` "An instrument outside the fixed_income segment is not a FixedIncome". An index given to `FixedIncome` signalled `FixedIncomeError` "UBI has no nse bond for the symbol ONMIBOR", with a `TradeableInstrumentError` as parent, which matches Python.
- A not-found answer from UBI became each class's own error, with the original `InstrumentError` as `parent`.
- The option discovery functions filtered by underlying, dropped expired contracts unless asked, and sorted the chain by strike then option type. An empty master gave an empty `Date` vector, `numeric(0)` and `NULL`, as Python's live check did.
- The holdings members and the three order methods were driven over four holding states. Every order body carried `product = "cnc"` and `synthetic = list(type = "simple")`, and liquidating ten units with four pledged sold six.

`tests/testthat/test-assets_fixed_income.R` covers the same ground (45 expectations, all passing on 2026-10-07).
