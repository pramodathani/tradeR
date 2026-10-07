# R/orders_plan_parts_then_part.R

The R port of `src/tradingmachine/orders/plan_parts/then_part.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`ThenPart` mirrors UBI's `ThenPart`, in `unified_broker_interface/utilities/order_engine/utilities/then_part.py` in the sibling project.

### Exits that follow a position that turned over (2026-10-06)

UBI's commit `8247bb7` of 2026-10-05 fixed two things about a Then join's exits, and the module docstring was updated to say so on 2026-10-06.

When both sides of a two-sided entry filled and the later side filled more, UBI used to resize the exits to the net quantity but leave them on the old side, so a short of 6 kept sell exits that would have doubled it. The exits on the wrong side are now cancelled and sent again on the new side, priced from the fills on the side now held, which is also why `FromFillPricing` counts only that side's fills.

An exit that had finished used to be reopened whenever its part was marked done as cancelled, so a bracket's stop cancelled by its `order_id` was placed again as soon as the cancel was confirmed, and each exchange cancel of a target placed another until one was rejected. A finished exit is now sent again only once its target grows past the target it had when it finished, which UBI records as `done_at_target`.

UBI's commit `15380c1` of the same day also made a refused or rejected child cancel the rest of the first plan and end the parent `failed`, naming the part, rather than `completed` with the position unhedged.
