# A trading strategy to run through a backtest

The R counterpart of `backtesting.Strategy` from the Python
`backtesting` package (version 0.6.5). Write a strategy as an R6 class
that inherits `BacktestStrategy` and defines two methods:

- `initialize_strategy()`, Python's `init()`, runs once before the first
  candle. It declares indicators with `self$indicator(name, values)`,
  where `values` is a numeric vector with one value per candle, such as
  `talib::SMA(self$data$Close, timePeriod = 10)`.

- `next_candle()`, Python's `next()`, runs once for each candle. It
  reads `self$data` and `self$indicators`, which reveal only the candles
  up to the current one, and places orders with `self$buy()` and
  `self$sell()` or closes them with `self$position$close()`.

The methods were renamed because
[`next`](https://rdrr.io/r/base/Control.html) is a reserved word in R
and `initialize` is the R6 constructor.

Python strategies store an indicator in an attribute, as in
`self.fast_average = self.I(...)`. An R6 object cannot gain fields after
it is created, so the R strategy names each indicator instead and reads
it back as `self$indicators$fast_average`.

The backtest starts on the first candle at which every indicator has a
value, plus one, exactly as backtesting.py does, so a 30-candle moving
average delays the first `next_candle()` call to candle 31.

Python's `backtesting.lib.crossover(series1, series2)` is the method
`self$crossover(series1, series2)`.

## Active bindings

- `data`:

  A `data.frame` of the candles up to and including the current one,
  with `datetime`, `Open`, `High`, `Low`, `Close` and `Volume` columns;
  inside `initialize_strategy()` it holds every candle.

- `indicators`:

  A named list of the declared indicators, each a numeric vector cut off
  at the current candle.

- `equity`:

  The numeric account equity: cash plus the profit or loss of the open
  trades.

- `position`:

  The `BacktestPosition` summing the open trades.

- `orders`:

  A list of the waiting `BacktestOrder` objects.

- `trades`:

  A list of the open `BacktestTrade` objects.

- `closed_trades`:

  A list of the closed `BacktestTrade` objects.

## Methods

### Public methods

- [`BacktestStrategy$new()`](#method-BacktestStrategy-initialize)

- [`BacktestStrategy$initialize_strategy()`](#method-BacktestStrategy-initialize_strategy)

- [`BacktestStrategy$next_candle()`](#method-BacktestStrategy-next_candle)

- [`BacktestStrategy$indicator()`](#method-BacktestStrategy-indicator)

- [`BacktestStrategy$warmup_candles()`](#method-BacktestStrategy-warmup_candles)

- [`BacktestStrategy$all_indicators()`](#method-BacktestStrategy-all_indicators)

- [`BacktestStrategy$buy()`](#method-BacktestStrategy-buy)

- [`BacktestStrategy$sell()`](#method-BacktestStrategy-sell)

- [`BacktestStrategy$crossover()`](#method-BacktestStrategy-crossover)

- [`BacktestStrategy$format()`](#method-BacktestStrategy-format)

- [`BacktestStrategy$print()`](#method-BacktestStrategy-print)

- [`BacktestStrategy$clone()`](#method-BacktestStrategy-clone)

------------------------------------------------------------------------

### `BacktestStrategy$new()`

Creates the strategy for one run; `Backtest$run()` does this, so a
strategy class rarely needs its own `initialize()`.

#### Usage

    BacktestStrategy$new(broker)

#### Arguments

- `broker`:

  The `BacktestBroker` of the run.

#### Returns

A new strategy object.

------------------------------------------------------------------------

### `BacktestStrategy$initialize_strategy()`

Declares indicators and does any other work needed before the first
candle. A strategy class must define it, even as an empty method.

#### Usage

    BacktestStrategy$initialize_strategy()

#### Details

Errors: always signals a plain error, because only a subclass knows its
indicators.

#### Returns

Ignored.

------------------------------------------------------------------------

### `BacktestStrategy$next_candle()`

Makes the trading decision for the current candle. A strategy class must
define it.

#### Usage

    BacktestStrategy$next_candle()

#### Details

Errors: always signals a plain error, because only a subclass knows its
rules.

#### Returns

Ignored.

------------------------------------------------------------------------

### `BacktestStrategy$indicator()`

Declares an indicator, the R counterpart of Python's `Strategy.I()`.
Call it from `initialize_strategy()`.

#### Usage

    BacktestStrategy$indicator(name, values)

#### Arguments

- `name`:

  A character name to read the indicator back by, as
  `self$indicators[[name]]`.

- `values`:

  A numeric vector with one value per candle, `NA` where the indicator
  is still warming up.

#### Details

Errors: signals `ValueError` when `values` is not as long as the
candles.

#### Returns

The numeric `values`, invisibly.

------------------------------------------------------------------------

### `BacktestStrategy$warmup_candles()`

Gives the number of candles before every indicator has a value, which
delays the start of the backtest.

#### Usage

    BacktestStrategy$warmup_candles()

#### Returns

The integer number of leading candles in which some indicator is still
`NA`, or 0 when there are no indicators.

------------------------------------------------------------------------

### `BacktestStrategy$all_indicators()`

Gives every indicator with all its values, not only those up to the
current candle, for the statistics and the trade list.

#### Usage

    BacktestStrategy$all_indicators()

#### Returns

A named list of numeric vectors.

------------------------------------------------------------------------

### `BacktestStrategy$buy()`

Places a buy order. Without `limit` or `stop` it is a market order,
filled at the next candle's open, or at the current close when the
backtest runs with `trade_on_close = TRUE`.

#### Usage

    BacktestStrategy$buy(
      size = BACKTESTING_FULL_EQUITY,
      limit = NULL,
      stop = NULL,
      sl = NULL,
      tp = NULL,
      tag = NULL
    )

#### Arguments

- `size`:

  The numeric size: a fraction between 0 and 1 of the available margin,
  or a whole number of units of at least 1. The default is all the
  available margin.

- `limit`:

  The numeric limit price, or `NULL`.

- `stop`:

  The numeric stop price, or `NULL`.

- `sl`:

  The numeric stop-loss price for the trade, or `NULL`.

- `tp`:

  The numeric take-profit price for the trade, or `NULL`.

- `tag`:

  Any value to recognise the order and its trade by, or `NULL`.

#### Details

Errors: signals `ValueError` when `size` is neither a fraction between 0
and 1 nor a whole number of at least 1, or the stop-loss, price and
take-profit are not in rising order.

#### Returns

The new `BacktestOrder`.

------------------------------------------------------------------------

### `BacktestStrategy$sell()`

Places a sell order, which opens a short trade or, without hedging,
closes long trades first. Use `self$position$close()` to close a long
position without going short.

#### Usage

    BacktestStrategy$sell(
      size = BACKTESTING_FULL_EQUITY,
      limit = NULL,
      stop = NULL,
      sl = NULL,
      tp = NULL,
      tag = NULL
    )

#### Arguments

- `size`:

  The numeric size: a fraction between 0 and 1 of the available margin,
  or a whole number of units of at least 1. The default is all the
  available margin.

- `limit`:

  The numeric limit price, or `NULL`.

- `stop`:

  The numeric stop price, or `NULL`.

- `sl`:

  The numeric stop-loss price for the trade, or `NULL`.

- `tp`:

  The numeric take-profit price for the trade, or `NULL`.

- `tag`:

  Any value to recognise the order and its trade by, or `NULL`.

#### Details

Errors: signals `ValueError` when `size` is neither a fraction between 0
and 1 nor a whole number of at least 1, or the take-profit, price and
stop-loss are not in rising order.

#### Returns

The new `BacktestOrder`.

------------------------------------------------------------------------

### `BacktestStrategy$crossover()`

Tells whether the first series has just crossed above the second, the R
counterpart of `backtesting.lib.crossover`.

#### Usage

    BacktestStrategy$crossover(series1, series2)

#### Arguments

- `series1`:

  A numeric vector, or one number standing for a flat line.

- `series2`:

  A numeric vector, or one number standing for a flat line.

#### Returns

A logical that is `TRUE` when `series1` was below `series2` on the
previous value and is above it on the latest, and `FALSE` otherwise,
including when either series has fewer than two values or a missing
value.

------------------------------------------------------------------------

### `BacktestStrategy$format()`

Describes the strategy by its class name, as Python's `str` does.

#### Usage

    BacktestStrategy$format(...)

#### Arguments

- `...`:

  Ignored; present for compatibility with
  [`format()`](https://rdrr.io/r/base/format.html).

#### Returns

A character value such as `"MovingAverageCross"`.

------------------------------------------------------------------------

### `BacktestStrategy$print()`

Prints the strategy's class name.

#### Usage

    BacktestStrategy$print(...)

#### Arguments

- `...`:

  Ignored; present for compatibility with
  [`print()`](https://rdrr.io/r/base/print.html).

#### Returns

The strategy, invisibly.

------------------------------------------------------------------------

### `BacktestStrategy$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BacktestStrategy$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
MovingAverageCross <- R6::R6Class(
  "MovingAverageCross",
  inherit = BacktestStrategy,
  public = list(
    initialize_strategy = function() {
      self$indicator(
        "fast_average",
        talib::SMA(self$data$Close, timePeriod = 10)
      )
      self$indicator(
        "slow_average",
        talib::SMA(self$data$Close, timePeriod = 30)
      )
    },
    next_candle = function() {
      fast <- self$indicators$fast_average
      slow <- self$indicators$slow_average
      if (self$crossover(fast, slow)) {
        self$position$close()
        self$buy()
      } else if (self$crossover(slow, fast)) {
        self$position$close()
        self$sell()
      }
    }
  )
)
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
statistics <- infosys$run_backtest(MovingAverageCross, cash = 100000, days = 730)
} # }
```
