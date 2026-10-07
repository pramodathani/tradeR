# R/orders_plan_parts_marketable_pricing.R

The R port of `src/tradingmachine/orders/plan_parts/marketable_pricing.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`MarketablePricing` builds UBI's `marketable` pricing, read by `PlanReader` in the sibling project's `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` and worked out by `marketable_pricing.py` beside it.

### A stale quote also makes it wait (2026-10-06)

UBI's commit `15380c1` of 2026-10-05 makes the rule refuse a quote marked stale as well as an empty book, so the order waits for the next tick. This matters most for an order sent only when a fill arrives, such as an attached hedge, which used to be priced from the stale quote and now waits and tries again on every tick.

This pricing is not the same thing as UBI's `marketable_limit` type, added in the same batch of changes, which is a preset built on `peg` with `on_empty_book: refuse` and is answered HTTP 409 rather than left waiting when the book cannot price it.
