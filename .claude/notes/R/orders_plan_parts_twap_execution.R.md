# R/orders_plan_parts_twap_execution.R

The R port of `src/tradingmachine/orders/plan_parts/twap_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`TwapExecution` mirrors UBI's `TwapExecution` in `unified_broker_interface/utilities/order_engine/utilities/twap_execution.py` in the sibling project, whose schedule is in `timed_slices_execution.py`. It is read by `PlanReader._read_timed` in `plan_reader.py`, as of 2026-10-02.

Its JSON is `{"twap": {"slices": 6, "over_minutes": 60}}`. Both are required. `slices` is a whole number from 2 to 60, the 60 being `MOST_SLICES` in `plan_reader.py`, and `over_minutes` is a number above zero. Unlike VWAP, TWAP does not accept `until`; UBI refuses it as `unknown_setting`.

### Behaviour

One slice goes every `over_minutes × 60 / slices` seconds, the first at once. Quantities are shared with the largest-remainder method, so equal weights give an exact even split with the leftover units going to the earliest slices. Each slice is sized from the order's total when it falls due, so a join that changes the total spreads the change over the slices still to come, and the last slice sends what is left. A slice that has not filled is left resting when the next goes. TWAP is paced by ticks, so the order starts working as soon as its trigger holds.

A pricing that moves its order, such as a peg, moves every slice still resting.

### Nesting and other joins

TWAP is in both of UBI's nesting lists, so it can be the outer execution, with an inner `iceberg`, `vwap`, `front_loaded` or another `twap`, or the inner one under `participation`, `iceberg`, `vwap`, `front_loaded` or `twap`. It is also one of the three executions, with `ladder` and `front_loaded`, that a `using` join accepts, because its pieces are known in advance.

### Rules that bite

A resting stop cannot be sliced, so TWAP with `native_stop`, `trail` or `stages` pricing is refused as `stop_not_sliced`.
