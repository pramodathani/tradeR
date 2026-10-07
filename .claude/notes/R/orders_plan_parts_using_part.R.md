# R/orders_plan_parts_using_part.R

The R port of `src/tradingmachine/orders/plan_parts/using_part.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## Specific to this file

As in Python, the `order` and `each_piece` objects are the inside of each `OrderPart`'s `order` key, read with `[["order"]]`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`UsingPart` mirrors UBI's `UsingPart`, in `unified_broker_interface/utilities/order_engine/utilities/using_part.py` in the sibling project, read by `PlanReader._read_using` in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`.

### The JSON shape

```json
{"using": {"order": {"execution": [{"twap": {"slices": 4, "over_minutes": 60}}]}, "each_piece": {"presets": [{"bracket": {"stop_price": 990.0, "stop_limit_price": 988.0, "target_price": 1020.0}}]}}}
```

Both values are the contents of an order, not order nodes: UBI checks that `order` and `each_piece` are objects and reads `order["execution"]` directly. The class therefore takes two `OrderPart` objects, for the sake of building them with the same slot parameters as any other order, and unwraps the `order` key from each document. Passing a join as either would raise a `KeyError` in `document()`; that is a misuse of the documented API rather than a validation the library performs.

### How UBI reads it

UBI makes one copy of `order` per piece its execution would send, with `execution` removed and `each_piece`'s values written on, and reads each copy as a whole plan at the path `<path>.pieces.<index>`. `each_piece`'s presets are appended after the order's own; every other slot must appear in only one of the two.

| Rule | Refused as |
|---|---|
| The order's `execution` is a list of exactly one value, `ladder`, `twap` or `front_loaded` (`USING_EXECUTIONS`) | `using_needs_pieces` |
| A timed execution gives `over_minutes`, not `until` (only `vwap` takes `until`, and `vwap` is not allowed anyway) | `using_needs_pieces` |
| `each_piece` takes no `execution` | `using_piece_execution` |
| A slot other than `presets` given in both | `using_slot_twice` |
| A `pricing` in either side beside a `ladder`, because the ladder prices each rung | `using_ladder_priced` |

A ladder's copies each get their rung's price and share, and a timed execution's copies wait `interval * index` from the start through an elapsed condition joined to any trigger they already have. `inner_execution` on the order would make the execution list two long, which UBI refuses.

### Rules that bite

- The join is never resized, so it cannot be a `then` join's child.
- Giving every piece an exit means naming a preset that expands to a `then` join, such as `bracket` or `cover`. A slot-value preset such as `trailing_stop` would instead turn each piece itself into a protecting order rather than following it with one.

### Two new refusals for each_piece (2026-10-06)

UBI's commit `b507de0` of 2026-10-05 refuses a `quantity` in `each_piece` with `using_piece_quantity`, because UBI used to split it as though it were the whole order's quantity rather than give it to each piece, and a preset naming a type kept whole, such as a `grid`, with `using_piece_kept_whole`, because such a type placed its orders at once and ignored its piece's turn and price. Since UBI's commit `0ec2a34`, a problem inside a piece is reported at `each_piece` or `order`, whichever holds the setting, with `part` naming the piece as it runs, rather than at a path such as `root.pieces.0`.
