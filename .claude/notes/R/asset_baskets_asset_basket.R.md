# R/asset_baskets_asset_basket.R

The R port of `src/tradingmachine/asset_baskets/asset_basket.py`, made on 2026-10-07.

`AssetBasket` is the shared base of every basket. It holds only what is genuinely the same for every kind: the members, the list requests to UBI, the weights, the history methods, and the candles for the whole basket. Each kind of basket is its own class in its own file, following the user's rule of self-contained classes over one parameterised abstraction.

## Candles for the basket, so it inherits the analysis

The user chose on 2026-09-28 that a basket should inherit the analysis methods an instrument has. In R the analysis classes are one chain ending in `PerformanceMeasures`, so `AssetBasket` inherits `PerformanceMeasures`, the same class `Instrument` inherits, and supplies its own `prices()`, which is all the analysis methods read.

Each candle is the sum over members of a fixed quantity times the member's candle. `candle_quantities` decides the quantities: the base class spreads `base_value` (100) across the members by weight at the first candle's closes, which is how a price index moves between rebalances; `Portfolio` uses its real quantities; a price-weighted `Index` holds the same quantity of each. The open and close are exact. The high and low are the sums of the members' highs and lows, an upper and lower bound, because the members do not reach their highs at the same moment. Volume and open interest are `NA`, because a sum of volumes across different shares has no meaning.

Only candles every member has are kept, joined on `datetime`. As in Python, only the close decides which times are shared; an open, high or low that is missing at a shared time counts as zero in the sum, which is what pandas' `sum(axis="columns")` does with NaN. The sum is a plain loop adding one member at a time in member order, the same order numpy adds a short row, rather than `rowSums`, which adds in extended precision and could differ in the last bit. A member with no candles at all makes `prices` return `NULL` rather than a basket quietly missing it.

## Live members read the whole basket in one request

`last_prices`, `ohlc` and `quotes` send one `POST` naming every member. A member UBI has no price for gets a row with its `error` filled in rather than failing the call, and a total such as `day_change_percent` is `NULL` when any member is missing. The history methods signal `BasketMemberError` when UBI answers an error for a member, because a history with a member missing would be wrong rather than incomplete.

`post_for_instruments` sorts the answer by `request_index`, which UBI documents as the way to match entries to the request.

## How pandas shapes became R shapes

| Python returns | R returns | Members |
|---|---|---|
| A Series indexed by member label | A named numeric vector whose names are the labels | `weights`, `exposure_by_segment`, `exposure_by_exchange` |
| A DataFrame indexed by `datetime` with one column per label | A `data.frame` whose first column is `datetime`, followed by one column per label in member order | `member_closes`, `member_returns` |
| A DataFrame indexed by label | A `data.frame` whose row names are the labels, with the same columns as Python | `covariance_matrix`, `correlation_matrix`, `risk_contributions`, `return_contributions` |
| A dict | A named list | `breadth`, `document`, `last_prices_by_instrument_id` |
| `None` in a column, such as `exchange` in `prices` or `error` in `ohlc` | `NA` | |

`ohlc` turns a price column that came back all missing into a numeric column of `NA`, so `top_gainers` and `breadth` can compare it with numbers.

## Where R differs from Python

| Python | R | Why |
|---|---|---|
| `_weights_by_instrument_id()` called on another basket by `overlap_with` and `Portfolio.rebalance_trades` | `private$weights_by_instrument_id_of(basket)` | An R6 object cannot call another object's private method. The helper reads the other basket's public `weights` and `members`, which is everything the Python method reads, so the result is the same. |
| `_check_members` and the other `@staticmethod` helpers | private methods | Behaviour lives on the class, and R6 has no static methods |
| Class attribute `KIND` | public field `KIND`, overridden by each subclass, and `AssetBasket$KIND` on the generator | So both `basket$KIND` and `AssetBasket$KIND` work, as `basket.KIND` and `AssetBasket.KIND` do |
| `__repr__` | `format()` and `print()` | The package's rule |
| `datetime.date.today()` for a missing `effective_date` | `Sys.Date()` | Both read the machine's local date |
| `sort_values` | `order(..., method = "radix")` | Radix ordering is stable and compares text byte by byte, as pandas does, so ties keep member order as pandas' single-column sort does |
| `DataFrame.cov()` and `.corr()` | `stats::cov()` and `stats::cor()` | Same definitions, with n - 1 in the denominator; results agree to about 1e-16 |
| `ValueError` | `ErrorCatalogue$raise("ValueError", ...)` | The package's language error classes |

## Why there is no `save` method

The Python plan gave the basket a `save` method. It was dropped because the basket would have had to import the store, and the store imports every basket class. Callers write `BasketStore$new()$save(basket)` instead.

## Measures chosen

- `risk_contributions` is the standard Euler split: a member's weight times its covariance with the basket, divided by the basket's variance, which adds up to 1.
- `diversification_ratio` is the weighted average of member volatilities over the basket's volatility, Choueifaty's definition.
- `concentration` is the Herfindahl index, and `effective_number_of_members` its inverse.
- `overlap_with` is the sum of the smaller weights, the usual portfolio-overlap test for funds.
- `return_contributions` weights each member's return by its share of the value at the first candle, so the contributions add up to `cumulative_return` exactly.

## Examples

The Python docstrings give every property two examples. R6 active bindings cannot carry `@examples`, so the property examples are translated into the class's `@examples`, sharing one weighted basket (`basket`) and one equal-weighted basket (`banks`) built at the top rather than rebuilding them for every example. Method examples rebuild what they need, so each method's examples run on their own.

## Parity with Python

Checked on 2026-10-07 with the scripts in the session scratchpad's `parity/baskets/`; the results are in that directory's `README.md`.
