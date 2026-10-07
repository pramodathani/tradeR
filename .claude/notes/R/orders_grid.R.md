# R/orders_grid.R

Port of `src/tradingmachine/orders/grid.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`GridOrder` mirrors UBI's `grid` synthetic order type, `unified_broker_interface/utilities/order_engine/grid.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-26, and its parameter names are UBI's field names.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row E4 grid, and G15 scale order with profit-taker.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

`most_inventory` is required by UBI rather than defaulted, because a trending market keeps filling one side and a grid with no cap would build an unlimited position. The class keeps it required for the same reason. The Atlas's G15, a ladder where each fill gets its own profit-taker, is the same mechanism, which is why the gap analysis on 2026-09-26 counted it as covered.

## UBI's fixes of 2026-10-05, recorded on 2026-10-06

UBI's commit `d3a354c` began refusing a `step_points` that is not a whole number of ticks with HTTP 400. Before, the order answering a filled rung was priced one step away without rounding, so a step of 2.53 gave a sell at 1000.03 that the placement refused after the fill had already been marked answered, leaving the position with no exit. UBI's commit `8c86310` stopped a parent that has ended from settling its plan again, because a fill arriving after the caller cancelled a grid used to place a new order that then rested at the broker under a cancelled parent. The docstrings were brought in line with both on 2026-10-06, together with UBI's clarification that the inventory cap is checked after each fill and can therefore be overshot by one fill.

## How the R version differs

- `GridOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_GRID_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
