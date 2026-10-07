# R/orders_plan_parts_ladder_execution.R

The R port of `src/tradingmachine/orders/plan_parts/ladder_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`LadderExecution` mirrors UBI's `LadderExecution` in `unified_broker_interface/utilities/order_engine/utilities/ladder_execution.py` in the sibling project, read through `PlanReader._read_ladder` in `plan_reader.py`, as of 2026-10-02.

Its JSON is `{"ladder": {"from_price": 1000.0, "to_price": 990.0, "steps": 5}}`. All three are required. The two prices must differ, and `steps` is a whole number from 2 to 20.

### Behaviour

Every rung is sent at once, as limits evenly spaced from `from_price` to `to_price`, each rounded to the tick on the passive side, so a range that does not divide evenly into ticks gives rungs that rest rather than cross. The quantity is shared as evenly as whole units allow, the first rungs taking the remainder, so 100 over three rungs is 34, 33 and 33. A quantity smaller than `steps` is refused when the order is sent.

### Pricing

The rung prices replace whatever the order's pricing set, so the examples give a ladder no pricing. Inside a `using` join, which accepts `ladder` with `twap` and `front_loaded`, UBI goes further and refuses any pricing on either the order or `each_piece` as `using_ladder_priced`.

### Rules that bite

It is in neither nesting list, and a resting stop cannot use it.
