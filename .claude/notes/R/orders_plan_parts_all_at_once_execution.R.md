# R/orders_plan_parts_all_at_once_execution.R

The R port of `src/tradingmachine/orders/plan_parts/all_at_once_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`AllAtOnceExecution` mirrors UBI's `AllAtOnceExecution` in `unified_broker_interface/utilities/order_engine/utilities/all_at_once_execution.py` in the sibling project, and the `all_at_once` branch of `PlanReader._read_execution_value` in `plan_reader.py`, read on 2026-10-02.

Its JSON is `{"all_at_once": {}}`, an entry of the order's `execution` list, which `OrderPart` builds. UBI refuses any setting inside the empty object as `unknown_setting`.

### Why a class for UBI's default

An order with no execution is already sent all at once, because `PlanReader` fills in `AllAtOnceExecution()` when the order names none. The class exists for two cases. A later value replaces an earlier one, so an order's own `execution=AllAtOnceExecution()` overrides an execution that a preset gave, with UBI's `execution_replaced` warning; the example `replace_a_preset_execution.py` shows this. And it lets a stop say explicitly that it is sent whole.

### Rules that bite

- A resting stop, meaning `native_stop`, `trail` (with or without its `atr` object) or `stages` pricing, or `from_fill` pricing set up as a stop, may only have `all_at_once` or `daily` execution. Anything else is refused as `stop_not_sliced`, because a stop protects the whole position at once.
- Under a join that resizes the order, such as a `ThenPart` `each_fill` child, `all_at_once` modifies its one resting order rather than sending another. `TopUpExecution` is the alternative that keeps each order's queue place.
- It is neither in `NESTED_OUTER_NAMES` nor `NESTED_INNER_NAMES`, so it cannot be one half of a nested pair.
