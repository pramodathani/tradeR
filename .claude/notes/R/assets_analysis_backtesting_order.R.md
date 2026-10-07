# R/assets_analysis_backtesting_order.R

`BacktestOrder` is the R counterpart of `backtesting.Order` from backtesting.py 0.6.5.

Python keeps the order's values in name-mangled attributes behind read-only properties and changes them through `_replace()`. The broker in R must change `size` and `stop` on another object, and R6 private members are visible only to their own object, so `size`, `limit`, `stop`, `sl`, `tp`, `parent_trade` and `tag` are public fields. The Google style guide the user follows also prefers a public attribute over a property that only returns it. `is_long`, `is_short` and `is_contingent` are computed, so they stay read-only active bindings.

Python's `assert size != 0` became a `ValueError`. `format()` gives the same one-line text as Python's `repr`, with R's spelling of numbers and logical values.
