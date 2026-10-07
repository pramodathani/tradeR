# R/assets_analysis_backtesting_position.R

`BacktestPosition` is the R counterpart of `backtesting.Position` from backtesting.py 0.6.5. Its members sum the broker's open trades on every read, exactly as the Python properties do. `pl_pct` is in percent, as in Python, unlike a trade's `pl_pct`, which is a fraction.

Python's `__bool__`, which makes `if not self.position:` work, has no R counterpart; strategies test `self$position$size == 0` instead.
