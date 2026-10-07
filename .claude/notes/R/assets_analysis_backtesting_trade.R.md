# R/assets_analysis_backtesting_trade.R

`BacktestTrade` is the R counterpart of `backtesting.Trade` from backtesting.py 0.6.5.

- `size`, `entry_price`, `exit_price`, `entry_bar`, `exit_bar`, `sl_order`, `tp_order`, `tag` and `commissions` are public fields for the reason given in `assets_analysis_backtesting_order.R.md`: the broker changes them, and R6 private members cannot be reached from another object.
- `sl` and `tp` are active bindings that can be assigned, because Python gives them setters. Assigning a price cancels any existing contingent order and places a new one; assigning `NULL` only cancels.
- `pl`, `pl_pct` and `value` value an open trade at the latest close, and commissions count only once the trade has closed, as in Python.
- `close()` rounds the portion with `round()`, which rounds halves to even like Python's `round()`.
- When the broker splits off part of a trade it uses R6 `clone()`, the counterpart of Python's `copy.copy`; the clone shares the broker.
- Candle numbers count from 1, so `entry_bar` is one more than in Python.
