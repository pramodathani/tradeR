# R/orders_plan_parts_stage_rule.R

The R port of `src/tradingmachine/orders/plan_parts/stage_rule.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`StageRule` is one milestone of a `stages` pricing, the dictionaries that `PlanReader._read_rules` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` reads. UBI has no class for a rule; its `StagesPricing` keeps them as a list of dictionaries. It was written on 2026-10-02 so that the rules of a `StagesPricing` are built from objects like every other part of a plan.

### The JSON shape

```json
{"gain": 10.0, "stop_at_gain": 0.0}
{"gain": 25.0, "trail_points": 8.0}
```

A rule is an entry of a list, so `document()` returns its settings directly rather than under a one-key name, which `PlanPart.document` lists as one of its exceptions.

### Rules that bite

`PlanReader._read_rules` checks the whole list and stops at the first wrong rule, refusing it with `bad_setting`:

- There are 1 to `MOST_RULES`, 20, rules.
- Each `gain` is above zero and larger than the gain of the rule before it.
- Each rule has exactly one of `stop_at_gain` and `trail_points`.
- Only the last rule may have `trail_points`, because trailing hands the rest of the trade over and nothing comes after it.
- `stop_at_gain` may be zero (breakeven) or negative (a smaller loss), but must be below the rule's own `gain`, or the stop would fire at once.

Gains are measured in the position's favour, so the same positive numbers serve a short position as a long one.
