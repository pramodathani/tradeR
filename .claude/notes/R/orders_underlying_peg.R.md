# R/orders_underlying_peg.R

Port of `src/tradingmachine/orders/underlying_peg.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`UnderlyingPegOrder` mirrors UBI's `underlying_peg` synthetic order type, `unified_broker_interface/utilities/order_engine/underlying_peg.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-27, and its parameter names are UBI's field names, except that `watch_instrument_id` is taken as the instrument object `watch_instrument`, as `CrossInstrumentOrder` does.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row G6 pegged-to-stock. UBI built the Atlas's group G on 2026-09-27, and this class was added the same day to catch up with it.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

UBI builds it on its `peg` type, but the documentation lists only these five fields for it, so `reference`, `offset_ticks` and `cap_price` are not offered.

## How the R version differs

- `UnderlyingPegOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_UNDERLYING_PEG_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.
- The watched instrument is sent as `watch_instrument_id`, read from the instrument object, as in Python.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
