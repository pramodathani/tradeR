# R/orders_plan_parts_chase_pricing.R

The R port of `src/tradingmachine/orders/plan_parts/chase_pricing.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`ChasePricing` mirrors UBI's `ChasePricing`, in `unified_broker_interface/utilities/order_engine/utilities/chase_pricing.py` in the sibling project, which `PlanReader._read_chase` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds. It was written on 2026-10-02 and keeps the rules of UBI's `chaser` synthetic type.

### The JSON shape

```json
{"chase": {"step_ticks": 1, "step_seconds": 5, "cross_after_seconds": 60}}
```

Every key is optional. `step_ticks` defaults to 1 and must be a whole number of at least 1; `step_seconds` defaults to 5 and must be a number above zero; `cross_after_seconds` has no default, and when it is given it must be above zero too.

### Rules that bite

- The chaser type's `cap_price` is not a chase setting in a plan. It is a separate `CapModifier` beside the chase, as `OrderPart(pricing=ChasePricing(...), cap=CapModifier(...))`, and the cap holds every step.
- A chase means to trade against the other side, so `PlanReader._can_rest` refuses it beside a `PostOnlyGuard` with `post_only_crosses`.
- The chase's clock is kept in the pricing's memory and recorded with each step, so a restart of UBI's engine neither steps at once nor forgets when the chase began. When a caller changes the price, the chase waits a full step before moving again.
