# R/orders_exposure_watch.R

Port of `src/tradingmachine/orders/exposure_watch.py`. The next section is carried over from the Python note and still applies.

## From the Python note

`ExposureHedgeOrder` reads `watched` as a list of objects, each naming an `instrument_id` and optionally an `exposure_per_unit`, which UBI defaults to 1 (`unified_broker_interface/utilities/order_engine/exposure_hedge.py`). `ExposureWatch` is that object as a class, for the same reason `OrderCandidate` is one: the two field names are documented and spelled right, and the instrument is an object that `document()` turns into an id.

It accepts any `Instrument`, not only a tradeable one, because a watched instrument is only read, never traded. `exposure_per_unit` is where a caller supplies a delta: UBI deliberately has no option pricing model, so the delta half of a delta hedge is the caller's to compute.

## How the R version differs

- `ExposureWatch` is an R6 class with public fields `instrument` and `exposure_per_unit`; the second argument may be given by position, as in Python, where it is not keyword-only.
- `document()` adds `exposure_per_unit` only when it is not `NULL`. `ExposureHedgeOrder` collects the documents into an unnamed `list()`, so `watched` is a JSON array even with one watch.
- Checked on 2026-10-07 through the order parity run on `ExposureHedgeOrder` and by `tests/testthat/test-orders_exposure_watch.R`.
