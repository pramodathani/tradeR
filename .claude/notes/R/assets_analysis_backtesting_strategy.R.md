# R/assets_analysis_backtesting_strategy.R

`BacktestStrategy` is the R counterpart of `backtesting.Strategy` from backtesting.py 0.6.5, and also holds `crossover()`, the counterpart of `backtesting.lib.crossover`.

## Renamed hooks

| Python | R | Why |
|---|---|---|
| `init()` | `initialize_strategy()` | `initialize()` is the R6 constructor |
| `next()` | `next_candle()` | `next` is a reserved word in R |
| `self.I(func, *args)` assigned to an attribute | `self$indicator(name, values)`, read as `self$indicators$name` | An R6 object is locked and cannot gain fields after creation, so indicators are stored by name; the caller computes `values` itself, such as `talib::SMA(self$data$Close, timePeriod = 10)` |
| `self.data.Close[-1]` | `tail(self$data$Close, 1)` | R has no negative indexing from the end |
| `if not self.position:` | `if (self$position$size == 0)` | An R object has no truth value |
| `backtesting.lib.crossover(a, b)` | `self$crossover(a, b)` | Behaviour lives on the class that uses it |

The base hooks signal a plain error, the R stand-in for Python's abstract methods, as `PriceAnalysis$prices()` does.

## Revealing candles gradually

backtesting.py slices its arrays to the current candle before each `next()` call. Here `data` and `indicators` are active bindings that cut the stored vectors at the broker's `current_bar` when read, which gives the same view without copying anything on candles where the strategy does not look.

## Details kept from backtesting.py

- The default order size is `1 - .Machine$double.eps`, Python's `_FULL_EQUITY`, kept in `BACKTESTING_FULL_EQUITY`.
- `buy()` and `sell()` accept a fraction strictly between 0 and 1 or a whole number of at least 1, and signal `ValueError` otherwise (Python uses `assert`).
- The warm-up is the largest index of the first non-missing value over the indicators, with an all-missing indicator counting as 0, as numpy's `argmin` does.
- `crossover()` treats a single number as a flat line and returns `FALSE` when a series has fewer than two values. A comparison with a missing value is `FALSE`, as `nan < x` is in Python.
- Indicators may only be numeric vectors; backtesting.py's two-dimensional indicators and its plotting options (`overlay`, `color`, `scatter`) are not ported.
