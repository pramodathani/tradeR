# Moving averages, Bollinger bands and other indicators an instrument draws over its candles

Overlap studies are indicators drawn on the price scale. Each method
fetches the instrument's candles through `prices()`, adds one or more
TA-Lib columns and returns the candles. This class is a link in the
analysis chain: it inherits `PriceStatistics`, and `MomentumIndicators`
inherits it, so `Instrument`, which supplies the real `prices()`, has
every method.

## Super classes

[`PriceAnalysis`](https://pramodathani.github.io/tradeR/reference/PriceAnalysis.md)
-\>
[`PriceStatistics`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.md)
-\> `OverlapStudies`

## Methods

### Public methods

- [`OverlapStudies$simple_moving_average()`](#method-OverlapStudies-simple_moving_average)

- [`OverlapStudies$exponential_moving_average()`](#method-OverlapStudies-exponential_moving_average)

- [`OverlapStudies$bollinger_bands()`](#method-OverlapStudies-bollinger_bands)

- [`OverlapStudies$weighted_moving_average()`](#method-OverlapStudies-weighted_moving_average)

- [`OverlapStudies$double_exponential_moving_average()`](#method-OverlapStudies-double_exponential_moving_average)

- [`OverlapStudies$triple_exponential_moving_average()`](#method-OverlapStudies-triple_exponential_moving_average)

- [`OverlapStudies$kaufman_adaptive_moving_average()`](#method-OverlapStudies-kaufman_adaptive_moving_average)

- [`OverlapStudies$mesa_adaptive_moving_average()`](#method-OverlapStudies-mesa_adaptive_moving_average)

- [`OverlapStudies$triangular_moving_average()`](#method-OverlapStudies-triangular_moving_average)

- [`OverlapStudies$parabolic_sar()`](#method-OverlapStudies-parabolic_sar)

- [`OverlapStudies$mid_point()`](#method-OverlapStudies-mid_point)

- [`OverlapStudies$middle_price()`](#method-OverlapStudies-middle_price)

- [`OverlapStudies$clone()`](#method-OverlapStudies-clone)

Inherited methods

- [`PriceAnalysis$prices()`](https://pramodathani.github.io/tradeR/reference/PriceAnalysis.html#method-prices)
- [`PriceStatistics$price_high()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_high)
- [`PriceStatistics$price_histogram()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_histogram)
- [`PriceStatistics$price_kurtosis()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_kurtosis)
- [`PriceStatistics$price_low()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_low)
- [`PriceStatistics$price_mean()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_mean)
- [`PriceStatistics$price_mean_absolute_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_mean_absolute_deviation)
- [`PriceStatistics$price_median()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_median)
- [`PriceStatistics$price_quantile()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_quantile)
- [`PriceStatistics$price_skewness()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_skewness)
- [`PriceStatistics$price_standard_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_standard_deviation)
- [`PriceStatistics$price_summary()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_summary)
- [`PriceStatistics$price_variance()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_variance)
- [`PriceStatistics$returns()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns)
- [`PriceStatistics$returns_high()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_high)
- [`PriceStatistics$returns_histogram()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_histogram)
- [`PriceStatistics$returns_kurtosis()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_kurtosis)
- [`PriceStatistics$returns_low()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_low)
- [`PriceStatistics$returns_mean()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_mean)
- [`PriceStatistics$returns_mean_absolute_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_mean_absolute_deviation)
- [`PriceStatistics$returns_median()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_median)
- [`PriceStatistics$returns_quantile()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_quantile)
- [`PriceStatistics$returns_skewness()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_skewness)
- [`PriceStatistics$returns_standard_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_standard_deviation)
- [`PriceStatistics$returns_summary()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_summary)
- [`PriceStatistics$returns_variance()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_variance)
- [`PriceStatistics$volume_high()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_high)
- [`PriceStatistics$volume_histogram()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_histogram)
- [`PriceStatistics$volume_kurtosis()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_kurtosis)
- [`PriceStatistics$volume_low()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_low)
- [`PriceStatistics$volume_mean()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_mean)
- [`PriceStatistics$volume_mean_absolute_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_mean_absolute_deviation)
- [`PriceStatistics$volume_median()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_median)
- [`PriceStatistics$volume_quantile()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_quantile)
- [`PriceStatistics$volume_skewness()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_skewness)
- [`PriceStatistics$volume_standard_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_standard_deviation)
- [`PriceStatistics$volume_summary()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_summary)
- [`PriceStatistics$volume_total()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_total)
- [`PriceStatistics$volume_variance()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_variance)
- [`PriceStatistics$volumes()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volumes)

------------------------------------------------------------------------

### `OverlapStudies$simple_moving_average()`

Adds the simple moving average of one candle column.

#### Usage

    OverlapStudies$simple_moving_average(
      window = 10,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with an `sma_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$simple_moving_average(window = 20, days = 90)
    print(tail(candles[, c("datetime", "close", "sma_20")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    fast <- nifty$simple_moving_average(window = 50, days = 400)
    slow <- nifty$simple_moving_average(window = 200, days = 400)
    fast_average <- fast$sma_50[nrow(fast)]
    slow_average <- slow$sma_200[nrow(slow)]
    if (fast_average > slow_average) {
      cat(sprintf("Golden cross: %.0f > %.0f\n", fast_average, slow_average))
    } else {
      cat(sprintf("Death cross: %.0f < %.0f\n", fast_average, slow_average))
    }

    information_technology <- Watchlist$new(
      name = "information technology",
      instruments = list(
        Equity$new(exchange = "nse", symbol = "INFY"),
        Equity$new(exchange = "nse", symbol = "TCS"),
        Equity$new(exchange = "nse", symbol = "WIPRO")
      )
    )
    candles <- information_technology$simple_moving_average(days = 60)
    print(tail(candles[, c("datetime", "close", "sma_10")]))

------------------------------------------------------------------------

### `OverlapStudies$exponential_moving_average()`

Adds the exponential moving average of one candle column.

#### Usage

    OverlapStudies$exponential_moving_average(
      window = 10,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with an `ema_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$exponential_moving_average(window = 20, days = 120)
    print(tail(candles[, c("datetime", "close", "ema_20")]))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      fast <- share$exponential_moving_average(window = 12, days = 180)
      slow <- share$exponential_moving_average(window = 26, days = 180)
      gap <- fast$ema_12[nrow(fast)] - slow$ema_26[nrow(slow)]
      cat(sprintf("%s: %.2f\n", symbol, gap))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    candles <- nifty$exponential_moving_average(window = 50, days = 250)
    last_row <- candles[nrow(candles), ]
    distance <- (last_row$close / last_row$ema_50 - 1) * 100
    cat(sprintf("%.2f%% from the average\n", distance))

------------------------------------------------------------------------

### `OverlapStudies$bollinger_bands()`

Adds the upper, middle and lower Bollinger bands of one candle column.

#### Usage

    OverlapStudies$bollinger_bands(
      window = 10,
      standard_deviations_up = 2,
      standard_deviations_down = 2,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `standard_deviations_up`:

  The numeric number of standard deviations from the middle band to the
  upper band.

- `standard_deviations_down`:

  The numeric number of standard deviations from the middle band to the
  lower band.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with `bb_upper_<window>`,
`bb_middle_<window>` and `bb_lower_<window>` columns added, or `NULL`
when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$bollinger_bands(window = 20, days = 120)
    columns <- c(
      "datetime",
      "close",
      "bb_lower_20",
      "bb_middle_20",
      "bb_upper_20"
    )
    print(tail(candles[, columns]))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$bollinger_bands(window = 20, days = 120)
      last_row <- candles[nrow(candles), ]
      width <- last_row$bb_upper_20 - last_row$bb_lower_20
      position <- (last_row$close - last_row$bb_lower_20) / width
      cat(sprintf("%s: %.2f\n", symbol, position))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    candles <- nifty$bollinger_bands(
      window = 20,
      standard_deviations_up = 3,
      standard_deviations_down = 3,
      days = 120
    )
    last_row <- candles[nrow(candles), ]
    width <- last_row$bb_upper_20 - last_row$bb_lower_20
    cat(sprintf("%.2f%%\n", width / last_row$bb_middle_20 * 100))

------------------------------------------------------------------------

### `OverlapStudies$weighted_moving_average()`

Adds the weighted moving average of one candle column.

#### Usage

    OverlapStudies$weighted_moving_average(
      window = 10,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `wma_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$weighted_moving_average(window = 20, days = 90)
    print(tail(candles[, c("datetime", "close", "wma_20")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    weighted <- nifty$weighted_moving_average(window = 10, days = 60)
    simple <- nifty$simple_moving_average(window = 10, days = 60)
    cat(sprintf("Weighted %.2f\n", weighted$wma_10[nrow(weighted)]))
    cat(sprintf("Simple %.2f\n", simple$sma_10[nrow(simple)]))

------------------------------------------------------------------------

### `OverlapStudies$double_exponential_moving_average()`

Adds the double exponential moving average of one candle column.

#### Usage

    OverlapStudies$double_exponential_moving_average(
      window = 10,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `dema_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$double_exponential_moving_average(
      window = 20,
      days = 180
    )
    print(tail(candles[, c("datetime", "close", "dema_20")]))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$double_exponential_moving_average(days = 120)
      last_row <- candles[nrow(candles), ]
      if (last_row$close > last_row$dema_10) {
        cat(sprintf("%s: above\n", symbol))
      } else {
        cat(sprintf("%s: below\n", symbol))
      }
    }

------------------------------------------------------------------------

### `OverlapStudies$triple_exponential_moving_average()`

Adds Tillson's T3 triple exponential moving average of one candle
column.

#### Usage

    OverlapStudies$triple_exponential_moving_average(
      window = 10,
      volume_factor = 0.7,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `volume_factor`:

  The numeric volume factor that sets how strongly T3 smooths, between 0
  and 1.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `t3_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$triple_exponential_moving_average(
      window = 10,
      days = 180
    )
    print(tail(candles[, c("datetime", "close", "t3_10")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    smooth <- nifty$triple_exponential_moving_average(
      window = 10,
      volume_factor = 0.9,
      days = 250
    )
    responsive <- nifty$triple_exponential_moving_average(
      window = 10,
      volume_factor = 0.3,
      days = 250
    )
    cat(sprintf("Factor 0.9: %.2f\n", smooth$t3_10[nrow(smooth)]))
    cat(sprintf("Factor 0.3: %.2f\n", responsive$t3_10[nrow(responsive)]))

------------------------------------------------------------------------

### `OverlapStudies$kaufman_adaptive_moving_average()`

Adds the Kaufman adaptive moving average of one candle column.

#### Usage

    OverlapStudies$kaufman_adaptive_moving_average(
      window = 10,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `kama_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$kaufman_adaptive_moving_average(days = 120)
    print(tail(candles[, c("datetime", "close", "kama_10")]))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$kaufman_adaptive_moving_average(
        window = 20,
        days = 180
      )
      average <- candles$kama_20
      change <- average[length(average)] - average[length(average) - 5]
      if (change > 0) {
        cat(sprintf("%s: rising by %.2f\n", symbol, change))
      } else {
        cat(sprintf("%s: falling by %.2f\n", symbol, -change))
      }
    }

------------------------------------------------------------------------

### `OverlapStudies$mesa_adaptive_moving_average()`

Adds the MESA adaptive moving average and its following average of one
candle column.

#### Usage

    OverlapStudies$mesa_adaptive_moving_average(
      fast_limit = 0.5,
      slow_limit = 0.05,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `fast_limit`:

  The numeric upper limit of the adaptive smoothing factor.

- `slow_limit`:

  The numeric lower limit of the adaptive smoothing factor.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with `mama` and `fama` columns added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$mesa_adaptive_moving_average(days = 365)
    print(tail(candles[, c("datetime", "close", "mama", "fama")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    candles <- nifty$mesa_adaptive_moving_average(days = 365)
    last_cross <- NULL
    mama <- candles$mama
    fama <- candles$fama
    for (position in seq(2, nrow(candles))) {
      before <- isTRUE(mama[position - 1] > fama[position - 1])
      after <- isTRUE(mama[position] > fama[position])
      if (before != after) {
        last_cross <- candles$datetime[position]
      }
    }
    print(last_cross)

------------------------------------------------------------------------

### `OverlapStudies$triangular_moving_average()`

Adds the triangular moving average of one candle column.

#### Usage

    OverlapStudies$triangular_moving_average(
      window = 10,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `trima_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$triangular_moving_average(window = 20, days = 120)
    print(tail(candles[, c("datetime", "close", "trima_20")]))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$triangular_moving_average(days = 90)
      last_row <- candles[nrow(candles), ]
      distance <- (last_row$close / last_row$trima_10 - 1) * 100
      cat(sprintf("%s: %.2f%%\n", symbol, distance))
    }

------------------------------------------------------------------------

### `OverlapStudies$parabolic_sar()`

Adds the parabolic stop and reverse from the high and low columns.

#### Usage

    OverlapStudies$parabolic_sar(
      acceleration = 0.02,
      maximum = 0.2,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `acceleration`:

  The numeric acceleration factor added at each new extreme.

- `maximum`:

  The numeric largest acceleration factor allowed.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `psar` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$parabolic_sar(days = 120)
    print(tail(candles[, c("datetime", "close", "psar")]))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$parabolic_sar(days = 120)
      last_row <- candles[nrow(candles), ]
      if (last_row$close > last_row$psar) {
        cat(sprintf("%s: uptrend, stop %.2f\n", symbol, last_row$psar))
      } else {
        cat(sprintf("%s: downtrend, stop %.2f\n", symbol, last_row$psar))
      }
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    candles <- nifty$parabolic_sar(
      acceleration = 0.01,
      maximum = 0.1,
      days = 180
    )
    print(tail(candles[, c("datetime", "close", "psar")]))

------------------------------------------------------------------------

### `OverlapStudies$mid_point()`

Adds the midpoint of the highest and lowest value of one candle column
over each window.

#### Usage

    OverlapStudies$mid_point(
      window = 10,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `column`:

  The character name of the candle column to use, such as `"close"`.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `mid_point_<window>` column added,
or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$mid_point(days = 60)
    print(tail(candles[, c("datetime", "close", "mid_point_10")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    candles <- nifty$mid_point(window = 20, days = 90)
    last_row <- candles[nrow(candles), ]
    if (last_row$close > last_row$mid_point_20) {
      print("In the upper half of the recent range")
    } else {
      print("In the lower half of the recent range")
    }

------------------------------------------------------------------------

### `OverlapStudies$middle_price()`

Adds the midpoint of the highest high and lowest low over each window.

#### Usage

    OverlapStudies$middle_price(
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in each calculation window.

- `interval`:

  The character candle interval, such as `"day"` or `"5minute"`.

- `from_date`:

  The first day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `to_date`:

  The last day of the range as a `Date` or a `"YYYY-MM-DD"` character
  value, or `NULL` when `days` is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  `from_date` and `to_date` are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `middle_price_<window>` column
added, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$middle_price(days = 60)
    print(tail(candles[, c("datetime", "close", "middle_price_10")]))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$middle_price(window = 20, days = 90)
      last_row <- candles[nrow(candles), ]
      middle <- last_row$middle_price_20
      cat(sprintf(
        "%s: close %s, middle %s\n",
        symbol,
        last_row$close,
        middle
      ))
    }

------------------------------------------------------------------------

### `OverlapStudies$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OverlapStudies$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$simple_moving_average(window = 20, days = 365)
} # }

## ------------------------------------------------
## Method `OverlapStudies$simple_moving_average()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$simple_moving_average(window = 20, days = 90)
print(tail(candles[, c("datetime", "close", "sma_20")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
fast <- nifty$simple_moving_average(window = 50, days = 400)
slow <- nifty$simple_moving_average(window = 200, days = 400)
fast_average <- fast$sma_50[nrow(fast)]
slow_average <- slow$sma_200[nrow(slow)]
if (fast_average > slow_average) {
  cat(sprintf("Golden cross: %.0f > %.0f\n", fast_average, slow_average))
} else {
  cat(sprintf("Death cross: %.0f < %.0f\n", fast_average, slow_average))
}

information_technology <- Watchlist$new(
  name = "information technology",
  instruments = list(
    Equity$new(exchange = "nse", symbol = "INFY"),
    Equity$new(exchange = "nse", symbol = "TCS"),
    Equity$new(exchange = "nse", symbol = "WIPRO")
  )
)
candles <- information_technology$simple_moving_average(days = 60)
print(tail(candles[, c("datetime", "close", "sma_10")]))
} # }

## ------------------------------------------------
## Method `OverlapStudies$exponential_moving_average()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$exponential_moving_average(window = 20, days = 120)
print(tail(candles[, c("datetime", "close", "ema_20")]))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  fast <- share$exponential_moving_average(window = 12, days = 180)
  slow <- share$exponential_moving_average(window = 26, days = 180)
  gap <- fast$ema_12[nrow(fast)] - slow$ema_26[nrow(slow)]
  cat(sprintf("%s: %.2f\n", symbol, gap))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
candles <- nifty$exponential_moving_average(window = 50, days = 250)
last_row <- candles[nrow(candles), ]
distance <- (last_row$close / last_row$ema_50 - 1) * 100
cat(sprintf("%.2f%% from the average\n", distance))
} # }

## ------------------------------------------------
## Method `OverlapStudies$bollinger_bands()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$bollinger_bands(window = 20, days = 120)
columns <- c(
  "datetime",
  "close",
  "bb_lower_20",
  "bb_middle_20",
  "bb_upper_20"
)
print(tail(candles[, columns]))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$bollinger_bands(window = 20, days = 120)
  last_row <- candles[nrow(candles), ]
  width <- last_row$bb_upper_20 - last_row$bb_lower_20
  position <- (last_row$close - last_row$bb_lower_20) / width
  cat(sprintf("%s: %.2f\n", symbol, position))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
candles <- nifty$bollinger_bands(
  window = 20,
  standard_deviations_up = 3,
  standard_deviations_down = 3,
  days = 120
)
last_row <- candles[nrow(candles), ]
width <- last_row$bb_upper_20 - last_row$bb_lower_20
cat(sprintf("%.2f%%\n", width / last_row$bb_middle_20 * 100))
} # }

## ------------------------------------------------
## Method `OverlapStudies$weighted_moving_average()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$weighted_moving_average(window = 20, days = 90)
print(tail(candles[, c("datetime", "close", "wma_20")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
weighted <- nifty$weighted_moving_average(window = 10, days = 60)
simple <- nifty$simple_moving_average(window = 10, days = 60)
cat(sprintf("Weighted %.2f\n", weighted$wma_10[nrow(weighted)]))
cat(sprintf("Simple %.2f\n", simple$sma_10[nrow(simple)]))
} # }

## ------------------------------------------------
## Method `OverlapStudies$double_exponential_moving_average()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$double_exponential_moving_average(
  window = 20,
  days = 180
)
print(tail(candles[, c("datetime", "close", "dema_20")]))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$double_exponential_moving_average(days = 120)
  last_row <- candles[nrow(candles), ]
  if (last_row$close > last_row$dema_10) {
    cat(sprintf("%s: above\n", symbol))
  } else {
    cat(sprintf("%s: below\n", symbol))
  }
}
} # }

## ------------------------------------------------
## Method `OverlapStudies$triple_exponential_moving_average()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$triple_exponential_moving_average(
  window = 10,
  days = 180
)
print(tail(candles[, c("datetime", "close", "t3_10")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
smooth <- nifty$triple_exponential_moving_average(
  window = 10,
  volume_factor = 0.9,
  days = 250
)
responsive <- nifty$triple_exponential_moving_average(
  window = 10,
  volume_factor = 0.3,
  days = 250
)
cat(sprintf("Factor 0.9: %.2f\n", smooth$t3_10[nrow(smooth)]))
cat(sprintf("Factor 0.3: %.2f\n", responsive$t3_10[nrow(responsive)]))
} # }

## ------------------------------------------------
## Method `OverlapStudies$kaufman_adaptive_moving_average()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$kaufman_adaptive_moving_average(days = 120)
print(tail(candles[, c("datetime", "close", "kama_10")]))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$kaufman_adaptive_moving_average(
    window = 20,
    days = 180
  )
  average <- candles$kama_20
  change <- average[length(average)] - average[length(average) - 5]
  if (change > 0) {
    cat(sprintf("%s: rising by %.2f\n", symbol, change))
  } else {
    cat(sprintf("%s: falling by %.2f\n", symbol, -change))
  }
}
} # }

## ------------------------------------------------
## Method `OverlapStudies$mesa_adaptive_moving_average()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$mesa_adaptive_moving_average(days = 365)
print(tail(candles[, c("datetime", "close", "mama", "fama")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
candles <- nifty$mesa_adaptive_moving_average(days = 365)
last_cross <- NULL
mama <- candles$mama
fama <- candles$fama
for (position in seq(2, nrow(candles))) {
  before <- isTRUE(mama[position - 1] > fama[position - 1])
  after <- isTRUE(mama[position] > fama[position])
  if (before != after) {
    last_cross <- candles$datetime[position]
  }
}
print(last_cross)
} # }

## ------------------------------------------------
## Method `OverlapStudies$triangular_moving_average()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$triangular_moving_average(window = 20, days = 120)
print(tail(candles[, c("datetime", "close", "trima_20")]))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$triangular_moving_average(days = 90)
  last_row <- candles[nrow(candles), ]
  distance <- (last_row$close / last_row$trima_10 - 1) * 100
  cat(sprintf("%s: %.2f%%\n", symbol, distance))
}
} # }

## ------------------------------------------------
## Method `OverlapStudies$parabolic_sar()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$parabolic_sar(days = 120)
print(tail(candles[, c("datetime", "close", "psar")]))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$parabolic_sar(days = 120)
  last_row <- candles[nrow(candles), ]
  if (last_row$close > last_row$psar) {
    cat(sprintf("%s: uptrend, stop %.2f\n", symbol, last_row$psar))
  } else {
    cat(sprintf("%s: downtrend, stop %.2f\n", symbol, last_row$psar))
  }
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
candles <- nifty$parabolic_sar(
  acceleration = 0.01,
  maximum = 0.1,
  days = 180
)
print(tail(candles[, c("datetime", "close", "psar")]))
} # }

## ------------------------------------------------
## Method `OverlapStudies$mid_point()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$mid_point(days = 60)
print(tail(candles[, c("datetime", "close", "mid_point_10")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
candles <- nifty$mid_point(window = 20, days = 90)
last_row <- candles[nrow(candles), ]
if (last_row$close > last_row$mid_point_20) {
  print("In the upper half of the recent range")
} else {
  print("In the lower half of the recent range")
}
} # }

## ------------------------------------------------
## Method `OverlapStudies$middle_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$middle_price(days = 60)
print(tail(candles[, c("datetime", "close", "middle_price_10")]))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$middle_price(window = 20, days = 90)
  last_row <- candles[nrow(candles), ]
  middle <- last_row$middle_price_20
  cat(sprintf(
    "%s: close %s, middle %s\n",
    symbol,
    last_row$close,
    middle
  ))
}
} # }
```
