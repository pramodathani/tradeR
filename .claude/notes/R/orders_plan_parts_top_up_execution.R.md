# R/orders_plan_parts_top_up_execution.R

The R port of `src/tradingmachine/orders/plan_parts/top_up_execution.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`TopUpExecution` mirrors UBI's `TopUpExecution` in `unified_broker_interface/utilities/order_engine/utilities/top_up_execution.py` in the sibling project, and the `top_up` branch of `PlanReader._read_execution_value` in `plan_reader.py`, as of 2026-10-02.

Its JSON is `{"top_up": {}}`, and UBI refuses any setting inside it as `unknown_setting`.

### What it is for

It only makes sense for an order whose size a join changes, such as the `each_fill` child of a `ThenPart`. Each time the target grows, one new broker order is sent for the quantity neither traded nor resting, so every broker order keeps the price it was given and its place in the queue; the default `all_at_once` would modify its one resting order instead. A target that shrinks cuts resting orders, newest first. A cancelled or rejected order stops it until the target next grows, as described in the section below.

UBI's `attached_hedge` and `legged_spread` presets use it for their second leg, which is why the example `calendar_spread_legged_in.py` writes a legged calendar spread out with it.

### Rules that bite

It is in neither nesting list, and a resting stop cannot use it, since a stop may only be `all_at_once` or `daily`.

### A cancelled order no longer comes straight back (2026-10-06)

Until UBI's commit `15380c1` of 2026-10-05, two things went wrong with a top-up order. Once all of its broker orders had filled it stopped growing, so later fills of an entry went unhedged while the parent ended `completed`. And a cancelled order was sent again at once, so an `IOC` hedge that the exchange cancelled unfilled was followed by another, and three cancellations gave four orders. UBI now reopens a filled top-up order whenever its target grows, and treats a cancelled order like a rejected one, ending the order until the first plan next fills, so what is missing is still sent but only once per fill. A rejection still ends it for good, and the parent then ends `failed` because the entry is left without its hedge. A caller's change to a hedge order's quantity is kept rather than modified back. The docstring was brought in line on 2026-10-06; it had said that a cancelled order's unfilled part is sent again.
