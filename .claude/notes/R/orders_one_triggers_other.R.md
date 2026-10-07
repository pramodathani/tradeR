# R/orders_one_triggers_other.R

Port of `src/tradingmachine/orders/one_triggers_other.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`OneTriggersOtherOrder` mirrors UBI's `oto` synthetic order type, `unified_broker_interface/utilities/order_engine/oto.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-26, and its parameter names are UBI's field names.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row D1 one-triggers-other.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

UBI reads `then` as an order body without a quantity and lays it over the whole template (`body.update(described)` in `oto.py`), then sets the quantity to what the first order filled and drops the tag. So the class does not take a `then` dict; it takes the six fields a second order sensibly changes as `then_transaction_type`, `then_order_type`, `then_price`, `then_trigger_price`, `then_product` and `then_validity`, and builds the dict itself. The side and the order type are required, which is a choice made here rather than UBI's rule: a `then` that changed neither would repeat the first order, which is never what an OTO is for.

Because the template is laid underneath, a template `price` is carried into a `then_order_type` of `market` and UBI refuses the market order that carries a price. UBI validates the child order before it sends the first one, so a dry run shows the refusal without placing anything. The docstring says so.

## UBI's fixes of 2026-10-05, recorded on 2026-10-06

UBI's commit `15380c1` made a refused order in a Then join's child cancel the rest of the first plan and end the parent `failed` rather than `completed`, which applies to the second order of a one-triggers-other order, so the docstrings now say so.

## How the R version differs

- `OneTriggersOtherOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_ONE_TRIGGERS_OTHER_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.
- The follow-on order is built the way Python builds it: `transaction_type` and `order_type` always, and `price`, `trigger_price`, `product` and `validity` only when they are not `NULL`.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
