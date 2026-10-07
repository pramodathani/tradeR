# R/asset_baskets_index.R

This is the R port of `tradingmachine/asset_baskets/index.py`. `Index` is the class `EquityIndex$constituents` and every other index's `constituents` return. It also serves an index the user makes up, with no linked instrument.

## Three weightings

`stated` uses each member's weight, as a factsheet gives it. `equal` ignores any weights, which is also what a CSV without a weight column gets. `price` weights by price, which is holding the same quantity of each, the Dow Jones method; its `weights` need live prices and its private `candle_quantities` gives every member the same quantity. A market-capitalisation weighting was not offered, because UBI has no shares-outstanding or free-float data to compute it from.

## `level` needs a base date

`prices()` restarts from `base_value` at the first candle of whatever range is asked for, so it cannot report a single level. `level` fixes the quantities at the closes of `base_date`, searching up to ten days forward for the first trading day, and values them at today's last prices. Without a `base_date` it signals `AssetBasketError` rather than inventing one. The Python note records a live check on 2026-09-28: a price-weighted index of five NIFTY stocks from 2026-01-01 stood at 78.39. The R port has not been run against the live UBI.

## `to_portfolio`

`to_portfolio()` floors each member's share of the capital to whole units at last prices and leaves out a member whose share buys less than one unit. The Python note records 500,000 rupees in the price-weighted five-stock index giving 83 of each, worth 497,439.75.

## Where the R version differs from Python

| Python | R | Why |
|---|---|---|
| `datetime.date.fromisoformat(base_date)` raises `ValueError` for bad text | `TimeConverter$date()` signals a plain error with Python's message, `Invalid isoformat string: '...'` | The shared converter is the project's one date parser |
| `math.floor` gives a Python `int` quantity in `to_portfolio` | The floored quantity is turned into an R integer when it fits | So the member reads `quantity=83` like Python's repr, and is stored as a whole number |
| The "buys no whole unit" message prints `capital` with Python's `str` | `format(capital, digits = 15)` | R cannot tell `500` from `500.0`; a whole number prints without `.0` |
| `ValueError` messages use `{weighting=}` and `{base_value=}` | `weighting='<value>'` and `base_value=<Python repr>` | Same text as Python |
| `level` passes `base_date + timedelta(days=10)` | `self$base_date + 10`, which R's `Date` arithmetic counts in days | Same range |
| Python's `Index.weights` calls `super().weights` for a stated weighting | The active binding calls `super$weights` | R6 2.6 lets a subclass reach the parent's active binding through `super$` |
| `document` sets `base_date` to `None` | Sets the element to `NULL` with `document["base_date"] <- list(NULL)`, so the name stays in the list | `document[["base_date"]] <- NULL` would delete the element, and MongoDB must receive an explicit null |
| Pandas `Series` for `weights` | A named numeric vector | Agreed for every basket file |
