# R/orders_plan_parts_follow_instrument_pricing.R

The R port of `src/tradingmachine/orders/plan_parts/follow_instrument_pricing.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## Specific to this file

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

`FollowInstrumentPricing` mirrors UBI's `FollowInstrumentPricing`, in `unified_broker_interface/utilities/order_engine/utilities/follow_instrument_pricing.py` in the sibling project, which `PlanReader._read_follow_instrument` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds. It was written on 2026-10-02 and keeps the rules of UBI's `underlying_peg` synthetic type.

### The JSON shape

```json
{"follow_instrument": {"instrument_id": "dba60324-...", "delta": 0.5, "lowest": 125.6, "highest": 188.3, "step_ticks": 2}}
```

`instrument_id` and `delta` are required. `delta` is any finite number, so a negative delta for a put is accepted. `lowest` and `highest` must be above zero, and `lowest` may not be above `highest`. `step_ticks` defaults to 1.

### Naming choice

The class takes an instrument object rather than an id string, the same as `PriceCrosses`, and sends its `instrument_id`. The synthetic type calls the same field `watch_instrument_id` and its bounds `lowest_price` and `highest_price`; in a plan they are `instrument_id`, `lowest` and `highest`, and the class follows the plan's names.

### Rules that bite

- The price starts at the template's own limit price, so the `PlanOrder` must be a `limit` order with a `price`, and the followed instrument must be another one than the order's own. Both are checked only when the plan is placed, with HTTP 400; the offline `PlanReader` does not check them.
- Nothing in the plan says which instrument the order trades except the `PlanOrder` or the `OrderPart`'s own `instrument`, so the examples build a `PlanOrder` on a real Nifty option without placing it.
