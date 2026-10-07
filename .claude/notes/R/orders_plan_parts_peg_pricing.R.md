# R/orders_plan_parts_peg_pricing.R

The R port of `src/tradingmachine/orders/plan_parts/peg_pricing.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`PegPricing` mirrors UBI's `PegPricing`, in `unified_broker_interface/utilities/order_engine/utilities/peg_pricing.py` in the sibling project, which `PlanReader._read_peg` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py` builds. It was written on 2026-10-02.

### The JSON shape

```json
{"peg": {"reference": "mid", "offset_ticks": 1, "follows": false, "within_body_price": true}}
```

Every key is optional, and an empty `{"peg": {}}` is a valid peg to the own touch. The defaults are `reference` `own_touch`, `offset_ticks` 0, `follows` true and `within_body_price` false. `reference` must be one of UBI's `REFERENCES`, `own_touch`, `mid` or `opposite_touch`; `offset_ticks` must be a whole number, and a bool is refused; any other key is refused with `unknown_setting`.

### Why the booleans are typed differently

`follows` defaults to true in UBI, so the class takes `bool | None = None` and sends it only when it is not None, which is the only way to say false. `within_body_price` defaults to false, so the class takes `bool = False` and sends it only when True. This is the spec's general rule for booleans.

### Rules that bite

- A peg to `opposite_touch` means to trade at once, so `PlanReader._can_rest` refuses it beside a `PostOnlyGuard` with `post_only_crosses`. A peg to `own_touch` or `mid` may carry the guard.
- `within_body_price` reads the *template's* limit price, the `price` of the `PlanOrder`, not a `FixedPricing` in the same order, because an order holds only one pricing setter and a second is refused with `two_setters`. The example `one_shot_bid_within_a_limit.py` therefore builds a `PlanOrder` (without placing it) so the template's price is real.
- `follows: false` with `within_body_price` is how UBI's `accumulation` preset prices each purchase.
- A pegged order may sit inside a `TwapExecution` and similar executions, and UBI moves every piece still resting.

### on_empty_book, added on 2026-10-06

UBI's commit `165a2ad` gave the peg the setting `on_empty_book`, `wait` by default or `refuse`. With `refuse`, a peg that cannot be priced when it is first sent, because nobody is on the side its reference reads, no live quote has arrived or the quote is marked stale, ends its part as refused, and a plan with nothing else placed answers HTTP 409. UBI built it for its `marketable_limit` preset. The attribute is sent only when it is not None, like `reference` and `follows`, and its value is not checked here because UBI refuses any other value with HTTP 400.
