# R/orders_plan_parts_parent_fill_delta_quantity.R

The R port of `src/tradingmachine/orders/plan_parts/parent_fill_delta_quantity.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`ParentFillDeltaQuantity` mirrors UBI's `FillDelta`, in `unified_broker_interface/utilities/order_engine/utilities/fill_delta.py` in the sibling project, read by `PlanReader._read_fill_delta` and paired with the side in `PlanReader._read_order` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. The `attached_hedge` preset uses it when given `delta_volatility`.

### The JSON shape

```json
{"parent_fill_delta": {"volatility": 12.5, "whole_lots": true}}
```

`volatility` is required, a percentage above zero, so the constructor has no default for it. `whole_lots` defaults to false. Any other key is refused.

### Rules that bite

- The order's side must be `against_delta`, and an `against_delta` side must have this quantity (`against_delta_needs_delta`). That side is opposite the opening side for a call and the same side for a put.
- Like `parent_fill`, it is only for a `then` join's direct child (`parent_fill_needs_then`).
- UBI takes the Black-76 delta of the plan's own instrument, which must be an option or the plan is refused with HTTP 400 when placed, using the last price of this order's instrument, usually the future, as the forward. The offline `PlanReader` cannot see the instrument, so that check happens only at placing.
- An expired option, or a forward with no price, leaves the size as it was.

### A forward with no price is tried again (2026-10-06)

UBI's commit `15380c1` of 2026-10-05 tries a delta hedge whose forward has no price again on every tick until the order has started, rather than leaving it unsized, and refuses with HTTP 400 a child sized this way that names an instrument the first plan trades. As with `ParentFillQuantity`, a size under one lot is cancelled once the first plan has finished.
