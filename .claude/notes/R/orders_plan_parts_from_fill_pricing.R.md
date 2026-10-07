# R/orders_plan_parts_from_fill_pricing.R

The R port of `src/tradingmachine/orders/plan_parts/from_fill_pricing.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`FromFillPricing` mirrors UBI's `FromFillPricing`, in `unified_broker_interface/utilities/order_engine/utilities/from_fill_pricing.py` in the sibling project, which `PlanReader._read_from_fill` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds. It was written on 2026-10-02. UBI added it the same day so that the exits of `two_sided_breakout` could be distances from the fill rather than absolute prices; the reasoning is in `.claude/notes/src/tradingmachine/orders/two_sided_breakout.py.md`.

### The JSON shape

```json
{"from_fill": {"stop_distance": 10.0, "stop_limit_offset": 1.0}}
{"from_fill": {"target_distance": 20.0}}
```

A stop takes `stop_distance` and `stop_limit_offset` together, and a target takes `target_distance` alone; each value must be above zero. Giving both kinds, or neither, is refused with `bad_setting` or `missing_setting`. The class takes all three as optional keywords and sends whichever are set, leaving the choice to UBI as the spec requires.

### Rules that bite

- The order must sit under a `ThenPart`'s `each_fill` or `on_complete` child, directly or inside an `EitherPart` there, because the price comes from the fill that opened the position. Anywhere else `PlanReader._check_fill_sizing` refuses it with `from_fill_needs_then`.
- The direction comes from the side the exit is sent on: a selling exit's stop sits below the fill and its target above, and a buying exit's the other way round. One plan therefore protects a position opened either way, which is why it suits a two-sided breakout.
- A stop form is a native stop-limit, so like the `STOP_PRICINGS` it cannot be split into pieces (`stop_not_sliced`).
