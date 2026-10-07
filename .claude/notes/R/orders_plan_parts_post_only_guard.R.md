# R/orders_plan_parts_post_only_guard.R

The R port of `src/tradingmachine/orders/plan_parts/post_only_guard.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`PostOnlyGuard` mirrors UBI's `PostOnlyGuard`, in `unified_broker_interface/utilities/order_engine/utilities/post_only_guard.py` in the sibling project, which `PlanReader._read_guards_list` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds. It was written on 2026-10-02 and keeps the rules of UBI's `post_only` synthetic type.

### The JSON shape

```json
{"post_only": {"on_crossing": "rest"}}
```

`on_crossing` is optional, one of UBI's `ON_CROSSING`, `refuse` (the default) or `rest`. `post_only` is the only guard UBI has built, so any other key in the `guards` list is refused with `unknown_guard`. `OrderPart.document` wraps the guard in a list of one under `guards`.

### Rules that bite

`PlanReader._can_rest` refuses the guard beside pricing that cannot rest:

- On a stop, any of the `STOP_PRICINGS`, with `post_only_needs_limit`.
- Beside pricing that means to trade at once, with `post_only_crosses`: `MarketablePricing`, `ChasePricing`, a `PegPricing` with `reference="opposite_touch"`, or a `FixedPricing` with `order_type="MARKET"`.

With `refuse`, a crossing limit ends the order, and when that is the plan's first order the placement answers HTTP 409. Indian exchanges have no post-only flag, so the book can still move while the order is in flight; the guard is an approximation.
