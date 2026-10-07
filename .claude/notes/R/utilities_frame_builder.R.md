# R/utilities_frame_builder.R

The Python library turns UBI's lists of rows into frames with `pandas.DataFrame(rows)` and walks them back with `frame.to_dict("records")`. R has no single equivalent that handles missing fields and nested objects the same way, so this class does both explicitly.

## Choices

- `jsonlite::fromJSON(simplifyVector = FALSE)` is used throughout the client, so every answer arrives as plain lists, exactly as Python's `response.json()` gives dictionaries. Letting jsonlite simplify would turn some answers into data frames and leave others as lists depending on their shape, which makes code harder to follow.
- A column holding only single numbers, strings or logicals becomes an ordinary vector, with `NA` for a missing value, as pandas fills `NaN` or `None`.
- A column holding anything else, such as a position's `pnl` object, becomes a list column. `frame$pnl[[1]]$realized` then reads like Python's `row["pnl"]["realized"]`.
- A column mixing types, such as numbers in some rows and strings in others, also stays a list column rather than being coerced to text.
- No rows gives `NULL`, matching the Python library's rule that "no rows" is `None` rather than an empty frame.
