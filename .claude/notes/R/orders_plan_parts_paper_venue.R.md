# R/orders_plan_parts_paper_venue.R

The R port of `src/tradingmachine/orders/plan_parts/paper_venue.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`PaperVenue` mirrors UBI's `PaperVenue`, in `unified_broker_interface/utilities/order_engine/utilities/paper_venue.py` in the sibling project, read by `PlanReader._read_venue_list` and checked by `PlanReader._can_fill_on_paper` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. The `virtual_limit` preset with `paper: true` builds it.

### The JSON shape

```json
{"order": {"trigger": {"limit_marketable": {}}, "venue": [{"session": "paper"}]}}
```

The entry takes `session` alone; any other key is refused. It has no settings, so the class has no constructor and no `Attributes:` section.

### Rules that bite

- The order's trigger must be `limit_marketable` alone (`paper_needs_limit_marketable`); a group of conditions is refused even if it contains one.
- Because of that trigger, the order takes no pricing of its own and is held at the body's own `LIMIT` price (`held_at_the_body_price`).
- The order must be the whole plan, at path `root` (`paper_is_the_whole_plan`), so it cannot sit in any join.
- Nothing reaches a broker. Fills come from the virtual book's queue estimate and are recorded as `paper_filled` events, and the plan completes once the whole quantity has filled.
