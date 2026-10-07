# R/orders_plan_parts_together_part.R

The R port of `src/tradingmachine/orders/plan_parts/together_part.py`, one part of a `PlanOrder`'s tree. The plan parts are described as a family in the note for `R/orders_plan.R`.

## Specific to this file

The children, conditions or rules are given as a `list()` of parts, the R counterpart of Python's sequence, and their documents are collected into a `list()`, so a list of one child is still a JSON array and an empty list is `[]`.

## How the R version differs from Python

The class keeps Python's name, its field names and its argument names in the same order, so a Python example translates line for line with `Class(...)` written as `Class$new(...)`. Python's keyword-only arguments become ordinary named arguments, because R has no keyword-only marker. A required Python argument has no default in R either.

`document()` returns a named list that the client encodes with `jsonlite::toJSON(auto_unbox = TRUE)`. Two R details make the JSON come out exactly as Python's does:

- An object that may end up with no keys starts as `structure(list(), names = character(0))`, which jsonlite writes as `{}`. A plain `list()` would be written as `[]`, which UBI would refuse.
- Every JSON array is built as an R `list()`, never an atomic vector, because `auto_unbox = TRUE` would turn a vector of length one into a single value.

A setting is left out exactly where Python leaves out `None`, by testing `!is.null()`, and a boolean whose UBI default is `FALSE` is sent only when it is `TRUE`, tested with `isTRUE()` so that `NULL` behaves like Python's falsy `None`. Settings are added with `settings[["name"]] <- value`; a required setting given as `NULL` on purpose would therefore be dropped in R where Python sends `null`, which only matters for a call that is already wrong.

The file was first generated from the Python module with an `ast`-based script kept in the session scratchpad (`plan_generator/generate.py`), then reviewed by hand. Parity with Python was checked on 2026-10-07 by building the same parts in both languages and comparing the JSON structurally (`parity/plan/` in the same scratchpad): every part case and every docstring example matched.

## Carried over from the Python note

The Python note records UBI's behaviour and the reasons for the design, all of which still apply to the R port.

`TogetherPart` mirrors UBI's `TogetherPart`, in `unified_broker_interface/utilities/order_engine/utilities/together_part.py` in the sibling project, read by `PlanReader._read_together`, which hands the list to `PlanReader._read_children`, in `unified_broker_interface/utilities/order_engine/utilities/plan_reader.py`. UBI's `basket` preset expands to this join, one child per candidate, with `group_margin` on.

### The JSON shape

```json
{"together": {"children": [{"order": {}}, {"order": {}}], "group_margin": true, "hedge_benefit": true, "done_when": "any"}}
```

| Key | UBI's default | How the class sends it |
|---|---|---|
| `children` | required, 1 to 25 plans (`MOST_CHILDREN`) | always |
| `group_margin` | `true` | `bool | None = None`, sent only when not None, because UBI's default is True |
| `hedge_benefit` | `false` | `bool = False`, sent only when True |
| `done_when` | `all`; the other value is `any` (UBI's `DONE_WHEN`) | sent only when not None |

Any other key is refused as `unknown_setting`, and a non-boolean flag or an unknown `done_when` as `bad_setting`.

### Rules that bite

- Each child trades its own quantity, so a child with no `quantity` of its own uses the body's. Nothing ties the children's sizes together; for that, use an `either` join with `reduce`.
- Only the first child's main order carries the caller's tag (`keeps_tag and index == 0` in `_read_children`).
- A together join cannot be a `then` join's child (`join_not_sized`), because that child is sized to the first plan's fills.
- Unlike `sequence`, a together join accepts a single child; UBI's smallest for it is 1.
- `hedge_benefit` matters only to the broker selector's affordability check; it prices options and futures on one underlying and expiry together, as the `basket` type does.

The children are kept as a list built from the sequence given, so a caller's later change to their own list does not alter the join, matching `EitherPart`.
