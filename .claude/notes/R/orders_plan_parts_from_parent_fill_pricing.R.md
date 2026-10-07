# R/orders_plan_parts_from_parent_fill_pricing.R

The R port of `src/tradingmachine/orders/plan_parts/from_parent_fill_pricing.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`FromParentFillPricing` mirrors UBI's `FromParentFillPricing`, in `unified_broker_interface/utilities/order_engine/utilities/from_parent_fill_pricing.py` in the sibling project, which `PlanReader._read_setter` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds inline (there is no `_read_from_parent_fill`). It was written on 2026-10-02 and keeps the arithmetic of UBI's `legged_spread` synthetic type.

### The JSON shape

```json
{"from_parent_fill": {"net_price": 45.0}}
```

`net_price` is required and is read with `_number`, not `_price`, so it may be zero or negative: positive is a net debit, negative a credit. No other key is accepted.

### Rules that bite

- The order must be the child of a `ThenPart` whose `first` plan is a single order, because the price is worked out from that order's average fill. Anywhere else `PlanReader._check_fill_sizing` refuses it with `from_parent_fill_needs_then`.
- The first leg's side signs its fill and the second leg's side signs the result, so the second leg is usually the opposite side and often another instrument, given through `OrderPart(instrument=..., transaction_type=...)`.
- A worked-out price at or below zero cannot be sent, so the order waits rather than failing.

### Each order priced to the running average (2026-10-06)

UBI's commit `cfdcad7` of 2026-10-05 changed how the second leg is priced. It used to be priced from the first leg's cumulative average alone, so each top-up priced from an earlier average left the spread away from `net_price`, 20.65 against 20 in one of UBI's runs. Each new order is now priced so that the second leg's orders together average what the net needs, and rounded to the second leg's tick in the caller's favour, down for a buy and up for a sell; before, a price such as 982.05 on a 0.10 tick was refused by the broker and the refusal was lost.
