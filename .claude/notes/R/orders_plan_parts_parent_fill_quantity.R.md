# R/orders_plan_parts_parent_fill_quantity.R

The R port of `src/tradingmachine/orders/plan_parts/parent_fill_quantity.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`ParentFillQuantity` mirrors UBI's `FillRatio`, in `unified_broker_interface/utilities/order_engine/utilities/fill_ratio.py` in the sibling project, read by `PlanReader._read_fill_ratio` and checked by `PlanReader._check_fill_sizing` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. The `attached_hedge` preset uses it with `ratio` and whole lots.

The class is named after the JSON key, `parent_fill`, rather than after UBI's internal class, because the key is what a caller writes.

### The JSON shape

```json
{"parent_fill": {"ratio": 0.5, "whole_lots": true}}
```

`ratio` defaults to 1 in UBI and must be a number above zero; `whole_lots` defaults to false. An empty object, `{"parent_fill": {}}`, is valid and means the whole of what filled. Any other key is refused.

### Rules that bite

- The order must be a `then` join's direct child (`parent_fill_needs_then`): `_check_fill_sizing` refuses any order with a fill ratio that is not `sized_by_fills`, and `_read_then` sets that flag only on an `OrderPart` child.
- With `whole_lots`, a size under one lot of the order's own instrument waits for more fills.
- The child is resized at every fill to `ratio` times the total filled so far, not per fill.

### A child under one lot, and a child on the first plan's instrument (2026-10-06)

UBI's commit `15380c1` of 2026-10-05 cancels a child whose size is still under one lot once the first plan has finished, where before it left the parent `working` for ever. The same commit refuses with HTTP 400 a child sized this way that names an instrument the first plan trades, because it would only trade back what was filled.
