# R/orders_scale_out.R

Port of `src/tradingmachine/orders/scale_out.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`ScaleOutOrder` mirrors UBI's `scale_out` synthetic order type, `unified_broker_interface/utilities/order_engine/scale_out.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-26, and its parameter names are UBI's field names.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row D7 multi-target bracket or scale-out, and part of G8 adjustable stop.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

`target_prices` is copied into a new list so that a caller changing their own list afterwards does not change the order. `breakeven_after` is the one piece of the Atlas's G8 adjustable stop that UBI has built; the general rule table is not built.

## UBI's fixes of 2026-10-05, recorded on 2026-10-06

UBI's commit `15380c1` made a refused order in a Then join's child cancel the rest of the first plan and end the parent `failed`, which applies to a scale-out's exits, and its commit `b507de0` made a dry run make the off-tick checks placing makes. The docstrings now say both.

## How the R version differs

- `ScaleOutOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_SCALE_OUT_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.
- `target_prices` is kept with `as.list()`, the counterpart of Python's `list(target_prices)` copy. In R this also matters for the JSON: the client encodes with `auto_unbox = TRUE`, so a numeric vector holding one price would otherwise be sent as a bare number instead of an array. A caller may therefore pass `c(1010, 1020)` or `list(1010, 1020)`.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
