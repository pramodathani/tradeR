# R/orders_average_true_range_trail.R

Port of `src/tradingmachine/orders/average_true_range_trail.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`AverageTrueRangeTrailOrder` mirrors UBI's `atr_trail` synthetic order type, `unified_broker_interface/utilities/order_engine/atr_trail.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-26, and its parameter names are UBI's field names.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row B8 ATR or indicator trail.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

The module name and the `average_true_range_multiple` parameter spell out UBI's `atr_trail` and `atr_multiple`; `synthetic_fields()` sends the parameter under UBI's name.

## `activate_at`, added on 2026-10-02

UBI's `atr_trail` shares the base class `TrailingOrder` with `trailing_stop` and does not override its `run`, so it reads `activate_at` and holds the order until the last traded price reaches that level, answering HTTP 202 with an `outcome` of `armed`. UBI's own table of fixed types does not list `activate_at` for `atr_trail`, although its code and its `ATR_TRAIL_SETTINGS` preset settings accept it; it was added here on 2026-10-02 because the code accepts it, and it is the one setting of this class that UBI's documentation does not promise.

## How the R version differs

- `AverageTrueRangeTrailOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_AVERAGE_TRUE_RANGE_TRAIL_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.
- The R field is `average_true_range_multiple`, spelled out like Python's attribute, and is sent under UBI's name `atr_multiple`.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
