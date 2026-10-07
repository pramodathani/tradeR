# A source of candles that analysis methods can be written against

The root of the chain of analysis classes. Each analysis class inherits
the one before it, ending with `PerformanceMeasures`, which `Instrument`
and `AssetBasket` inherit, and every analysis method calls `prices()` to
fetch the candles it works on. This class only declares `prices()`; the
instrument or basket that inherits the chain supplies the real one.

The chain, from this root to the last link, is `PriceAnalysis`,
`PriceStatistics`, `OverlapStudies`, `MomentumIndicators`,
`VolumeIndicators`, `CycleIndicators`, `PriceTransforms`,
`VolatilityIndicators`, `StatisticFunctions`, `MathTransforms`,
`MathOperators`, `CandlestickPatterns`, `Signals`, `StrategyBacktests`
and `PerformanceMeasures`.

## Methods

### Public methods

- [`PriceAnalysis$prices()`](#method-PriceAnalysis-prices)

- [`PriceAnalysis$clone()`](#method-PriceAnalysis-clone)

------------------------------------------------------------------------

### `PriceAnalysis$prices()`

Fetches candles for a range, which a subclass must provide.

#### Usage

    PriceAnalysis$prices(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `interval`:

  A character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  An integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: always signals a plain error, because only a subclass knows
where candles come from.

#### Returns

A `data.frame` of candles with `exchange`, `segment`, `interval`,
`datetime`, `open`, `high`, `low`, `close`, `volume` and `oi` columns,
or `NULL` when there are no candles.

------------------------------------------------------------------------

### `PriceAnalysis$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PriceAnalysis$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$prices(days = 30)
tail(candles[, c("datetime", "open", "high", "low", "close")])

tryCatch(
  PriceAnalysis$new()$prices(days = 30),
  error = function(error) conditionMessage(error)
)
} # }
```
