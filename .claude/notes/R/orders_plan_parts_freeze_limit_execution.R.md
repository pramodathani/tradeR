# R/orders_plan_parts_freeze_limit_execution.R

The R port of `src/tradingmachine/orders/plan_parts/freeze_limit_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`FreezeLimitExecution` mirrors UBI's `FreezeLimitExecution` in `unified_broker_interface/utilities/order_engine/utilities/freeze_limit_execution.py` in the sibling project, and the `freeze_limit` branch of `PlanReader._read_execution_value` in `plan_reader.py`, as of 2026-10-02. UBI's `freeze_slicer` preset is this execution and nothing else.

Its JSON is `{"freeze_limit": {}}`, and UBI refuses any setting inside it as `unknown_setting`.

### Behaviour

The broker is chosen first, through UBI's selector, because each broker publishes its freeze quantity in its own units: for one MCX silver option, brokers with a lot of 30 report 600 and brokers with a lot of 1 report 20, both meaning twenty lots. The order's quantity in that broker's terms is compared with its figure and split evenly into orders each within it, all sent at once to that broker, which is kept in the execution's memory. A broker that publishes no freeze quantity gets the order whole, and more than 20 slices is refused.

### Rules that bite

UBI's documentation says it is one execution among the others rather than applied inside every piece, because it sends every piece at once to one broker, and it is in neither nesting list. So an order above the freeze quantity that should also be spread over time cannot be built. A resting stop cannot use it.
