# R/orders_plan_parts_lifetime.R

The R port of `src/tradingmachine/orders/plan_parts/lifetime.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`Lifetime` mirrors UBI's `Lifetime`, in `unified_broker_interface/utilities/order_engine/utilities/lifetime.py` in the sibling project, read by `PlanReader._read_lifetime_list` and checked by `PlanReader._can_end` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. It is what the `good_till_time`, `time_stop`, `good_till_triggered`, `daily_stop` and cancelling `account_conditional` presets are built from.

### The JSON shape

A lifetime is one entry of the order's `lifetime` list, not a one-key object, so `document()` returns the settings directly and `OrderPart` wraps it in a list of one:

```json
{"lifetime": [{"at_time": "14:30", "applies_to": "working", "on_end": "marketable"}]}
```

| Setting | UBI's rule |
|---|---|
| `at_time` | A string time of day on the instrument's next trading day |
| `after_minutes` | A number above zero, counted from placing; refused with HTTP 400 at placement on a day the instrument does not trade |
| `after_days` | A whole number from 1 to 365 (`MOST_DAYS`), of 24-hour days from placing; the plan then outlives the trading day and is rebuilt after the 06:00 reset |
| `when` | Any trigger condition, checked on every tick |
| `applies_to` | `waiting`, `working` or `both`; default `both` |
| `on_end` | `cancel`, `marketable` or `close_filled`; default `cancel` |

Exactly one of the four ends must be given, or the reader refuses the entry with `bad_setting`. The class does not check this, following the rule that UBI checks the whole plan, so its parameters all default to None. `applies_to` and `on_end` are left out when None so UBI's defaults apply. `when` takes any condition part, such as `PriceCrosses`, `TimeAt`, `AccountCondition` or `AnyCondition`, and is sent as that part's `document()`.

### Rules that bite

`_can_end` refuses three combinations:

| Combination | Problem rule | Why |
|---|---|---|
| `close_filled` on an order that is not the plan's root | `close_filled_needs_whole_plan` | Orders joined to it are sized to its fills and would be left protecting a position closed under them |
| `close_filled` on a `protect` order | `close_filled_on_protect` | Closing what a protecting order filled would open the position again |
| `marketable` on a stop pricing (`NativeStopPricing`, `TrailPricing` and the other stops) | `marketable_needs_limit` | A stop has no resting limit to move |

An order still waiting for its trigger when its end comes is done as expired, whatever `on_end` says; `on_end` only acts on an order already working.

A `RepeatPart` with `until` gives every copy a lifetime of its own, `Lifetime(applies_to='waiting', on_end='cancel', when=until)`, so an order repeated with `until` may not carry a lifetime; the reader refuses it with `until_with_lifetime`. An order also has one lifetime only: a second one from a preset replaces the first with a `lifetime_replaced` warning.
