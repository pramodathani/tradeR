# R/orders_plan_parts_discretion_modifier.R

The R port of `src/tradingmachine/orders/plan_parts/discretion_modifier.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`DiscretionModifier` mirrors UBI's `DiscretionModifier`, in `unified_broker_interface/utilities/order_engine/utilities/discretion_modifier.py` in the sibling project, which `PlanReader._read_discretion` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds. It was written on 2026-10-02 and keeps the rules of UBI's `discretionary` synthetic type.

### The JSON shape

```json
{"discretion": {"points": 0.25, "quantity": 40}}
```

`points` is required and must be above zero; `quantity` is optional, at least 1, and defaults to everything still resting. The synthetic type calls these `discretion_points` and `discretion_quantity`; the plan's names are used here.

### Where it goes

Like the cap, it is a modifier read from the `pricing` list beside the one setter, so it is passed as `OrderPart(pricing=..., discretion=...)`. A second discretion in one list is refused with `two_discretions`. With no setter at all, the template's own order type and price are used.

### Rules that bite

`PlanReader._can_take_at_discretion` needs one visible limit:

- On a stop, any of the `STOP_PRICINGS` `native_stop`, `trail`, the average-true-range trail and `stages`, it is refused with `discretion_needs_limit`.
- With any execution other than all at once, it is refused with `discretion_not_sliced`.

The taking order is a limit `BUFFER_TICKS`, two ticks, past the other side's touch, never past the visible price plus `points`, and the visible order is reduced or cancelled before it is sent, so the two can never both fill in full.
