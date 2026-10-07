# R/orders_plan_parts_stages_pricing.R

The R port of `src/tradingmachine/orders/plan_parts/stages_pricing.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## Specific to this file

The children, conditions or rules are given as a `list()` of parts, the R counterpart of Python's sequence, and their documents are collected into a `list()`, so a list of one child is still a JSON array and an empty list is `[]`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`StagesPricing` mirrors UBI's `StagesPricing`, in `unified_broker_interface/utilities/order_engine/utilities/stages_pricing.py` in the sibling project, which `PlanReader._read_stages` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds. It was written on 2026-10-02 and keeps the rules of UBI's `stepped_stop` synthetic type.

### The JSON shape

```json
{"stages": {"entry_price": 1000.0, "stop_price": 990.0, "limit_offset": 1.0, "step_ticks": 2, "rules": [{"gain": 10.0, "stop_at_gain": 0.0}, {"gain": 25.0, "trail_points": 8.0}]}}
```

`entry_price`, `stop_price`, `limit_offset` and `rules` are required, and the three prices must be above zero. `step_ticks` defaults to 1. The rules are `StageRule` objects, whose limits are in that class's note.

### Naming choice

The `stepped_stop` preset calls the limit distance `stop_limit_offset`; the plan's own `stages` pricing calls it `limit_offset`, as `trail` does, and the class follows the plan.

### Rules that bite

- `stages` is one of UBI's `STOP_PRICINGS`. A stop protects the whole position at once, so an order with it cannot have an execution other than all at once or daily (`stop_not_sliced`), cannot take a `DiscretionModifier` (`discretion_needs_limit`) and cannot take a `PostOnlyGuard` (`post_only_needs_limit`).
- The stop only ever moves in the position's favour, by at least `step_ticks`, so a rule that would loosen it counts as reached and is skipped rather than refused.
- It is usually the `each_fill` child of a `ThenPart` with `side="protect"`, but nothing requires that, because the entry price is stated rather than read from a fill.
