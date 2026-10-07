# R/orders_marketable_limit.R

Port of `src/tradingmachine/orders/marketable_limit.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`MarketableLimitOrder` was added on 2026-10-06 for UBI's fifty-fifth type, `marketable_limit`, which UBI built in its commit `462c6c1` (pull request #74). It is not an Atlas row. UBI made it so that a market order could no longer fill far from the price that was showing, and because brokers such as Flattrade refuse market orders sent through an API with `ALGO_CHK: MKT Order type not allowed for API order`.

UBI routes the type into a plan of its preset: a `peg` on `opposite_touch` with `offset_ticks` of minus `buffer_ticks` and `on_empty_book` `refuse`, plus a `lifetime` of `fill_within_seconds / 60` minutes that cancels. A dry run of the type shows exactly that plan. The class is needed only to choose other values, because UBI already runs every plain `market` body with no `synthetic` object and `after_market` False as this type with the defaults, while `UNIFIED_BROKER_INTERFACE_API_ORDER_MARKET_AS_LIMIT` is on.

Both settings are sent as given or left out when None, following the rule that UBI checks order fields: UBI refuses a `buffer_ticks` that is not a whole number at or above zero, and a `fill_within_seconds` that is not above zero, with HTTP 400.

The live run on 2026-10-06 at 09:13, in the pre-open session, was accepted by UBI and rejected by the exchange; the run at 09:15 filled one Vodafone Idea share at 12.78, the best offer, and the parent ended `completed`.

## How the R version differs

- `MarketableLimitOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_MARKETABLE_LIMIT_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
