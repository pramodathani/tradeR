# R/orders_plan_parts_limit_marketable.R

The R port of `src/tradingmachine/orders/plan_parts/limit_marketable.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`LimitMarketable` mirrors UBI's `LimitMarketableCondition`, in `unified_broker_interface/utilities/order_engine/utilities/limit_marketable_condition.py` in the sibling project, read inline by `PlanReader._read_condition` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. It keeps the rules of the `virtual_limit` synthetic type, whose preset builds this condition, and with `paper: true` adds the paper venue.

The class takes no arguments and has no `__init__`, because the condition has no settings.

### The JSON shape

```json
{"limit_marketable": {}}
```

Anything other than an empty object is refused with `bad_setting`.

### Rules that bite

- **The order takes no pricing of its own.** `PlanReader._holds_at_its_limit` looks for the condition on its own or anywhere inside an `all` or `any` group, and when it is there `_held_at_the_body_price` accepts only the default pricing, a `fixed` setter with neither a price nor an order type. Any pricing rule, even `FixedPricing(price=...)`, is refused with `held_at_the_body_price`. The price is the plan's template's own `LIMIT` price.
- **The template must be a LIMIT order with a price.** That is checked when the plan is placed, not by the offline reader, and refused with HTTP 400. The examples therefore print only the order part and say in words what the template carries.
- It holds once the opposite touch reaches the limit: for a buy, the best offer at or below it, and for a sell, the best bid at or above it. A stale quote never holds.
- When the plan is placed, the condition writes the held terms into its memory, and `bin/unified/orders/virtual_book` estimates from them how much a resting order at the same limit would have filled. When the order is sent, that estimate is kept as `missed_quantity` in the part's record.
- A `PaperVenue` order must wait on `limit_marketable` alone and be the whole plan, because its fills come from that estimate.
