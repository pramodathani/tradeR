# R/orders_plan_parts_account_condition.R

The R port of `src/tradingmachine/orders/plan_parts/account_condition.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`AccountCondition` mirrors UBI's `AccountCondition`, in `unified_broker_interface/utilities/order_engine/utilities/account_condition.py` in the sibling project, read by `PlanReader._read_account` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. It keeps the rules of the `account_conditional` synthetic type, whose preset builds this condition either as a trigger or, with `action: cancel`, as a lifetime's `when`.

The module is named `account_condition` rather than `account` so it does not clash in reading with `tradingmachine.accounts.account`; the class name matches UBI's.

### The JSON shape

```json
{"account": {"field": "day_pnl", "level": -5000.0, "direction": "at_or_below"}}
```

All three settings are required, which is why the constructor has no defaults. Any other key is refused.

| `field` | What UBI reads |
|---|---|
| `available_balance` | `summary.available_balance` of the funds document in Redis under `unified:portfolio:funds`, the free margin across every broker |
| `day_pnl` | `pnl.realized` plus `pnl.unrealized` of the same document, across every broker |
| `open_positions` | The count of net positions with a non-zero quantity across every broker |

`level` is any finite number, so a negative level for a day's loss and 0 for "no positions open" are both accepted. `direction` must be `at_or_above` or `at_or_below`; UBI requires it because nothing about an order says which way an account figure should move.

### Rules that bite

- It reads no quotes, so the engine checks it once a second on the clock rather than on ticks.
- When the figure cannot be read, for example when Redis has no funds document, the condition simply does not hold, so an order waiting on it waits rather than firing.
- The figures are account-wide, not per instrument, so a plan on one share can be gated by losses on another.
