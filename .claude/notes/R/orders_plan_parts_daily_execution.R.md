# R/orders_plan_parts_daily_execution.R

The R port of `src/tradingmachine/orders/plan_parts/daily_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`DailyExecution` mirrors UBI's `DailyExecution` in `unified_broker_interface/utilities/order_engine/utilities/daily_execution.py` in the sibling project, read through `PlanReader._read_daily` in `plan_reader.py`, as of 2026-10-02. It is the plan's form of the fixed `daily_stop` type.

Its JSON is `{"daily": {"arm_at": "09:30"}}`, or `{"daily": {}}` for UBI's default `arm_at` of `09:20`, which the class sends by leaving `arm_at` out when None. UBI refuses a value that is not a time `HH:MM` with hours under 24 and minutes under 60.

### Behaviour

A native stop dies at the close, so the order is sent again each trading day at `arm_at`, after the pre-open has settled, and not on a day the instrument does not trade. A plan placed after that time, or on a non-trading day, first sends on the next trading morning. The day last sent is recorded with the order, so a restart does not send twice. Once anything trades no more is sent. UBI's commit `9731fa9` of 2026-10-02 fixed the case where a stop that had traded re-armed the next morning, or sold at once below the stop; the parent now completes instead.

UBI's documentation says to pair it with a lifetime in `after_days`, which ends it and keeps the plan across days, so `stop_renewed_each_morning.py` uses `Lifetime(after_days=5)`.

### Rules that bite

`daily` is one of only two executions a resting stop may have, the other being `all_at_once`, because renewing a stop whole each morning still protects the whole position at once. Every other execution with `native_stop`, `trail`, `stages` or a stop `from_fill` pricing is refused as `stop_not_sliced`; `sliced_stop_refused.py` shows the three cases. It is in neither nesting list.
