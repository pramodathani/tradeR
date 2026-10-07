# R/orders_plan_parts_participation_execution.R

The R port of `src/tradingmachine/orders/plan_parts/participation_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`ParticipationExecution` mirrors UBI's `ParticipationExecution` in `unified_broker_interface/utilities/order_engine/utilities/participation_execution.py` in the sibling project, read through `PlanReader._read_participation` in `plan_reader.py`, as of 2026-10-02.

Its JSON is `{"participation": {"percent": 10.0, "most_slices": 20}}`. `percent` is required, above zero and at most 100. `most_slices` is a whole number of at least 1 and defaults to 60 in UBI, so the class leaves it out when None.

### Behaviour

On each tick it sends `percent` of the volume traded since its last slice, read from the live quote's cumulative `volume`, counting from when the order starts working. Participation is paced by ticks, so the order starts working, and the count starts, as soon as its trigger holds. A slice that rests unfilled still counts as sent; the unfilled part of a cancelled slice is sent again by later slices, and a slice the broker rejects stops the order.

### Whole lots, fixed on 2026-10-02

UBI's commit `9731fa9` found that a share of volume rarely comes to whole lots, so on a lot-traded contract such as a NIFTY option every slice was refused and the order stalled with nothing sent. Each slice is now cut down to whole lots of the instrument at the chosen broker, or before a broker is chosen the largest lot any broker lists, and a share under one lot leaves the counted volume where it was, so the volume goes on counting towards the next slice. The counters are also restored when a slice is refused. The example `nifty_futures_in_whole_lots.py` prints what a few volumes would send.

### Nesting

Participation is in UBI's `OUTER_NAMES` but not `INNER_NAMES`, so it can release slices for an inner `iceberg`, `twap`, `vwap` or `front_loaded` to work, but cannot itself work the slices of another execution; that pair is refused as `bad_nesting`. It is not accepted by a `using` join, whose pieces must be known in advance.

### Rules that bite

A resting stop cannot be sliced, so stop pricing with this execution is refused as `stop_not_sliced`.
