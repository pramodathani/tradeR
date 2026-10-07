# R/orders_one_cancels_all.R

Port of `src/tradingmachine/orders/one_cancels_all.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`OneCancelsAllOrder` mirrors UBI's `oca` synthetic order type, `unified_broker_interface/utilities/order_engine/one_cancels_all.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-26, and its parameter names are UBI's field names.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row D4 one-cancels-all group.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

The class has no instrument argument of its own. UBI's route runs `PlaceOrderRequest` over the body before the engine sees it, so the body needs a resolvable `instrument_id`, and the first candidate's instrument is used for it; the engine then places only the candidates (`utilities/candidate_legs.py`). An empty candidate list therefore raises `ValueError` here, which is the one check in the package, because without a candidate there is no instrument to put in the body and the request could not be built at all. The template's fields become the defaults each candidate overrides, and UBI never resolves price or quantity references for this type, so the class does not accept them. The leak of a template price into a market candidate is described in the note on `order_candidate.py`. UBI cancels the other candidates rather than reducing them, the one linked type that does, because the candidates are separate trades rather than exits on one position.

## How the R version differs

- `OneCancelsAllOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_ONE_CANCELS_ALL_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.
- `candidates` is kept with `as.list()`, the counterpart of Python's `list(candidates)` copy, and the candidate documents are collected into an unnamed `list()`, so the field always encodes as a JSON array, even with one candidate.
- The empty-candidates check signals `ValueError` through `ErrorCatalogue$raise()`, as Python raises `ValueError`, and runs before the template is built because the first candidate's instrument anchors the request.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
