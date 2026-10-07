# R/orders_plan_parts_cap_modifier.R

The R port of `src/tradingmachine/orders/plan_parts/cap_modifier.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`CapModifier` mirrors UBI's `CapModifier`, in `unified_broker_interface/utilities/order_engine/utilities/cap_modifier.py` in the sibling project, which `PlanReader._read_cap` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds. It was written on 2026-10-02.

### The JSON shape

```json
{"cap": {"worst_price": 1010.0}}
```

`worst_price` is required and must be above zero.

### Where it goes

A cap is a modifier, not a pricing setter. UBI reads it from the same `pricing` list as the setter, and `PlanReader._read_pricing_list` sorts the entries into one setter, one cap and one discretion. The class is therefore passed as `OrderPart(pricing=..., cap=...)`, and `OrderPart.document` puts it in the `pricing` list after the setter. A second cap in one list is refused with `two_caps`; a cap from a preset and another from the order itself is a replacement, reported as a warning.

### Rules that bite

- The cap holds for a buy as the most it pays and for a sell as the least it takes; the same class serves both.
- It replaces the `cap_price` setting of the `peg` and `chaser` synthetic types, which in a plan is no longer part of the pricing itself.
- A market order has no limit to cap, so a cap beside a `MARKET` `FixedPricing` has no effect.
