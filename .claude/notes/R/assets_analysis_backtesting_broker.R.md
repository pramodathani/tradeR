# R/assets_analysis_backtesting_broker.R

`BacktestBroker` is the R counterpart of backtesting.py 0.6.5's `_Broker`. `next_bar()`, `process_orders()`, `reduce_trade()`, `close_trade()` and `open_trade()` follow `_Broker.next`, `_process_orders`, `_reduce_trade`, `_close_trade` and `_open_trade` line by line, so the fill rules are the same:

| Situation | Fill price |
|---|---|
| Market order | Next candle's open, or the previous close with `trade_on_close` (a stop-loss or take-profit always uses the open) |
| Stop reached | Becomes a market or limit order; a market fill is no better than the stop |
| Limit reached | The limit, or the open (or the stop just reached) when that is better |
| Limit and stop both on one candle | The limit is assumed to come first, so the order waits |

## Choices that differ in form from Python

- `_process_orders` was split into `process_orders()`, `fill_closing_order()`, `fill_opening_order()` and `needs_reprocessing()` to keep each method short. The order of operations is unchanged.
- `next()` raised `_OutOfMoneyError`; `next_bar()` returns `TRUE` instead, because R has no cheap way to use an exception for control flow and the loop only needs to stop.
- Lists of orders and trades are searched by identity with `identical()`, which compares R6 objects as the same environment, matching Python's `in` and `is` on objects without `__eq__`.
- The spread is always zero, because `run_backtest()` does not expose it, so `_adjusted_price` disappeared.
- The fractional order size uses `floor(a / b)` where Python uses `a // b` on floats. They can differ only when the quotient rounds to a whole number at the last bit, which did not happen in any parity run.
- Candle numbers count from 1.

## A Python quirk kept on purpose

With `exclusive_orders`, backtesting.py cancels orders with `for o in self.orders: o.cancel()`, removing items from the list it is walking, so it skips every second order. Its out-of-money handler closes trades the same way. `cancel_standalone_orders()` and `next_bar()` walk their lists with an index that moves on after each removal, reproducing the skipping, so results stay identical to the Python library even in these rare cases.

Python's `if price == stop_price: trade._sl_order._replace(stop_price=stop_price)` restores the stop on a filled stop-loss order so the trade list can report it in `SL`; `fill_closing_order()` does the same.
