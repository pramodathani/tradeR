# R/orders_plan_parts_order_part.R

The R port of `src/tradingmachine/orders/plan_parts/order_part.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## Specific to this file

Python tells a quantity object from an integer quantity with `isinstance(self.quantity, plan_part.PlanPart)`; R uses `inherits(self$quantity, "PlanPart")`. The guard, lifetime and venue are each wrapped in a `list()` of one, because UBI reads them as arrays.

An instrument argument is read only for its `instrument_id`, so any object with that field works, including a `TradeableInstrument`, an `Instrument` or, in tests, a plain `list(instrument_id = ...)`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

### `hold_limits` and `same_as_first` (2026-10-05)

UBI added both on 2026-10-03. An order's own `hold_limits` decides for that order over the plan's, and it is the only way to hold a follow-on order in a Then join's child or an order on the `protect` side, since the request's value deliberately never reaches those. UBI refuses True with the rule `not_holdable` and a reason for an order that cannot be held, such as a market order, one priced by anything but `fixed`, or a leg of a `group_margin` join. `same_as_first` is a new side for a Then join's child, trading on the side the first plan filled on; it needs no code here because `side` is passed through as a string.

`FixedPricing`'s `order_type` must be upper case, `LIMIT` or `MARKET`, since UBI refuses `limit` there with `bad_setting`, unlike the order body, which UBI accepts in any case. The example program `held_entry_and_held_target.py` gives only a price for that reason.
