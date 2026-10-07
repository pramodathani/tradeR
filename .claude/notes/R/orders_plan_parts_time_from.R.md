# R/orders_plan_parts_time_from.R

The R port of `src/tradingmachine/orders/plan_parts/time_from.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`TimeFrom` mirrors the `time_from` kind of UBI's `TimeCondition`, in `unified_broker_interface/utilities/order_engine/utilities/time_condition.py` in the sibling project, which `PlanReader._read_condition` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds for any key in `KINDS` whose value is a string. It was written on 2026-10-02 as an exact copy of `time_at.py` and `time_after.py`, taking the time as its one positional argument, because the four time conditions differ only in their key.

### The JSON shape

```json
{"time_from": "15:00"}
```

The value must be a string; anything else is refused with `bad_setting`. UBI accepts `HH:MM` or `HH:MM:SS`, read in India's time.

### How it differs from time_at and time_after

`time_at` and `time_after` work out the moment once, when the plan is placed, and a time already passed on a trading day is refused with HTTP 400. `time_from` checks first whether today is a trading day for the instrument and the time has passed; if so it holds at once from the moment of placing, and otherwise it falls back to the same next-trading-day rule as `time_at`. That is why UBI uses it for the `closing_price` preset, which starts at once when placed inside its window, and for the pre-open venue, whose `at_time` is turned into a `time_from` trigger by the reader. The rejection only happens at placement time, so the offline `PlanReader` accepts a passed `time_at` too; the difference cannot be seen without placing an order.
