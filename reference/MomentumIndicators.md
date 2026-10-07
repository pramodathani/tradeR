# Oscillators and directional indicators an instrument calculates from its candles

Momentum indicators measure how fast prices move and in which direction.
Each method fetches the instrument's candles through `prices()`, adds
one or more TA-Lib columns and returns the candles. This class is a link
in the analysis chain: it inherits `OverlapStudies`, and
`VolumeIndicators` inherits it, so `Instrument`, which supplies the real
`prices()`, has every method.

Arguments named `..._moving_average_type` take TA-Lib's moving average
codes: 0 simple, 1 exponential, 2 weighted, 3 double exponential, 4
triple exponential, 5 triangular, 6 Kaufman adaptive, 7 MESA adaptive
and 8 Tillson T3.

## Super classes

[`PriceAnalysis`](https://pramodathani.github.io/tradeR/reference/PriceAnalysis.md)
-\>
[`PriceStatistics`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.md)
-\>
[`OverlapStudies`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.md)
-\> `MomentumIndicators`

## Methods

### Public methods

- [`MomentumIndicators$moving_average_convergence_divergence()`](#method-MomentumIndicators-moving_average_convergence_divergence)

- [`MomentumIndicators$average_directional_movement_index()`](#method-MomentumIndicators-average_directional_movement_index)

- [`MomentumIndicators$momentum()`](#method-MomentumIndicators-momentum)

- [`MomentumIndicators$commodity_channel_index()`](#method-MomentumIndicators-commodity_channel_index)

- [`MomentumIndicators$average_directional_movement_index_rating()`](#method-MomentumIndicators-average_directional_movement_index_rating)

- [`MomentumIndicators$absolute_price_oscillator()`](#method-MomentumIndicators-absolute_price_oscillator)

- [`MomentumIndicators$aroon()`](#method-MomentumIndicators-aroon)

- [`MomentumIndicators$aroon_oscillator()`](#method-MomentumIndicators-aroon_oscillator)

- [`MomentumIndicators$balance_of_power()`](#method-MomentumIndicators-balance_of_power)

- [`MomentumIndicators$chande_momentum_oscillator()`](#method-MomentumIndicators-chande_momentum_oscillator)

- [`MomentumIndicators$directional_movement_index()`](#method-MomentumIndicators-directional_movement_index)

- [`MomentumIndicators$moving_average_convergence_divergence_extended()`](#method-MomentumIndicators-moving_average_convergence_divergence_extended)

- [`MomentumIndicators$money_flow_index()`](#method-MomentumIndicators-money_flow_index)

- [`MomentumIndicators$minus_directional_indicator()`](#method-MomentumIndicators-minus_directional_indicator)

- [`MomentumIndicators$minus_directional_movement()`](#method-MomentumIndicators-minus_directional_movement)

- [`MomentumIndicators$plus_directional_indicator()`](#method-MomentumIndicators-plus_directional_indicator)

- [`MomentumIndicators$plus_directional_movement()`](#method-MomentumIndicators-plus_directional_movement)

- [`MomentumIndicators$percentage_price_oscillator()`](#method-MomentumIndicators-percentage_price_oscillator)

- [`MomentumIndicators$rate_of_change()`](#method-MomentumIndicators-rate_of_change)

- [`MomentumIndicators$rate_of_change_percent()`](#method-MomentumIndicators-rate_of_change_percent)

- [`MomentumIndicators$rate_of_change_ratio()`](#method-MomentumIndicators-rate_of_change_ratio)

- [`MomentumIndicators$relative_strength_index()`](#method-MomentumIndicators-relative_strength_index)

- [`MomentumIndicators$stochastic_oscillator()`](#method-MomentumIndicators-stochastic_oscillator)

- [`MomentumIndicators$stochastic_fast_oscillator()`](#method-MomentumIndicators-stochastic_fast_oscillator)

- [`MomentumIndicators$stochastic_relative_strength_index()`](#method-MomentumIndicators-stochastic_relative_strength_index)

- [`MomentumIndicators$trix()`](#method-MomentumIndicators-trix)

- [`MomentumIndicators$ultimate_oscillator()`](#method-MomentumIndicators-ultimate_oscillator)

- [`MomentumIndicators$williams_percent_r()`](#method-MomentumIndicators-williams_percent_r)

- [`MomentumIndicators$clone()`](#method-MomentumIndicators-clone)

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
- [`OverlapStudies$bollinger_bands()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-bollinger_bands)
- [`OverlapStudies$double_exponential_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-double_exponential_moving_average)
- [`OverlapStudies$exponential_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-exponential_moving_average)
- [`OverlapStudies$kaufman_adaptive_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-kaufman_adaptive_moving_average)
- [`OverlapStudies$mesa_adaptive_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-mesa_adaptive_moving_average)
- [`OverlapStudies$mid_point()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-mid_point)
- [`OverlapStudies$middle_price()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-middle_price)
- [`OverlapStudies$parabolic_sar()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-parabolic_sar)
- [`OverlapStudies$simple_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-simple_moving_average)
- [`OverlapStudies$triangular_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-triangular_moving_average)
- [`OverlapStudies$triple_exponential_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-triple_exponential_moving_average)
- [`OverlapStudies$weighted_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-weighted_moving_average)

------------------------------------------------------------------------

### `MomentumIndicators$moving_average_convergence_divergence()`

Adds the moving average convergence divergence line, its signal line and
their difference.

#### Usage

    MomentumIndicators$moving_average_convergence_divergence(
      fast_period = 12,
      slow_period = 26,
      signal_period = 9,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `fast_period`:

  The integer number of candles in the fast moving average.

- `slow_period`:

  The integer number of candles in the slow moving average.

- `signal_period`:

  The integer number of candles in the signal line's moving average.

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

A `data.frame` of the candles with `macd_<fast>_<slow>_<signal>`
columns, with `_signal` and `_hist` variants added, or `NULL` when UBI
has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$moving_average_convergence_divergence(days = 180)
    columns <- c(
      "datetime",
      "macd_12_26_9",
      "macd_12_26_9_signal",
      "macd_12_26_9_hist"
    )
    print(tail(frame[, columns]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$moving_average_convergence_divergence(
      fast_period = 8,
      slow_period = 21,
      signal_period = 5,
      days = 365
    )
    histogram <- frame$macd_8_21_5_hist
    previous <- c(NA, histogram[-length(histogram)])
    crossed_above <- which(histogram > 0 & previous <= 0)
    print(as.Date(frame$datetime[crossed_above], tz = "Asia/Kolkata"))

------------------------------------------------------------------------

### `MomentumIndicators$average_directional_movement_index()`

Adds the average directional movement index.

#### Usage

    MomentumIndicators$average_directional_movement_index(
      window = 14,
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

A `data.frame` of the candles with an `adx_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$average_directional_movement_index(days = 180)
    print(tail(frame[, c("datetime", "adx_14")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$average_directional_movement_index(
      window = 14,
      days = 180
    )
    latest <- frame$adx_14[nrow(frame)]
    if (latest > 25) {
      cat(sprintf("NIFTY is trending, ADX %.1f\n", latest))
    } else {
      cat(sprintf("NIFTY is moving sideways, ADX %.1f\n", latest))
    }

------------------------------------------------------------------------

### `MomentumIndicators$momentum()`

Adds the momentum of one candle column, its change over each window.

#### Usage

    MomentumIndicators$momentum(
      window = 14,
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

A `data.frame` of the candles with a `momentum_<window>` column added,
or `NULL` when UBI has no candles for the range.

#### Examples

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    frame <- reliance$momentum(window = 10, days = 120)
    print(tail(frame[, c("datetime", "momentum_10")]))

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      frame <- share$momentum(window = 20, column = "high", days = 120)
      print(paste(symbol, round(frame$momentum_20[nrow(frame)], 2)))
    }

------------------------------------------------------------------------

### `MomentumIndicators$commodity_channel_index()`

Adds the commodity channel index.

#### Usage

    MomentumIndicators$commodity_channel_index(
      window = 14,
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

A `data.frame` of the candles with a `cci_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$commodity_channel_index(window = 20, days = 180)
    print(tail(frame[, c("datetime", "cci_20")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$commodity_channel_index(window = 20, days = 365)
    above <- sum(frame$cci_20 > 100, na.rm = TRUE)
    below <- sum(frame$cci_20 < -100, na.rm = TRUE)
    cat(sprintf(
      "Above 100 on %d days, below -100 on %d days\n",
      above,
      below
    ))

------------------------------------------------------------------------

### `MomentumIndicators$average_directional_movement_index_rating()`

Adds the average directional movement index rating.

#### Usage

    MomentumIndicators$average_directional_movement_index_rating(
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

A `data.frame` of the candles with an `adxr_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    frame <- hdfc_bank$average_directional_movement_index_rating(
      window = 14,
      days = 180
    )
    print(tail(frame[, c("datetime", "adxr_14")]))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    rating_frame <- infosys$average_directional_movement_index_rating(
      window = 14,
      days = 180
    )
    index_frame <- infosys$average_directional_movement_index(
      window = 14,
      days = 180
    )
    print(paste("ADXR", round(rating_frame$adxr_14[nrow(rating_frame)], 2)))
    print(paste("ADX", round(index_frame$adx_14[nrow(index_frame)], 2)))

------------------------------------------------------------------------

### `MomentumIndicators$absolute_price_oscillator()`

Adds the absolute price oscillator, the difference between a fast and a
slow moving average.

#### Usage

    MomentumIndicators$absolute_price_oscillator(
      fast_period = 12,
      slow_period = 26,
      moving_average_type = 0,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `fast_period`:

  The integer number of candles in the fast moving average.

- `slow_period`:

  The integer number of candles in the slow moving average.

- `moving_average_type`:

  The integer TA-Lib moving average type, where 0 is a simple moving
  average.

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

A `data.frame` of the candles with an `apo_<fast>_<slow>` column added,
or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$absolute_price_oscillator(days = 180)
    print(tail(frame[, c("datetime", "apo_12_26")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$absolute_price_oscillator(
      fast_period = 5,
      slow_period = 20,
      moving_average_type = 1,
      days = 120
    )
    gap <- round(frame$apo_5_20[nrow(frame)], 2)
    if (gap > 0) {
      cat(sprintf(
        "The fast average is %s points above the slow one\n",
        gap
      ))
    } else {
      cat(sprintf(
        "The fast average is %s points below the slow one\n",
        -gap
      ))
    }

------------------------------------------------------------------------

### `MomentumIndicators$aroon()`

Adds the Aroon down and Aroon up lines.

#### Usage

    MomentumIndicators$aroon(
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

A `data.frame` of the candles with `aroon_down_<window>` and
`aroon_up_<window>` columns added, or `NULL` when UBI has no candles for
the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$aroon(window = 25, days = 180)
    columns <- c(
      "datetime",
      "aroon_down_25",
      "aroon_up_25"
    )
    print(tail(frame[, columns]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$aroon(window = 25, days = 180)
    aroon_up <- as.integer(frame$aroon_up_25[nrow(frame)])
    aroon_down <- as.integer(frame$aroon_down_25[nrow(frame)])
    if (aroon_up > aroon_down) {
      cat(sprintf("New highs lead: up %d, down %d\n", aroon_up, aroon_down))
    } else {
      cat(sprintf("New lows lead: up %d, down %d\n", aroon_up, aroon_down))
    }

------------------------------------------------------------------------

### `MomentumIndicators$aroon_oscillator()`

Adds the Aroon oscillator, Aroon up minus Aroon down.

#### Usage

    MomentumIndicators$aroon_oscillator(
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

A `data.frame` of the candles with an `aroon_osc_<window>` column added,
or `NULL` when UBI has no candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    frame <- tcs$aroon_oscillator(window = 14, days = 180)
    print(tail(frame[, c("datetime", "aroon_osc_14")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$aroon_oscillator(window = 14, days = 180)
    last_sixty <- tail(frame$aroon_osc_14, 60)
    positive_days <- sum(last_sixty > 0, na.rm = TRUE)
    cat(sprintf(
      "Positive on %d of %d days\n",
      positive_days,
      length(last_sixty)
    ))

------------------------------------------------------------------------

### `MomentumIndicators$balance_of_power()`

Adds the balance of power.

#### Usage

    MomentumIndicators$balance_of_power(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `bop` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$balance_of_power(days = 60)
    print(tail(frame[, c("datetime", "bop")]))

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    frame <- reliance$balance_of_power(days = 120)
    smoothed <- mean(tail(frame$bop, 10))
    if (smoothed > 0) {
      cat(sprintf("Buyers have been in control: %.3f\n", smoothed))
    } else {
      cat(sprintf("Sellers have been in control: %.3f\n", smoothed))
    }

------------------------------------------------------------------------

### `MomentumIndicators$chande_momentum_oscillator()`

Adds the Chande momentum oscillator of one candle column.

#### Usage

    MomentumIndicators$chande_momentum_oscillator(
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

A `data.frame` of the candles with a `cmo_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$chande_momentum_oscillator(window = 14, days = 120)
    print(tail(frame[, c("datetime", "cmo_14")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$chande_momentum_oscillator(window = 14, days = 120)
    latest <- frame$cmo_14[nrow(frame)]
    if (latest > 50) {
      label <- "overbought"
    } else if (latest < -50) {
      label <- "oversold"
    } else {
      label <- "neutral"
    }
    cat(sprintf("NIFTY CMO %.1f: %s\n", latest, label))

------------------------------------------------------------------------

### `MomentumIndicators$directional_movement_index()`

Adds the directional movement index.

#### Usage

    MomentumIndicators$directional_movement_index(
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

A `data.frame` of the candles with a `dx_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$directional_movement_index(window = 14, days = 120)
    print(tail(frame[, c("datetime", "dx_14")]))

    bank_nifty <- EquityIndex$new(
      exchange = "nse",
      symbol = "BANKNIFTY"
    )
    frame <- bank_nifty$directional_movement_index(
      window = 14,
      from_date = "2026-01-01",
      to_date = "2026-03-31"
    )
    cat(sprintf("Average DX: %.2f\n", mean(frame$dx_14, na.rm = TRUE)))

------------------------------------------------------------------------

### `MomentumIndicators$moving_average_convergence_divergence_extended()`

Adds the moving average convergence divergence with a chosen moving
average type for each of its three averages.

#### Usage

    MomentumIndicators$moving_average_convergence_divergence_extended(
      fast_period = 12,
      fast_moving_average_type = 0,
      slow_period = 26,
      slow_moving_average_type = 0,
      signal_period = 9,
      signal_moving_average_type = 0,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `fast_period`:

  The integer number of candles in the fast moving average.

- `fast_moving_average_type`:

  The integer TA-Lib moving average type of the fast average, where 0 is
  a simple moving average.

- `slow_period`:

  The integer number of candles in the slow moving average.

- `slow_moving_average_type`:

  The integer TA-Lib moving average type of the slow average, where 0 is
  a simple moving average.

- `signal_period`:

  The integer number of candles in the signal line's moving average.

- `signal_moving_average_type`:

  The integer TA-Lib moving average type of the signal line, where 0 is
  a simple moving average.

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

A `data.frame` of the candles with `macd_<fast>_<slow>_<signal>`,
`macd_signal_...` and `macd_hist_...` columns added, or `NULL` when UBI
has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$moving_average_convergence_divergence_extended(
      fast_moving_average_type = 1,
      slow_moving_average_type = 1,
      signal_moving_average_type = 1,
      days = 180
    )
    columns <- c(
      "datetime",
      "macd_12_26_9",
      "macd_signal_12_26_9",
      "macd_hist_12_26_9"
    )
    print(tail(frame[, columns]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$moving_average_convergence_divergence_extended(
      fast_period = 10,
      fast_moving_average_type = 2,
      slow_period = 30,
      slow_moving_average_type = 2,
      signal_period = 7,
      signal_moving_average_type = 0,
      days = 240
    )
    print(round(frame$macd_hist_10_30_7[nrow(frame)], 2))

------------------------------------------------------------------------

### `MomentumIndicators$money_flow_index()`

Adds the money flow index, a relative strength index weighted by volume.

#### Usage

    MomentumIndicators$money_flow_index(
      window = 14,
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

A `data.frame` of the candles with an `mfi_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$money_flow_index(window = 14, days = 120)
    print(tail(frame[, c("datetime", "mfi_14")]))

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      frame <- share$money_flow_index(window = 14, days = 120)
      latest <- frame$mfi_14[nrow(frame)]
      if (latest > 80) {
        label <- "overbought"
      } else if (latest < 20) {
        label <- "oversold"
      } else {
        label <- "neutral"
      }
      cat(sprintf("%s: %.1f %s\n", symbol, latest, label))
    }

------------------------------------------------------------------------

### `MomentumIndicators$minus_directional_indicator()`

Adds the minus directional indicator.

#### Usage

    MomentumIndicators$minus_directional_indicator(
      window = 14,
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

A `data.frame` of the candles with a `minus_di_<window>` column added,
or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$minus_directional_indicator(window = 14, days = 120)
    print(tail(frame[, c("datetime", "minus_di_14")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    minus_frame <- nifty$minus_directional_indicator(window = 14, days = 120)
    plus_frame <- nifty$plus_directional_indicator(window = 14, days = 120)
    minus_value <- round(minus_frame$minus_di_14[nrow(minus_frame)], 1)
    plus_value <- round(plus_frame$plus_di_14[nrow(plus_frame)], 1)
    if (minus_value > plus_value) {
      cat(sprintf(
        "Sellers dominate: -DI %s, +DI %s\n",
        minus_value,
        plus_value
      ))
    } else {
      cat(sprintf(
        "Buyers dominate: -DI %s, +DI %s\n",
        minus_value,
        plus_value
      ))
    }

------------------------------------------------------------------------

### `MomentumIndicators$minus_directional_movement()`

Adds the minus directional movement.

#### Usage

    MomentumIndicators$minus_directional_movement(
      window = 14,
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

A `data.frame` of the candles with a `minus_dm_<window>` column added,
or `NULL` when UBI has no candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    frame <- tcs$minus_directional_movement(window = 14, days = 120)
    print(tail(frame[, c("datetime", "minus_dm_14")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$minus_directional_movement(
      window = 7,
      from_date = "2026-01-01",
      to_date = "2026-09-28"
    )
    peak_row <- which.max(frame$minus_dm_7)
    peak_day <- as.Date(frame$datetime[peak_row], tz = "Asia/Kolkata")
    print(paste(peak_day, round(frame$minus_dm_7[peak_row], 2)))

------------------------------------------------------------------------

### `MomentumIndicators$plus_directional_indicator()`

Adds the plus directional indicator.

#### Usage

    MomentumIndicators$plus_directional_indicator(
      window = 14,
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

A `data.frame` of the candles with a `plus_di_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$plus_directional_indicator(window = 14, days = 120)
    print(tail(frame[, c("datetime", "plus_di_14")]))

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    frame <- hdfc_bank$plus_directional_indicator(window = 14, days = 180)
    days_above <- sum(frame$plus_di_14 > 25, na.rm = TRUE)
    cat(sprintf("Above 25 on %d days\n", days_above))

------------------------------------------------------------------------

### `MomentumIndicators$plus_directional_movement()`

Adds the plus directional movement.

#### Usage

    MomentumIndicators$plus_directional_movement(
      window = 14,
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

A `data.frame` of the candles with a `plus_dm_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$plus_directional_movement(window = 14, days = 120)
    print(tail(frame[, c("datetime", "plus_dm_14")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$plus_directional_movement(window = 7, days = 60)
    cat(sprintf("%.2f points\n", frame$plus_dm_7[nrow(frame)]))

------------------------------------------------------------------------

### `MomentumIndicators$percentage_price_oscillator()`

Adds the percentage price oscillator, the gap between a fast and a slow
moving average as a percentage.

#### Usage

    MomentumIndicators$percentage_price_oscillator(
      fast_period = 12,
      slow_period = 26,
      moving_average_type = 0,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `fast_period`:

  The integer number of candles in the fast moving average.

- `slow_period`:

  The integer number of candles in the slow moving average.

- `moving_average_type`:

  The integer TA-Lib moving average type, where 0 is a simple moving
  average.

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

A `data.frame` of the candles with a `ppo<fast>_<slow>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$percentage_price_oscillator(days = 180)
    print(tail(frame[, c("datetime", "ppo12_26")]))

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      frame <- share$percentage_price_oscillator(
        moving_average_type = 1,
        days = 180
      )
      cat(sprintf("%s: %.2f%%\n", symbol, frame$ppo12_26[nrow(frame)]))
    }

------------------------------------------------------------------------

### `MomentumIndicators$rate_of_change()`

Adds the rate of change of one candle column as a percentage.

#### Usage

    MomentumIndicators$rate_of_change(
      window = 14,
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

Errors: signals a plain error when `window` is below 1 or above 100000,
as TA-Lib does; and `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `roc_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$rate_of_change(window = 14, days = 120)
    print(tail(frame[, c("datetime", "roc_14")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$rate_of_change(
      window = 20,
      from_date = "2026-01-01",
      to_date = "2026-06-30"
    )
    cat(sprintf("Best 20 days: %.2f%%\n", max(frame$roc_20, na.rm = TRUE)))
    cat(sprintf("Worst 20 days: %.2f%%\n", min(frame$roc_20, na.rm = TRUE)))

------------------------------------------------------------------------

### `MomentumIndicators$rate_of_change_percent()`

Adds the rate of change of one candle column as a fraction.

#### Usage

    MomentumIndicators$rate_of_change_percent(
      window = 14,
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

Errors: signals a plain error when `window` is below 1 or above 100000,
as TA-Lib does; and `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `rocp_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$rate_of_change_percent(window = 14, days = 120)
    print(tail(frame[, c("datetime", "rocp_14")]))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    frame <- tcs$rate_of_change_percent(
      window = 5,
      column = "high",
      days = 60
    )
    print(round(frame$rocp_5[nrow(frame)], 4))

------------------------------------------------------------------------

### `MomentumIndicators$rate_of_change_ratio()`

Adds the rate of change of one candle column as a ratio.

#### Usage

    MomentumIndicators$rate_of_change_ratio(
      window = 14,
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

A `data.frame` of the candles with a `rocr_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$rate_of_change_ratio(window = 14, days = 120)
    print(tail(frame[, c("datetime", "rocr_14")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$rate_of_change_ratio(window = 10, days = 60)
    ratio <- frame$rocr_10[nrow(frame)]
    if (ratio > 1) {
      cat(sprintf("Higher than ten days ago, ratio %.4f\n", ratio))
    } else {
      cat(sprintf("Lower than ten days ago, ratio %.4f\n", ratio))
    }

------------------------------------------------------------------------

### `MomentumIndicators$relative_strength_index()`

Adds the relative strength index of one candle column.

#### Usage

    MomentumIndicators$relative_strength_index(
      window = 14,
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

A `data.frame` of the candles with an `rsi_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$relative_strength_index(window = 14, days = 120)
    print(tail(frame[, c("datetime", "rsi_14")]))

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      frame <- share$relative_strength_index(window = 14, days = 120)
      latest <- frame$rsi_14[nrow(frame)]
      if (latest > 70) {
        label <- "overbought"
      } else if (latest < 30) {
        label <- "oversold"
      } else {
        label <- "neutral"
      }
      cat(sprintf("%s: %.1f %s\n", symbol, latest, label))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$relative_strength_index(
      window = 9,
      column = "high",
      from_date = "2026-04-01",
      to_date = "2026-06-30"
    )
    complete <- frame[!is.na(frame$rsi_9), ]
    print(data.frame(
      datetime = complete$datetime,
      rsi_9 = round(complete$rsi_9, 1)
    ))

------------------------------------------------------------------------

### `MomentumIndicators$stochastic_oscillator()`

Adds the slow stochastic oscillator's %K and %D lines.

#### Usage

    MomentumIndicators$stochastic_oscillator(
      fast_k_period = 5,
      slow_k_period = 3,
      slow_k_moving_average_type = 0,
      slow_d_period = 3,
      slow_d_moving_average_type = 0,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `fast_k_period`:

  The integer number of candles in the fast %K calculation.

- `slow_k_period`:

  The integer number of candles smoothing fast %K into slow %K.

- `slow_k_moving_average_type`:

  The integer TA-Lib moving average type for slow %K, where 0 is a
  simple moving average.

- `slow_d_period`:

  The integer number of candles smoothing slow %K into slow %D.

- `slow_d_moving_average_type`:

  The integer TA-Lib moving average type for slow %D, where 0 is a
  simple moving average.

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

A `data.frame` of the candles with `slowk_<period>` and `slowd_<period>`
columns added, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$stochastic_oscillator(days = 90)
    columns <- c(
      "datetime",
      "slowk_3",
      "slowd_3"
    )
    print(tail(frame[, columns]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$stochastic_oscillator(
      fast_k_period = 14,
      slow_k_period = 3,
      slow_d_period = 3,
      days = 120
    )
    difference <- frame$slowk_3 - frame$slowd_3
    last <- length(difference)
    crossed <- difference[last] > 0 && difference[last - 1] <= 0
    cat(sprintf("%%K %.1f\n", frame$slowk_3[nrow(frame)]))
    cat(sprintf("Crossed above %%D: %s\n", crossed))

------------------------------------------------------------------------

### `MomentumIndicators$stochastic_fast_oscillator()`

Adds the fast stochastic oscillator's %K and %D lines.

#### Usage

    MomentumIndicators$stochastic_fast_oscillator(
      fast_k_period = 5,
      fast_d_period = 3,
      fast_d_moving_average_type = 0,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `fast_k_period`:

  The integer number of candles in the fast %K calculation.

- `fast_d_period`:

  The integer number of candles smoothing fast %K into fast %D.

- `fast_d_moving_average_type`:

  The integer TA-Lib moving average type for fast %D, where 0 is a
  simple moving average.

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

A `data.frame` of the candles with `stochf_fastk<period>` and
`stochf_fastd<period>` columns added, or `NULL` when UBI has no candles
for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$stochastic_fast_oscillator(days = 90)
    columns <- c(
      "datetime",
      "stochf_fastk5",
      "stochf_fastd3"
    )
    print(tail(frame[, columns]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$stochastic_fast_oscillator(
      fast_k_period = 14,
      fast_d_period = 3,
      days = 90
    )
    fast_k <- round(frame$stochf_fastk14[nrow(frame)], 1)
    cat(sprintf("%s%% of the 14-day range\n", fast_k))

------------------------------------------------------------------------

### `MomentumIndicators$stochastic_relative_strength_index()`

Adds the stochastic relative strength index's %K and %D lines for one
candle column.

#### Usage

    MomentumIndicators$stochastic_relative_strength_index(
      window = 14,
      fast_k_period = 5,
      fast_d_period = 3,
      fast_d_moving_average_type = 0,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `window`:

  The integer number of candles in the relative strength index that the
  stochastic is taken of.

- `fast_k_period`:

  The integer number of relative strength index values the stochastic %K
  looks back over.

- `fast_d_period`:

  The integer number of candles smoothing %K into %D.

- `fast_d_moving_average_type`:

  The integer TA-Lib moving average type for %D, where 0 is a simple
  moving average.

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

A `data.frame` of the candles with `stochrsi_fastk<period>` and
`stochrsi_fastd<period>` columns added, or `NULL` when UBI has no
candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$stochastic_relative_strength_index(days = 120)
    columns <- c(
      "datetime",
      "stochrsi_fastk5",
      "stochrsi_fastd3"
    )
    print(tail(frame[, columns]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$stochastic_relative_strength_index(
      window = 14,
      fast_k_period = 14,
      fast_d_period = 3,
      days = 180
    )
    cat(sprintf("%%K %.1f\n", frame$stochrsi_fastk14[nrow(frame)]))
    cat(sprintf("%%D %.1f\n", frame$stochrsi_fastd3[nrow(frame)]))

------------------------------------------------------------------------

### `MomentumIndicators$trix()`

Adds TRIX, the rate of change of a triple smoothed exponential moving
average of one candle column.

#### Usage

    MomentumIndicators$trix(
      window = 15,
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

A `data.frame` of the candles with a `trix_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$trix(days = 180)
    print(tail(frame[, c("datetime", "trix_15")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$trix(window = 9, days = 180)
    latest <- frame$trix_9[nrow(frame)]
    previous <- frame$trix_9[nrow(frame) - 1]
    if (latest > previous) {
      cat(sprintf("TRIX is rising: %.4f to %.4f\n", previous, latest))
    } else {
      cat(sprintf("TRIX is falling: %.4f to %.4f\n", previous, latest))
    }

------------------------------------------------------------------------

### `MomentumIndicators$ultimate_oscillator()`

Adds the ultimate oscillator, which blends buying pressure over three
windows.

#### Usage

    MomentumIndicators$ultimate_oscillator(
      fast_period = 7,
      slow_period = 14,
      signal_period = 28,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `fast_period`:

  The integer number of candles in the shortest window.

- `slow_period`:

  The integer number of candles in the middle window.

- `signal_period`:

  The integer number of candles in the longest window.

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

A `data.frame` of the candles with an `ultosc_<fast>_<slow>_<signal>`
column added, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$ultimate_oscillator(days = 120)
    print(tail(frame[, c("datetime", "ultosc_7_14_28")]))

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    frame <- reliance$ultimate_oscillator(days = 120)
    latest <- frame$ultosc_7_14_28[nrow(frame)]
    if (latest > 70) {
      label <- "overbought"
    } else if (latest < 30) {
      label <- "oversold"
    } else {
      label <- "neutral"
    }
    cat(sprintf("Reliance ultimate oscillator %.1f: %s\n", latest, label))

------------------------------------------------------------------------

### `MomentumIndicators$williams_percent_r()`

Adds Williams %R.

#### Usage

    MomentumIndicators$williams_percent_r(
      window = 14,
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

A `data.frame` of the candles with a `willr_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$williams_percent_r(window = 14, days = 90)
    print(tail(frame[, c("datetime", "willr_14")]))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$williams_percent_r(window = 14, days = 365)
    days_below <- sum(frame$willr_14 < -80, na.rm = TRUE)
    cat(sprintf("Below -80 on %d days\n", days_below))

------------------------------------------------------------------------

### `MomentumIndicators$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MomentumIndicators$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$relative_strength_index(window = 14, days = 365)
} # }

## ------------------------------------------------
## Method `MomentumIndicators$moving_average_convergence_divergence()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$moving_average_convergence_divergence(days = 180)
columns <- c(
  "datetime",
  "macd_12_26_9",
  "macd_12_26_9_signal",
  "macd_12_26_9_hist"
)
print(tail(frame[, columns]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$moving_average_convergence_divergence(
  fast_period = 8,
  slow_period = 21,
  signal_period = 5,
  days = 365
)
histogram <- frame$macd_8_21_5_hist
previous <- c(NA, histogram[-length(histogram)])
crossed_above <- which(histogram > 0 & previous <= 0)
print(as.Date(frame$datetime[crossed_above], tz = "Asia/Kolkata"))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$average_directional_movement_index()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$average_directional_movement_index(days = 180)
print(tail(frame[, c("datetime", "adx_14")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$average_directional_movement_index(
  window = 14,
  days = 180
)
latest <- frame$adx_14[nrow(frame)]
if (latest > 25) {
  cat(sprintf("NIFTY is trending, ADX %.1f\n", latest))
} else {
  cat(sprintf("NIFTY is moving sideways, ADX %.1f\n", latest))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$momentum()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
frame <- reliance$momentum(window = 10, days = 120)
print(tail(frame[, c("datetime", "momentum_10")]))

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  frame <- share$momentum(window = 20, column = "high", days = 120)
  print(paste(symbol, round(frame$momentum_20[nrow(frame)], 2)))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$commodity_channel_index()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$commodity_channel_index(window = 20, days = 180)
print(tail(frame[, c("datetime", "cci_20")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$commodity_channel_index(window = 20, days = 365)
above <- sum(frame$cci_20 > 100, na.rm = TRUE)
below <- sum(frame$cci_20 < -100, na.rm = TRUE)
cat(sprintf(
  "Above 100 on %d days, below -100 on %d days\n",
  above,
  below
))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$average_directional_movement_index_rating()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
frame <- hdfc_bank$average_directional_movement_index_rating(
  window = 14,
  days = 180
)
print(tail(frame[, c("datetime", "adxr_14")]))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
rating_frame <- infosys$average_directional_movement_index_rating(
  window = 14,
  days = 180
)
index_frame <- infosys$average_directional_movement_index(
  window = 14,
  days = 180
)
print(paste("ADXR", round(rating_frame$adxr_14[nrow(rating_frame)], 2)))
print(paste("ADX", round(index_frame$adx_14[nrow(index_frame)], 2)))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$absolute_price_oscillator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$absolute_price_oscillator(days = 180)
print(tail(frame[, c("datetime", "apo_12_26")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$absolute_price_oscillator(
  fast_period = 5,
  slow_period = 20,
  moving_average_type = 1,
  days = 120
)
gap <- round(frame$apo_5_20[nrow(frame)], 2)
if (gap > 0) {
  cat(sprintf(
    "The fast average is %s points above the slow one\n",
    gap
  ))
} else {
  cat(sprintf(
    "The fast average is %s points below the slow one\n",
    -gap
  ))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$aroon()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$aroon(window = 25, days = 180)
columns <- c(
  "datetime",
  "aroon_down_25",
  "aroon_up_25"
)
print(tail(frame[, columns]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$aroon(window = 25, days = 180)
aroon_up <- as.integer(frame$aroon_up_25[nrow(frame)])
aroon_down <- as.integer(frame$aroon_down_25[nrow(frame)])
if (aroon_up > aroon_down) {
  cat(sprintf("New highs lead: up %d, down %d\n", aroon_up, aroon_down))
} else {
  cat(sprintf("New lows lead: up %d, down %d\n", aroon_up, aroon_down))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$aroon_oscillator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
frame <- tcs$aroon_oscillator(window = 14, days = 180)
print(tail(frame[, c("datetime", "aroon_osc_14")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$aroon_oscillator(window = 14, days = 180)
last_sixty <- tail(frame$aroon_osc_14, 60)
positive_days <- sum(last_sixty > 0, na.rm = TRUE)
cat(sprintf(
  "Positive on %d of %d days\n",
  positive_days,
  length(last_sixty)
))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$balance_of_power()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$balance_of_power(days = 60)
print(tail(frame[, c("datetime", "bop")]))

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
frame <- reliance$balance_of_power(days = 120)
smoothed <- mean(tail(frame$bop, 10))
if (smoothed > 0) {
  cat(sprintf("Buyers have been in control: %.3f\n", smoothed))
} else {
  cat(sprintf("Sellers have been in control: %.3f\n", smoothed))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$chande_momentum_oscillator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$chande_momentum_oscillator(window = 14, days = 120)
print(tail(frame[, c("datetime", "cmo_14")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$chande_momentum_oscillator(window = 14, days = 120)
latest <- frame$cmo_14[nrow(frame)]
if (latest > 50) {
  label <- "overbought"
} else if (latest < -50) {
  label <- "oversold"
} else {
  label <- "neutral"
}
cat(sprintf("NIFTY CMO %.1f: %s\n", latest, label))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$directional_movement_index()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$directional_movement_index(window = 14, days = 120)
print(tail(frame[, c("datetime", "dx_14")]))

bank_nifty <- EquityIndex$new(
  exchange = "nse",
  symbol = "BANKNIFTY"
)
frame <- bank_nifty$directional_movement_index(
  window = 14,
  from_date = "2026-01-01",
  to_date = "2026-03-31"
)
cat(sprintf("Average DX: %.2f\n", mean(frame$dx_14, na.rm = TRUE)))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$moving_average_convergence_divergence_extended()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$moving_average_convergence_divergence_extended(
  fast_moving_average_type = 1,
  slow_moving_average_type = 1,
  signal_moving_average_type = 1,
  days = 180
)
columns <- c(
  "datetime",
  "macd_12_26_9",
  "macd_signal_12_26_9",
  "macd_hist_12_26_9"
)
print(tail(frame[, columns]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$moving_average_convergence_divergence_extended(
  fast_period = 10,
  fast_moving_average_type = 2,
  slow_period = 30,
  slow_moving_average_type = 2,
  signal_period = 7,
  signal_moving_average_type = 0,
  days = 240
)
print(round(frame$macd_hist_10_30_7[nrow(frame)], 2))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$money_flow_index()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$money_flow_index(window = 14, days = 120)
print(tail(frame[, c("datetime", "mfi_14")]))

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  frame <- share$money_flow_index(window = 14, days = 120)
  latest <- frame$mfi_14[nrow(frame)]
  if (latest > 80) {
    label <- "overbought"
  } else if (latest < 20) {
    label <- "oversold"
  } else {
    label <- "neutral"
  }
  cat(sprintf("%s: %.1f %s\n", symbol, latest, label))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$minus_directional_indicator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$minus_directional_indicator(window = 14, days = 120)
print(tail(frame[, c("datetime", "minus_di_14")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
minus_frame <- nifty$minus_directional_indicator(window = 14, days = 120)
plus_frame <- nifty$plus_directional_indicator(window = 14, days = 120)
minus_value <- round(minus_frame$minus_di_14[nrow(minus_frame)], 1)
plus_value <- round(plus_frame$plus_di_14[nrow(plus_frame)], 1)
if (minus_value > plus_value) {
  cat(sprintf(
    "Sellers dominate: -DI %s, +DI %s\n",
    minus_value,
    plus_value
  ))
} else {
  cat(sprintf(
    "Buyers dominate: -DI %s, +DI %s\n",
    minus_value,
    plus_value
  ))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$minus_directional_movement()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
frame <- tcs$minus_directional_movement(window = 14, days = 120)
print(tail(frame[, c("datetime", "minus_dm_14")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$minus_directional_movement(
  window = 7,
  from_date = "2026-01-01",
  to_date = "2026-09-28"
)
peak_row <- which.max(frame$minus_dm_7)
peak_day <- as.Date(frame$datetime[peak_row], tz = "Asia/Kolkata")
print(paste(peak_day, round(frame$minus_dm_7[peak_row], 2)))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$plus_directional_indicator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$plus_directional_indicator(window = 14, days = 120)
print(tail(frame[, c("datetime", "plus_di_14")]))

hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
frame <- hdfc_bank$plus_directional_indicator(window = 14, days = 180)
days_above <- sum(frame$plus_di_14 > 25, na.rm = TRUE)
cat(sprintf("Above 25 on %d days\n", days_above))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$plus_directional_movement()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$plus_directional_movement(window = 14, days = 120)
print(tail(frame[, c("datetime", "plus_dm_14")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$plus_directional_movement(window = 7, days = 60)
cat(sprintf("%.2f points\n", frame$plus_dm_7[nrow(frame)]))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$percentage_price_oscillator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$percentage_price_oscillator(days = 180)
print(tail(frame[, c("datetime", "ppo12_26")]))

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  frame <- share$percentage_price_oscillator(
    moving_average_type = 1,
    days = 180
  )
  cat(sprintf("%s: %.2f%%\n", symbol, frame$ppo12_26[nrow(frame)]))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$rate_of_change()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$rate_of_change(window = 14, days = 120)
print(tail(frame[, c("datetime", "roc_14")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$rate_of_change(
  window = 20,
  from_date = "2026-01-01",
  to_date = "2026-06-30"
)
cat(sprintf("Best 20 days: %.2f%%\n", max(frame$roc_20, na.rm = TRUE)))
cat(sprintf("Worst 20 days: %.2f%%\n", min(frame$roc_20, na.rm = TRUE)))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$rate_of_change_percent()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$rate_of_change_percent(window = 14, days = 120)
print(tail(frame[, c("datetime", "rocp_14")]))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
frame <- tcs$rate_of_change_percent(
  window = 5,
  column = "high",
  days = 60
)
print(round(frame$rocp_5[nrow(frame)], 4))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$rate_of_change_ratio()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$rate_of_change_ratio(window = 14, days = 120)
print(tail(frame[, c("datetime", "rocr_14")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$rate_of_change_ratio(window = 10, days = 60)
ratio <- frame$rocr_10[nrow(frame)]
if (ratio > 1) {
  cat(sprintf("Higher than ten days ago, ratio %.4f\n", ratio))
} else {
  cat(sprintf("Lower than ten days ago, ratio %.4f\n", ratio))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$relative_strength_index()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$relative_strength_index(window = 14, days = 120)
print(tail(frame[, c("datetime", "rsi_14")]))

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  frame <- share$relative_strength_index(window = 14, days = 120)
  latest <- frame$rsi_14[nrow(frame)]
  if (latest > 70) {
    label <- "overbought"
  } else if (latest < 30) {
    label <- "oversold"
  } else {
    label <- "neutral"
  }
  cat(sprintf("%s: %.1f %s\n", symbol, latest, label))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$relative_strength_index(
  window = 9,
  column = "high",
  from_date = "2026-04-01",
  to_date = "2026-06-30"
)
complete <- frame[!is.na(frame$rsi_9), ]
print(data.frame(
  datetime = complete$datetime,
  rsi_9 = round(complete$rsi_9, 1)
))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$stochastic_oscillator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$stochastic_oscillator(days = 90)
columns <- c(
  "datetime",
  "slowk_3",
  "slowd_3"
)
print(tail(frame[, columns]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$stochastic_oscillator(
  fast_k_period = 14,
  slow_k_period = 3,
  slow_d_period = 3,
  days = 120
)
difference <- frame$slowk_3 - frame$slowd_3
last <- length(difference)
crossed <- difference[last] > 0 && difference[last - 1] <= 0
cat(sprintf("%%K %.1f\n", frame$slowk_3[nrow(frame)]))
cat(sprintf("Crossed above %%D: %s\n", crossed))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$stochastic_fast_oscillator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$stochastic_fast_oscillator(days = 90)
columns <- c(
  "datetime",
  "stochf_fastk5",
  "stochf_fastd3"
)
print(tail(frame[, columns]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$stochastic_fast_oscillator(
  fast_k_period = 14,
  fast_d_period = 3,
  days = 90
)
fast_k <- round(frame$stochf_fastk14[nrow(frame)], 1)
cat(sprintf("%s%% of the 14-day range\n", fast_k))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$stochastic_relative_strength_index()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$stochastic_relative_strength_index(days = 120)
columns <- c(
  "datetime",
  "stochrsi_fastk5",
  "stochrsi_fastd3"
)
print(tail(frame[, columns]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$stochastic_relative_strength_index(
  window = 14,
  fast_k_period = 14,
  fast_d_period = 3,
  days = 180
)
cat(sprintf("%%K %.1f\n", frame$stochrsi_fastk14[nrow(frame)]))
cat(sprintf("%%D %.1f\n", frame$stochrsi_fastd3[nrow(frame)]))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$trix()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$trix(days = 180)
print(tail(frame[, c("datetime", "trix_15")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$trix(window = 9, days = 180)
latest <- frame$trix_9[nrow(frame)]
previous <- frame$trix_9[nrow(frame) - 1]
if (latest > previous) {
  cat(sprintf("TRIX is rising: %.4f to %.4f\n", previous, latest))
} else {
  cat(sprintf("TRIX is falling: %.4f to %.4f\n", previous, latest))
}
} # }

## ------------------------------------------------
## Method `MomentumIndicators$ultimate_oscillator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$ultimate_oscillator(days = 120)
print(tail(frame[, c("datetime", "ultosc_7_14_28")]))

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
frame <- reliance$ultimate_oscillator(days = 120)
latest <- frame$ultosc_7_14_28[nrow(frame)]
if (latest > 70) {
  label <- "overbought"
} else if (latest < 30) {
  label <- "oversold"
} else {
  label <- "neutral"
}
cat(sprintf("Reliance ultimate oscillator %.1f: %s\n", latest, label))
} # }

## ------------------------------------------------
## Method `MomentumIndicators$williams_percent_r()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$williams_percent_r(window = 14, days = 90)
print(tail(frame[, c("datetime", "willr_14")]))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$williams_percent_r(window = 14, days = 365)
days_below <- sum(frame$willr_14 < -80, na.rm = TRUE)
cat(sprintf("Below -80 on %d days\n", days_below))
} # }
```
