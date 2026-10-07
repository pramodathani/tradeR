# R/assets_instruments.R

Port of `src/tradingmachine/assets/instruments.py`: `Instrument`, `TradeableInstrument`, `NonTradeableInstrument` and the derivative bases `Derivative`, `Futures`, `Option`, `IndexFutures` and `IndexOption`, plus `InstrumentCatalogue`.

## The analysis chain

Python's `Instrument` inherits fourteen analysis mixins at once. R6 allows one parent, so the analysis classes form a single chain, `PriceAnalysis` at the root and `PerformanceMeasures` at the end, and `Instrument` inherits the end. The analysis methods have distinct names, so the order of the chain changes nothing.

## InstrumentCatalogue

Python's protected class methods `_search_catalogue`, `_master_catalogue`, `_contracts_for`, `_expiry_dates` and `_identity_frame` are shared by every family. R6 generators do not inherit functions, so they became the methods of a small class, `InstrumentCatalogue`, and each family class's discovery functions, such as `EquityOption$chain()`, build one and call it. `strikes()` was added to it because `Option.strikes` was the one discovery method whose body was more than a call.

## Discovery on the base classes

`Futures$expiries()`, `Futures$contracts()`, `Option$expiries()`, `Option$strikes()` and `Option$chain()` exist only to signal `FuturesError` or `OptionError`, as calling them on the Python base classes does, because those classes name no segment.

## The shared client

Python stores the shared client on `Instrument` as a class attribute. R6 generators are environments, but storing state there is fragile across `devtools::load_all()`, so it lives in the package environment `.trade_r_state`. `Instrument$set_shared_unified_broker_interface()` is an R-only addition that lets tests and scripts install a client, such as one built with `credentials`.

## Differences from the Python version

- `tick_size` is numeric, not `decimal.Decimal`, because base R has no decimal type. Tick sizes such as 0.05 are only ever compared or multiplied, so a double is close enough; the exact text UBI sent can be recovered from `carried_by`.
- `__hash__` has no counterpart, because R6 objects are not used as keys; `equals()` replaces `__eq__`.
- `format()` writes numbers the R way, so a strike of 24000 prints as `24000`, not Python's `24000.0`.
- `days_to_expiry` is an integer from subtracting two `Date` values, the same count Python's `.days` gives.
- `expiry_kind` compares the year and month as one `"YYYY-MM"` string, which is the same test as Python's separate year and month checks.
- The order wrappers were generated from the Python source on 2026-10-07 by a one-off script in the session scratchpad, which also translated their docstrings; the file is ordinary source from now on.
