# R/asset_baskets_watchlist.R

This is the R port of `tradingmachine/asset_baskets/watchlist.py`. `Watchlist` takes plain instruments rather than `BasketMember` objects, because a watchlist has no weights or quantities and asking for members would only add noise at the call site. It adds `add()` and `rank_by()`; everything else, including `top_gainers()`, `breadth` and the equal-weighted candles, comes from `AssetBasket`.

The constructor's argument is named `instruments`, the same as the active binding the basket has. In R the argument is a local variable of `initialize` and the binding is reached only through `self$instruments`, so the two never meet; the Python note's concern about lazily evaluated annotations does not arise.

## Where the R version differs from Python

| Python | R | Why |
|---|---|---|
| `rank_by` with an unknown column raises pandas' `KeyError` | `KeyError`, `Not a column of ohlc: '<column>'` | `KeyError` was added to `ErrorCatalogue` on 2026-10-07 for this |
| `sort_values(ascending=..., na_position="last")` | `order(..., decreasing = !ascending, na.last = TRUE, method = "radix")` | Both keep tied members in their original order: pandas sorts a descending column by reversing, sorting stably and reversing back |
| `KIND` class attribute | Public field `KIND` and `Watchlist$KIND` on the generator | Agreed for every basket class |
