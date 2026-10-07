# R/orders_plan_parts_iceberg_execution.R

The R port of `src/tradingmachine/orders/plan_parts/iceberg_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`IcebergExecution` mirrors UBI's `IcebergExecution` in `unified_broker_interface/utilities/order_engine/utilities/iceberg_execution.py` in the sibling project, read through `PlanReader._read_iceberg` in `plan_reader.py`, as of 2026-10-02.

Its JSON is `{"iceberg": {"visible_quantity": 10, "randomise_percent": 20}}`. `visible_quantity` is a whole number of at least 1 and is required. `randomise_percent` is a whole number from 0 to 99 and defaults to 0 in UBI, so it is left out when None. Any other key is refused as `unknown_setting`.

### Behaviour

One piece is sent at a time and the next only once the last has filled. The variation of each piece is worked out from the parent's id and the number of pieces sent, so it is repeatable after a restart but does not form a visible pattern. A piece that is cancelled or rejected stops the iceberg, because whoever stopped it meant the order to stop.

The fixed type `iceberg` calls the same setting `slice_quantity`; the plan's execution calls it `visible_quantity`, and the class follows the plan.

### Nesting

`iceberg` is the only execution in both of UBI's lists in `nested_execution.py`: `OUTER_NAMES` is `twap`, `vwap`, `front_loaded`, `participation`, `iceberg`, and `INNER_NAMES` is `iceberg`, `twap`, `vwap`, `front_loaded`. So it can show each slice of another execution a little at a time, which is the common use, as in `OrderPart(execution=TwapExecution(...), inner_execution=IcebergExecution(...))`, sent as `"execution": [{"twap": ...}, {"iceberg": ...}]`. It can also release its own pieces as slices for an inner timed execution to work. Pairs outside those lists are refused as `bad_nesting`, and a third value as `nesting_too_deep`.

### Rules that bite

A resting stop cannot be an iceberg; UBI refuses it as `stop_not_sliced`.
