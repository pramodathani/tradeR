# R/orders_plan_parts_candle_closes.R

The R port of `src/tradingmachine/orders/plan_parts/candle_closes.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`CandleCloses` mirrors UBI's `CandleClosesCondition`, in `unified_broker_interface/utilities/order_engine/utilities/candle_closes_condition.py` in the sibling project, read by `PlanReader._read_candle_closes` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. It keeps the rules of the `candle_close_stop` synthetic type, whose preset builds this condition.

### The JSON shape

```json
{"candle_closes": {"level": 995.0, "direction": "at_or_above", "bar_minutes": 15}}
```

| Setting | Required | UBI's default | UBI's check |
|---|---|---|---|
| `level` | Yes | None | A number above zero, read as a Decimal |
| `direction` | No | From the opening side | `at_or_above` or `at_or_below` |
| `bar_minutes` | No | 5 | A number above zero; the reader's message calls it seconds, but the condition multiplies it by 60, so it really is minutes |

Any other key is refused as an unknown setting. Settings left as None are left out so UBI's defaults apply.

### Rules that bite

- The bars are built by the engine from the last traded price it sees, aligned to the clock, and kept in the condition's memory, so nothing is known until the first whole bar after the order rests has closed. A plan placed at 10:02 with five-minute bars can first fire at 10:10, not 10:05.
- It answers once per bar, at the close, so it is slower than a touch by design.
- With no direction, the direction follows the side that opened the position, not the side the order is sent on: a long (opened with a buy) waits for a close at or below the level and a short for one at or above it. That is a stop's meaning, so for a breakout entry give the direction explicitly, as the breakout example does.
