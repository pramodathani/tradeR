# Hilbert transform cycle indicators an instrument calculates from its candles

The Hilbert transform family, which looks for repeating cycles in
prices. Each method fetches the instrument's candles through `prices()`,
adds one or more TA-Lib columns, computed by the `talib` package, and
returns the candles. The class is a link in the chain of analysis
classes, inheriting `VolumeIndicators`, and `Instrument` inherits it
through that chain and supplies `prices()`.

The Hilbert transform functions need a long warm-up before their first
value: TA-Lib's lookback is 32 candles for the dominant cycle period and
the phasor components, and 63 for the other four, so a short range
returns columns that are mostly or entirely empty.

## Super classes

[`PriceAnalysis`](https://pramodathani.github.io/tradeR/reference/PriceAnalysis.md)
-\>
[`PriceStatistics`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.md)
-\>
[`OverlapStudies`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.md)
-\>
[`MomentumIndicators`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.md)
-\>
[`VolumeIndicators`](https://pramodathani.github.io/tradeR/reference/VolumeIndicators.md)
-\> `CycleIndicators`

## Methods

### Public methods

- [`CycleIndicators$hilbert_transform_dominant_cycle_period()`](#method-CycleIndicators-hilbert_transform_dominant_cycle_period)

- [`CycleIndicators$hilbert_transform_dominant_cycle_phase()`](#method-CycleIndicators-hilbert_transform_dominant_cycle_phase)

- [`CycleIndicators$hilbert_transform_phasor_components()`](#method-CycleIndicators-hilbert_transform_phasor_components)

- [`CycleIndicators$hilbert_transform_sine_wave()`](#method-CycleIndicators-hilbert_transform_sine_wave)

- [`CycleIndicators$hilbert_transform_trend_mode()`](#method-CycleIndicators-hilbert_transform_trend_mode)

- [`CycleIndicators$hilbert_transform_trend_line()`](#method-CycleIndicators-hilbert_transform_trend_line)

- [`CycleIndicators$clone()`](#method-CycleIndicators-clone)

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
- [`MomentumIndicators$absolute_price_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-absolute_price_oscillator)
- [`MomentumIndicators$aroon()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-aroon)
- [`MomentumIndicators$aroon_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-aroon_oscillator)
- [`MomentumIndicators$average_directional_movement_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-average_directional_movement_index)
- [`MomentumIndicators$average_directional_movement_index_rating()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-average_directional_movement_index_rating)
- [`MomentumIndicators$balance_of_power()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-balance_of_power)
- [`MomentumIndicators$chande_momentum_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-chande_momentum_oscillator)
- [`MomentumIndicators$commodity_channel_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-commodity_channel_index)
- [`MomentumIndicators$directional_movement_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-directional_movement_index)
- [`MomentumIndicators$minus_directional_indicator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-minus_directional_indicator)
- [`MomentumIndicators$minus_directional_movement()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-minus_directional_movement)
- [`MomentumIndicators$momentum()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-momentum)
- [`MomentumIndicators$money_flow_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-money_flow_index)
- [`MomentumIndicators$moving_average_convergence_divergence()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-moving_average_convergence_divergence)
- [`MomentumIndicators$moving_average_convergence_divergence_extended()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-moving_average_convergence_divergence_extended)
- [`MomentumIndicators$percentage_price_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-percentage_price_oscillator)
- [`MomentumIndicators$plus_directional_indicator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-plus_directional_indicator)
- [`MomentumIndicators$plus_directional_movement()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-plus_directional_movement)
- [`MomentumIndicators$rate_of_change()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-rate_of_change)
- [`MomentumIndicators$rate_of_change_percent()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-rate_of_change_percent)
- [`MomentumIndicators$rate_of_change_ratio()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-rate_of_change_ratio)
- [`MomentumIndicators$relative_strength_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-relative_strength_index)
- [`MomentumIndicators$stochastic_fast_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-stochastic_fast_oscillator)
- [`MomentumIndicators$stochastic_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-stochastic_oscillator)
- [`MomentumIndicators$stochastic_relative_strength_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-stochastic_relative_strength_index)
- [`MomentumIndicators$trix()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-trix)
- [`MomentumIndicators$ultimate_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-ultimate_oscillator)
- [`MomentumIndicators$williams_percent_r()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-williams_percent_r)
- [`VolumeIndicators$chaikin_accumulation_distribution_line()`](https://pramodathani.github.io/tradeR/reference/VolumeIndicators.html#method-chaikin_accumulation_distribution_line)
- [`VolumeIndicators$chaikin_accumulation_distribution_oscillator()`](https://pramodathani.github.io/tradeR/reference/VolumeIndicators.html#method-chaikin_accumulation_distribution_oscillator)
- [`VolumeIndicators$on_balance_volume()`](https://pramodathani.github.io/tradeR/reference/VolumeIndicators.html#method-on_balance_volume)

------------------------------------------------------------------------

### `CycleIndicators$hilbert_transform_dominant_cycle_period()`

Adds the Hilbert transform dominant cycle period of one candle column.

#### Usage

    CycleIndicators$hilbert_transform_dominant_cycle_period(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `interval`:

  The character candle interval, such as `day` or `5minute`.

- `from_date`:

  The first day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `to_date`:

  The last day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  from_date and to_date are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `ht_dcperiod` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$hilbert_transform_dominant_cycle_period(days = 365)
    print(tail(candles[, c("datetime", "close", "ht_dcperiod")], 5))

    instruments <- list(
      EquityIndex$new(exchange = "nse", symbol = "NIFTY"),
      Equity$new(exchange = "nse", symbol = "HDFCBANK"),
      Equity$new(exchange = "nse", symbol = "ICICIBANK"),
      Equity$new(exchange = "nse", symbol = "SBIN")
    )
    for (instrument in instruments) {
      candles <- instrument$hilbert_transform_dominant_cycle_period(
        days = 365
      )
      period <- candles$ht_dcperiod[[nrow(candles)]]
      cat(sprintf("%s: %.1f days\n", instrument$symbol, period))
    }

------------------------------------------------------------------------

### `CycleIndicators$hilbert_transform_dominant_cycle_phase()`

Adds the Hilbert transform dominant cycle phase of one candle column.

#### Usage

    CycleIndicators$hilbert_transform_dominant_cycle_phase(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `interval`:

  The character candle interval, such as `day` or `5minute`.

- `from_date`:

  The first day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `to_date`:

  The last day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  from_date and to_date are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `ht_dcphase` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$hilbert_transform_dominant_cycle_phase(days = 365)
    print(tail(candles[, c("datetime", "close", "ht_dcphase")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    candles <- nifty$hilbert_transform_dominant_cycle_phase(
      column = "high",
      days = 365
    )
    phase <- candles$ht_dcphase[[nrow(candles)]]
    cat(sprintf("%.0f degrees\n", phase))

------------------------------------------------------------------------

### `CycleIndicators$hilbert_transform_phasor_components()`

Adds the Hilbert transform in-phase and quadrature phasor components of
one candle column.

#### Usage

    CycleIndicators$hilbert_transform_phasor_components(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `interval`:

  The character candle interval, such as `day` or `5minute`.

- `from_date`:

  The first day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `to_date`:

  The last day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  from_date and to_date are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with `inphase` and `quadrature` columns
added, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$hilbert_transform_phasor_components(days = 365)
    columns <- c(
      "datetime",
      "close",
      "inphase",
      "quadrature"
    )
    print(tail(candles[, columns], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    candles <- nifty$hilbert_transform_phasor_components(days = 365)
    last_row <- candles[nrow(candles), ]
    radians <- atan2(last_row$quadrature, last_row$inphase)
    cat(sprintf("%.0f degrees\n", radians * 180 / pi))

------------------------------------------------------------------------

### `CycleIndicators$hilbert_transform_sine_wave()`

Adds the Hilbert transform sine wave and lead sine wave of one candle
column.

#### Usage

    CycleIndicators$hilbert_transform_sine_wave(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `interval`:

  The character candle interval, such as `day` or `5minute`.

- `from_date`:

  The first day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `to_date`:

  The last day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  from_date and to_date are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with `sine` and `lead_sine` columns added,
or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$hilbert_transform_sine_wave(days = 365)
    print(tail(candles[, c("datetime", "close", "sine", "lead_sine")], 5))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$hilbert_transform_sine_wave(days = 365)
      last_row <- candles[nrow(candles), ]
      if (last_row$lead_sine > last_row$sine) {
        cat(sprintf("%s: lead sine above, cycle turning up\n", symbol))
      } else {
        cat(sprintf("%s: lead sine below, cycle turning down\n", symbol))
      }
    }

------------------------------------------------------------------------

### `CycleIndicators$hilbert_transform_trend_mode()`

Adds the Hilbert transform trend mode of one candle column, 1 in a trend
and 0 in a cycle.

#### Usage

    CycleIndicators$hilbert_transform_trend_mode(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `interval`:

  The character candle interval, such as `day` or `5minute`.

- `from_date`:

  The first day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `to_date`:

  The last day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  from_date and to_date are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `ht_trendmode` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$hilbert_transform_trend_mode(days = 365)
    print(tail(candles[, c("datetime", "close", "ht_trendmode")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    candles <- nifty$hilbert_transform_trend_mode(days = 365)
    trending_days <- sum(candles$ht_trendmode)
    cat(sprintf("%d of %d days trending\n", trending_days, nrow(candles)))

    information_technology <- Watchlist$new(
      name = "information technology",
      instruments = list(
        Equity$new(exchange = "nse", symbol = "INFY"),
        Equity$new(exchange = "nse", symbol = "TCS"),
        Equity$new(exchange = "nse", symbol = "WIPRO")
      )
    )
    candles <- information_technology$hilbert_transform_trend_mode(
      days = 365
    )
    if (candles$ht_trendmode[[nrow(candles)]] == 1) {
      cat("Trending\n")
    } else {
      cat("Cycling\n")
    }

------------------------------------------------------------------------

### `CycleIndicators$hilbert_transform_trend_line()`

Adds the Hilbert transform instantaneous trend line of one candle
column.

#### Usage

    CycleIndicators$hilbert_transform_trend_line(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `interval`:

  The character candle interval, such as `day` or `5minute`.

- `from_date`:

  The first day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `to_date`:

  The last day of the range as a `Date` or a `YYYY-MM-DD` character, or
  `NULL` when days is given.

- `days`:

  The integer number of days to count back from today, or `NULL` when
  from_date and to_date are given.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the
request or could not be reached.

#### Returns

A `data.frame` of the candles with a `ht_trendline` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$hilbert_transform_trend_line(days = 365)
    print(tail(candles[, c("datetime", "close", "ht_trendline")], 5))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$hilbert_transform_trend_line(days = 365)
      last_row <- candles[nrow(candles), ]
      ratio <- last_row$close / last_row$ht_trendline
      distance <- (ratio - 1) * 100
      cat(sprintf("%s: %.2f%%\n", symbol, distance))
    }

------------------------------------------------------------------------

### `CycleIndicators$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CycleIndicators$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
infosys <- Instrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)
frame <- infosys$hilbert_transform_sine_wave(days = 365)
} # }

## ------------------------------------------------
## Method `CycleIndicators$hilbert_transform_dominant_cycle_period()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$hilbert_transform_dominant_cycle_period(days = 365)
print(tail(candles[, c("datetime", "close", "ht_dcperiod")], 5))

instruments <- list(
  EquityIndex$new(exchange = "nse", symbol = "NIFTY"),
  Equity$new(exchange = "nse", symbol = "HDFCBANK"),
  Equity$new(exchange = "nse", symbol = "ICICIBANK"),
  Equity$new(exchange = "nse", symbol = "SBIN")
)
for (instrument in instruments) {
  candles <- instrument$hilbert_transform_dominant_cycle_period(
    days = 365
  )
  period <- candles$ht_dcperiod[[nrow(candles)]]
  cat(sprintf("%s: %.1f days\n", instrument$symbol, period))
}
} # }

## ------------------------------------------------
## Method `CycleIndicators$hilbert_transform_dominant_cycle_phase()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$hilbert_transform_dominant_cycle_phase(days = 365)
print(tail(candles[, c("datetime", "close", "ht_dcphase")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
candles <- nifty$hilbert_transform_dominant_cycle_phase(
  column = "high",
  days = 365
)
phase <- candles$ht_dcphase[[nrow(candles)]]
cat(sprintf("%.0f degrees\n", phase))
} # }

## ------------------------------------------------
## Method `CycleIndicators$hilbert_transform_phasor_components()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$hilbert_transform_phasor_components(days = 365)
columns <- c(
  "datetime",
  "close",
  "inphase",
  "quadrature"
)
print(tail(candles[, columns], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
candles <- nifty$hilbert_transform_phasor_components(days = 365)
last_row <- candles[nrow(candles), ]
radians <- atan2(last_row$quadrature, last_row$inphase)
cat(sprintf("%.0f degrees\n", radians * 180 / pi))
} # }

## ------------------------------------------------
## Method `CycleIndicators$hilbert_transform_sine_wave()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$hilbert_transform_sine_wave(days = 365)
print(tail(candles[, c("datetime", "close", "sine", "lead_sine")], 5))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$hilbert_transform_sine_wave(days = 365)
  last_row <- candles[nrow(candles), ]
  if (last_row$lead_sine > last_row$sine) {
    cat(sprintf("%s: lead sine above, cycle turning up\n", symbol))
  } else {
    cat(sprintf("%s: lead sine below, cycle turning down\n", symbol))
  }
}
} # }

## ------------------------------------------------
## Method `CycleIndicators$hilbert_transform_trend_mode()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$hilbert_transform_trend_mode(days = 365)
print(tail(candles[, c("datetime", "close", "ht_trendmode")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
candles <- nifty$hilbert_transform_trend_mode(days = 365)
trending_days <- sum(candles$ht_trendmode)
cat(sprintf("%d of %d days trending\n", trending_days, nrow(candles)))

information_technology <- Watchlist$new(
  name = "information technology",
  instruments = list(
    Equity$new(exchange = "nse", symbol = "INFY"),
    Equity$new(exchange = "nse", symbol = "TCS"),
    Equity$new(exchange = "nse", symbol = "WIPRO")
  )
)
candles <- information_technology$hilbert_transform_trend_mode(
  days = 365
)
if (candles$ht_trendmode[[nrow(candles)]] == 1) {
  cat("Trending\n")
} else {
  cat("Cycling\n")
}
} # }

## ------------------------------------------------
## Method `CycleIndicators$hilbert_transform_trend_line()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$hilbert_transform_trend_line(days = 365)
print(tail(candles[, c("datetime", "close", "ht_trendline")], 5))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$hilbert_transform_trend_line(days = 365)
  last_row <- candles[nrow(candles), ]
  ratio <- last_row$close / last_row$ht_trendline
  distance <- (ratio - 1) * 100
  cat(sprintf("%s: %.2f%%\n", symbol, distance))
}
} # }
```
