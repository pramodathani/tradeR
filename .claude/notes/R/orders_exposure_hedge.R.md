# R/orders_exposure_hedge.R

Port of `src/tradingmachine/orders/exposure_hedge.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`ExposureHedgeOrder` mirrors UBI's `exposure_hedge` synthetic order type, `unified_broker_interface/utilities/order_engine/exposure_hedge.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-26, and its parameter names are UBI's field names.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row F4 delta or exposure-triggered hedge.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

UBI's `ExposureHedge` reads `watched`, `lower_band`, `upper_band`, `hedge_instrument_id` and `hedge_exposure_per_unit`, and works out the side and quantity of every hedge itself. The class is built on the hedge instrument, which becomes both the body's `instrument_id` and `hedge_instrument_id`, so the two can never disagree. The template's side, order type and quantity are placeholders, `buy`, `market` and 1, because the route validates them before the engine overwrites them. UBI's note says the delta half of the Atlas's F4 delta hedge is deliberately not built, since the engine has no option pricing model, so an option's delta is supplied as its `exposure_per_unit` on `ExposureWatch`. An exposure hedge is armed and waits, so it survives a flatten; This project's former Known issues page, which the documentation rebuild of 2026-09-26 removed and which `git show b5761c0:docs/contributing/known-issues.md` still prints records that UBI's kill switch does not disarm engine parents.

## UBI's fixes of 2026-10-05, recorded on 2026-10-06

UBI's commit `864e07e` hardened the exposure hedge. It used to drop a hedge cancelled after a partial fill from its count and so oversell, treat a missing or nine-day-old positions document as real, price from a stale quote, send hedges that were not whole lots and were refused with a traceback on every tick, and send a rejected hedge again on every tick. It now counts what a finished hedge filled, measures nothing from a missing, minute-old or stale-marked document, waits out a stale quote, rounds down to whole lots, and stops after a refusal, ending `failed` when anything traded and `rejected` when nothing did. UBI's commit `42afbb2` then fixed a double count when the hedge instrument is also watched: a filled hedge was counted both as in flight and, once the positions document caught up, in the account's position, so after selling 100 against a long of 100 the engine bought the 100 back. It now measures nothing after a fill until the document shows that broker's positions observed after the fill, which delays the next hedge rather than undoing the last one.

## How the R version differs

- `ExposureHedgeOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_EXPOSURE_HEDGE_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.
- `watched` is kept with `as.list()`, the counterpart of Python's `list(watched)` copy, and the watched objects are collected into an unnamed `list()`, so the field is a JSON array even with one watch. The template is fixed to a market buy of one unit, exactly as Python fixes it, because UBI validates a template the engine never places as it stands.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
