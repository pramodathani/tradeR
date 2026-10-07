# R/orders_plan_parts_book_depth_execution.R

The R port of `src/tradingmachine/orders/plan_parts/book_depth_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`BookDepthExecution` mirrors UBI's `BookDepthExecution` in `unified_broker_interface/utilities/order_engine/utilities/book_depth_execution.py` in the sibling project, read through `PlanReader._read_book_depth` in `plan_reader.py`, as of 2026-10-02. It is the plan's form of the fixed `liquidity_seeking` type.

Its JSON is `{"book_depth": {"limit_price": 1000.0, "minimum_quantity": 500}}`. Both are required: `limit_price` is a positive price and `minimum_quantity` a whole number of at least 1.

### Behaviour

It sends nothing until the displayed quantity at every level of the other side of the book no worse than `limit_price` adds up to at least `minimum_quantity`, and then strikes for the smaller of what is shown and what is left. A strike that partly fills rests at its price; later strikes are only for what is neither traded nor resting. A strike the broker rejects stops the order. The size shown is the size displayed, so more or less may fill. It reads quotes and is paced by ticks, so it starts watching as soon as the trigger holds.

### Pricing

The execution decides when and how much, but the strike's price is the order's pricing. UBI's `liquidity_seeking` preset pairs it with `fixed` pricing at `limit_price`, and the examples here do the same with `FixedPricing(price=limit_price, order_type="LIMIT")`, so a strike that does not fill rests at the limit. Nothing stops a caller pairing it with another pricing, and UBI does not refuse that.

### Rules that bite

It is in neither nesting list, so it cannot be half of a nested pair, and a resting stop cannot use it.
