# R/orders_plan_parts_front_loaded_execution.R

The R port of `src/tradingmachine/orders/plan_parts/front_loaded_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`FrontLoadedExecution` mirrors UBI's `FrontLoadedExecution` in `unified_broker_interface/utilities/order_engine/utilities/front_loaded_execution.py` in the sibling project, on the shared clock of `timed_slices_execution.py`. It is read by `PlanReader._read_timed` in `plan_reader.py`, as of 2026-10-02. It is the plan's form of the fixed `implementation_shortfall` type.

Its JSON is `{"front_loaded": {"slices": 5, "over_minutes": 30, "urgency": 0.8}}`. `slices` runs from 2 to 60, `over_minutes` must be above zero, and `urgency` is a number from 0 to 1 that defaults to 0.5 in UBI, so the class leaves it out when None. It does not accept `until`.

### Behaviour

Slices go on the TWAP clock, but each is `1 - urgency × 0.5` of the one before. An urgency of 0 is an even split, 0.5 makes each slice three quarters of the last, and 1 halves every slice. The `compare_urgencies.py` example prints the approximate sizes; UBI's own sizes use the largest-remainder method and may differ by a unit.

### Nesting and other joins

It is in both nesting lists, so it can be outer or inner, and it is one of the three executions a `using` join accepts.

### Rules that bite

A resting stop cannot be sliced, so stop pricing with this execution is refused as `stop_not_sliced`.
