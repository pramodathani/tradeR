# R/asset_baskets_portfolio.R

This is the R port of `tradingmachine/asset_baskets/portfolio.py`. `Portfolio` is a basket counted in units. It overrides `weights` with each member's share of today's value, divided by the gross value so a short position shows as a negative weight, and the private `candle_quantities` with the real quantities, so its candles show what today's holdings were worth at each past candle.

## Built from the account

`Portfolio$from_holdings()` reads `GET /api/portfolio/holdings` and `Portfolio$from_positions()` reads `GET /api/portfolio/positions`, then resolves every instrument in one list request through `MemberResolver`. A position held under two products, such as intraday and carry, becomes one member with the total quantity and no average price, because two average prices cannot be combined without the two quantities' cost, and a member may appear only once.

The Python note records the live check of 2026-09-28: `from_holdings` built seven members and valued them at 9,240.43 rupees, against UBI's summary of 9,237.33, with an invested value of 11,216.62 against UBI's 11,216.99. The value differs because the portfolio prices at the live last price while UBI's summary uses the prices in its holdings document; the invested value differs because UBI adds the brokers' own invested figures. The R port has not been run against the live UBI.

## Orders go in UBI's list form, not the basket order

`place_orders()` and `rebalance()` send one `POST /api/orders/place` with `list(orders = ..., dry_run = ...)`. UBI's `basket` synthetic order was rejected for this, because it takes at most 25 legs and sends every leg to the first leg's broker, so a NIFTY portfolio of 50 would not fit. The list form takes up to 500 orders and places them in parallel, each at the broker that suits it. `dry_run` goes beside the list, never inside an order, which UBI refuses. The request gets a 60-second timeout because UBI waits up to 25 seconds for the engine's answers.

Only market orders are sent. A limit order would need one price per member, which a portfolio does not have, and a plain limit order would be held by UBI's engine rather than sent. Each answer's `broker` is kept in the table, because a dry run shows which broker each order would go to.

Since 2026-10-06 UBI runs plain market bodies as `marketable_limit` orders. `as_marketable_limit = FALSE` adds `synthetic = list(type = "simple")` to every body.

## Rebalancing is computed here

Rebalancing to target weights is portfolio arithmetic that UBI does not offer, so it is built here. Quantities are floored towards zero to whole units and sent as computed, with no lot or tick check. `rebalance_trades()` is separate from `rebalance()` so the trades can be read before anything is sent.

## Where the R version differs from Python

| Python | R | Why |
|---|---|---|
| `Portfolio.from_holdings` and `from_positions` are class methods | Functions stored on the generator, `Portfolio$from_holdings()` and `Portfolio$from_positions()` | R6 generators carry no class methods; this is the project's mapping |
| `target._weights_by_instrument_id()` on another basket | `private$weights_by_instrument_id_of(target)`, inherited from `AssetBasket` | An R6 object cannot call another object's private method; the helper reads only the target's public `weights` and `members`, which is all the Python method reads |
| `pandas.Series` for `quantities`, `values` and `weights` | Named numeric vectors whose names are the member labels | Agreed for every basket file |
| `_plain_number` turns a whole float into an `int` | `plain_number` turns a whole number into an R integer, when it fits in one | jsonlite writes both `5` and `5L` as `5`, so the JSON body is the same; the integer also makes the request list show the intent |
| `_whole_units` uses `math.floor` on the absolute value | `trunc()` | Both round towards zero |
| An empty plan returns `pd.DataFrame(columns=columns)` | A zero-row `data.frame` with the same eleven columns, typed as character or numeric | A base data frame needs a type per column |
| `rebalance_trades` with no trades returns an empty frame with seven columns | The same, as a zero-row typed `data.frame` | As above |
| Sorting by `trade_quantity` uses pandas' default sort | `order(..., method = "radix")`, which is stable | pandas sorts short arrays with insertion sort, which is stable too, so ties keep the instruments' order: held members first, then target-only members |
| `dry_run` is sent as `bool(dry_run)` | `isTRUE(as.logical(dry_run))` | The JSON always carries `true` or `false` |
| A missing value in the answer table is `None` | `NA`, and a column UBI never filled, such as `parent_id` in a dry run, is a logical `NA` column | `FrameBuilder` makes an all-missing column logical |
| The weights error message uses `{self.name!r}` | `'name'` in single quotes | Matches Python's repr for an ordinary string |
