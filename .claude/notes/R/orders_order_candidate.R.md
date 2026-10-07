# R/orders_order_candidate.R

Port of `src/tradingmachine/orders/order_candidate.py`. The next section is carried over from the Python note and still applies.

## From the Python note

`BasketOrder`, `OneCancelsAllOrder`, `LeggedSpreadOrder` and `StrategyStopOrder` each place one order per candidate, and UBI reads a candidate as an object naming an `instrument_id` plus any of eight override fields. The eight are exactly the ones `unified_broker_interface/utilities/order_engine/utilities/candidate_legs.py` allows: `transaction_type`, `product`, `order_type`, `validity`, `quantity`, `price`, `trigger_price` and `tag`. That file also strips `price_reference`, `quantity_reference` and `synthetic` from a candidate, so `OrderCandidate` does not offer them.

It takes an instrument object rather than an id, because every other part of the library does, and `document()` turns it into the id UBI wants. A class rather than a plain dict keeps the eight names documented and spelled right, which a dict typed by hand does not.

## The template leaks into a candidate

UBI builds each candidate's order as `dict(body)` with the candidate's overrides laid over it, so every template field the candidate does not override is carried in. A template with a `price` and a candidate that sets `order_type` to `market` produces a market order carrying a price, which UBI refuses with HTTP 400. The constructor's docstring says so. A dry run of a basket prepares only the first candidate, so it may not catch a leak in a later one.

## How the R version differs

- `OrderCandidate` is an R6 class with public fields, as Python's are public attributes. Python's keyword-only overrides became ordinary named arguments in the same order, all defaulting to `NULL`.
- `document()` builds a named list and adds each override only when it is not `NULL`, with an explicit loop, so the candidate object carries exactly the keys Python's does. The types that hold candidates collect the documents into an unnamed `list()`, which encodes as a JSON array.
- Checked on 2026-10-07 through the order parity run, where every candidate document inside a basket, one-cancels-all, legged spread and strategy stop body matched Python's, and by `tests/testthat/test-orders_order_candidate.R`.
