# R/orders_hidden_stop.R

Port of `src/tradingmachine/orders/hidden_stop.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`HiddenStopOrder` mirrors UBI's `hidden_stop` synthetic order type, `unified_broker_interface/utilities/order_engine/hidden_stop.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-26, and its parameter names are UBI's field names.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row B2 hidden stop, and part of G10.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

UBI's `HiddenStop` builds on its `PriceTrigger` class, so it reads `trigger_direction` although the glossary does not list it for this type; the class accepts it. `trigger_price` is the hidden level and is stored as `trigger_level`. The backstop is a real stop-loss limit at the broker, which the Atlas says is the one thing no code replaces, because it keeps working when UBI does not.

## How the R version differs

- `HiddenStopOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_HIDDEN_STOP_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.
- As in Python, the argument `trigger_price` is the type's own level: it is stored in the field `trigger_level` and sent as the synthetic object's `trigger_price`, while the template's own `trigger_price` is passed to the base class as `NULL`.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
