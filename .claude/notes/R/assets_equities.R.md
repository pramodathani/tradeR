# R/assets_equities.R

Port of `src/tradingmachine/assets/equities.py`, and the pattern the other five family files follow.

## How a family class is written

- The constructor calls `super$initialize()` inside `tryCatch(..., InstrumentError = ...)` and re-signals the family's own error with the original as `parent`, as the Python constructor's `except ... from error` does. An index given to `Equity` therefore becomes `EquityError` "UBI has no nse share", because the `TradeableInstrumentError` it first raises is an `InstrumentError`, which is also what Python does.
- The Python `SEGMENT` class attribute is not needed, because each discovery function names its segment constant directly.
- The discovery functions are written out on every class generator, rather than inherited from `Futures` and `Option`, because R6 generators do not inherit functions. They are documented in each class's description, since roxygen documents only R6 members.

## Checked against a fake client

On 2026-10-07 an `Equity` was driven against a fake client answering canned details, candles, order book, parents, positions and quote. Candle sorting, open-order filtering, `cancel_open_orders` skipping an order its cancelled parent covered and reporting a 409 in its frame, the JSON body of `buy_at_best_bid_price` and `liquidate_position`, the `add_to_position` direction error and the index-as-equity error all matched the Python code.
