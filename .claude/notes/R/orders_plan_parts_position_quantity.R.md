# R/orders_plan_parts_position_quantity.R

The R port of `src/tradingmachine/orders/plan_parts/position_quantity.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## Specific to this file

`held_instruments` is a `list()` of instruments, and each one is sent as its `instrument_id`, collected into a `list()` so one instrument is still an array.

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

`PositionQuantity` mirrors UBI's `PositionQuantity`, in `unified_broker_interface/utilities/order_engine/utilities/position_quantity.py` in the sibling project, read by `PlanReader._read_position` and checked with the order's side by `PlanReader._closes_sensibly` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. The `close_on_trigger`, `square_off` and `stop_and_reverse` presets build it.

It is passed to `OrderPart(quantity=...)`, which sends a `PlanPart` quantity as its document.

### The JSON shape

```json
{"position": {"product": "intraday", "instrument_ids": ["e7d0deaa-..."], "ratio": 2, "cancel_resting_first": false}}
```

| Key | UBI's default | How the class sends it |
|---|---|---|
| `product` | the body's product; one of `intraday`, `delivery`, `carry` (UBI's `PRODUCTS`) | sent when not None |
| `instrument_ids` | the order's own instrument; a non-empty list of strings | built from `held_instruments`, each object's `instrument_id` |
| `every_instrument` | `false` | `bool = False`, sent only when True; refused beside `instrument_ids` |
| `ratio` | `1`; only 1 or 2 | sent when not None |
| `cancel_resting_first` | `true` | `bool | None = None`, sent only when not None |

### Rules that bite

- The product is a position product, not an order product: `mis` is refused, `intraday` is right. This is the same naming trap `TradeableInstrument.reduce_position` has.
- The order's side must be `close` (`position_needs_close`), and a `close` side needs this quantity (`close_needs_position`).
- A close takes no pricing or execution of its own (`close_prices_itself`); UBI prices each closing order two ticks past the other side's touch and sends each broker's share to the broker holding it.
- Nothing held ends the plan `completed` without an order.

### Naming

The parameter is called `held_instruments` rather than `instruments`, which would have hidden the imported `tradingmachine.assets.instruments` module inside `__init__`; the name also says which instruments are meant, those whose positions are closed.
