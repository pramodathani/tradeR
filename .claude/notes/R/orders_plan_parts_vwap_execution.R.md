# R/orders_plan_parts_vwap_execution.R

The R port of `src/tradingmachine/orders/plan_parts/vwap_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## Specific to this file

`volume_profile` is kept as given, usually a numeric vector, and sent through `as.list()`, so a profile of one weight is still a JSON array as Python's list of one is.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`VwapExecution` mirrors UBI's `VwapExecution` in `unified_broker_interface/utilities/order_engine/utilities/vwap_execution.py` in the sibling project, on the shared clock of `timed_slices_execution.py`. It is read by `PlanReader._read_timed` and `PlanReader._read_profile` in `plan_reader.py`, as of 2026-10-02.

Its JSON is `{"vwap": {"slices": 10, "over_minutes": 90, "volume_profile": [...]}}` or `{"vwap": {"slices": 10, "until": "15:00"}}`. `slices` runs from 2 to 60.

### `until` instead of `over_minutes`

VWAP alone of the timed executions takes `until`, a time of day `HH:MM`, given instead of `over_minutes`. The slices are then spread from when the order starts working until that time, and an order that starts after it is refused with HTTP 400 when it begins. Giving both is refused as `bad_setting`, with the message that `until` is "given instead of over_minutes". Both are therefore optional in the class, and the caller supplies exactly one. A `using` join does not accept a VWAP at all, and refuses any timed execution that gives `until`.

### The volume profile

`volume_profile` is a list of relative weights at or above zero, one per half hour from the session's open, which must not be empty and must add up to more than zero. A slice takes the weight of the half hour it falls in, and a slice after the last half hour takes the last weight. UBI's default is `DEFAULT_PROFILE` in `vwap_execution.py`, the NSE equity day's shape, heavy at the open and the close.

### Fixes of 2026-10-02

UBI's commit `42ba13d` changed two things. The half hours are now counted from each segment's own open, through `SessionOpen`: 09:15 for equity and 09:00 for currency and MCX, on the day the order starts working; before, every segment was measured from the equity open. And the default profile is now used only for equity: a currency or commodity order with no profile of its own gets even slices, since the equity shape means nothing for a session with a long evening. A caller who wants a shape for those segments must give `volume_profile`.

### Nesting

VWAP is in both nesting lists, so it can be the outer execution with an inner `iceberg`, which is the usual pairing, or the inner one under `participation`, `iceberg`, `twap`, `front_loaded` or `vwap`.

### Rules that bite

A resting stop cannot be sliced, so VWAP with stop pricing is refused as `stop_not_sliced`.
