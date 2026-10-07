# R/orders_plan_parts_option_model_pricing.R

The R port of `src/tradingmachine/orders/plan_parts/option_model_pricing.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

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

`OptionModelPricing` mirrors UBI's `OptionModelPricing`, in `unified_broker_interface/utilities/order_engine/utilities/option_model_pricing.py` in the sibling project, which `PlanReader._read_option_model` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds. It was written on 2026-10-02 and keeps the rules of UBI's `volatility` synthetic type. UBI's class is a subclass of its `FollowInstrumentPricing`; this one is self-contained instead, following the user's rule that each case is its own readable class.

### The JSON shape

```json
{"option_model": {"instrument_id": "dba60324-...", "volatility": 13.0, "interest_rate": 6.5, "lowest": 50.0, "highest": 120.0, "step_ticks": 2}}
```

`instrument_id`, the option's underlying, and `volatility` are required. `volatility` is a percentage above zero and at most `HIGHEST_VOLATILITY_PERCENT`, 500, so 13% is written `13.0`, not `0.13`. `interest_rate` is a yearly percentage defaulting to 0 and may be any finite number. `lowest`, `highest` and `step_ticks` work as in `follow_instrument`.

### Rules that bite

- UBI prices with Black-76. A future as the underlying is treated as the forward, so no interest rate is needed; an index or a share is grown to expiry by `interest_rate`, so leaving it at 0 underprices a call slightly.
- The option's strike, expiry and kind are read from UBI's catalogue when the plan is placed, and an order whose instrument is not an option is refused then with HTTP 400. The offline `PlanReader` does not check that.
- The template's own price is the worst the order accepts, so the `PlanOrder` should be a `limit` with a price.
- The examples find the nearest weekly Nifty contract with `EquityIndexOption.expiries` and `chain`, which are read-only. The index's symbol in UBI is `NIFTY`; `NIFTY 50` is not found.
