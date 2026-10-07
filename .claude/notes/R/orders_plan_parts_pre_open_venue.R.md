# R/orders_plan_parts_pre_open_venue.R

The R port of `src/tradingmachine/orders/plan_parts/pre_open_venue.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`PreOpenVenue` mirrors UBI's `PreOpenVenue`, in `unified_broker_interface/utilities/order_engine/utilities/pre_open_venue.py` in the sibling project, read by `PlanReader._read_venue_list` and turned into a trigger in `PlanReader._read_order` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. The `opening_auction` preset builds it.

### The JSON shape

A venue is an entry of the order's `venue` list, not a one-key object, so `document()` returns the entry and `OrderPart` wraps it in a list of one:

```json
{"order": {"venue": [{"session": "pre_open", "at_time": "09:02"}]}}
```

`at_time` defaults to `09:00:30` in UBI and must parse as a time of day; the class sends it only when given. Any other key is refused.

### Rules that bite

- UBI sends the order at `at_time` through a `time_from` trigger it builds itself, so the order takes no trigger of its own (`pre_open_sets_its_time`), whether written out or from a preset.
- The pre-open takes only `LIMIT` and `MARKET` orders, on NSE and BSE cash until 09:10 (market orders until 09:05) and on NSE stock and index futures until 09:07. Anything else, or an order taken after collection closed on a trading day, is refused with HTTP 400 when placed; the offline reader does not check that.

The constructor is keyword-only, like the other parts with settings, even though it has one parameter.
