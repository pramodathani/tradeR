# Arithmetic and rolling extremes an instrument calculates from its candle columns

Each method fetches the instrument's candles through `prices()`, adds
one or more columns and returns the candles. The class is a link in the
chain of analysis classes that `Instrument` inherits, and `Instrument`
supplies `prices()`.

The `talib` package has no arithmetic operators, no `MINMAX` and no
index functions, and its `MAX` and `MIN` treat a missing value inside
the data differently from Python's `talib`, so this class computes all
of them in R. The arithmetic uses R's operators, which match TA-Lib's C
code, and the rolling extremes and their positions follow TA-Lib 0.6.4's
loops step by step.

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
-\>
[`CycleIndicators`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.md)
-\>
[`PriceTransforms`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.md)
-\>
[`VolatilityIndicators`](https://pramodathani.github.io/tradeR/reference/VolatilityIndicators.md)
-\>
[`StatisticFunctions`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.md)
-\>
[`MathTransforms`](https://pramodathani.github.io/tradeR/reference/MathTransforms.md)
-\> `MathOperators`

## Methods

### Public methods

- [`MathOperators$add()`](#method-MathOperators-add)

- [`MathOperators$subtract()`](#method-MathOperators-subtract)

- [`MathOperators$multiply()`](#method-MathOperators-multiply)

- [`MathOperators$divide()`](#method-MathOperators-divide)

- [`MathOperators$maximum()`](#method-MathOperators-maximum)

- [`MathOperators$minimum()`](#method-MathOperators-minimum)

- [`MathOperators$maximum_index()`](#method-MathOperators-maximum_index)

- [`MathOperators$minimum_index()`](#method-MathOperators-minimum_index)

- [`MathOperators$minimum_maximum()`](#method-MathOperators-minimum_maximum)

- [`MathOperators$minimum_maximum_index()`](#method-MathOperators-minimum_maximum_index)

- [`MathOperators$clone()`](#method-MathOperators-clone)

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
- [`CycleIndicators$hilbert_transform_dominant_cycle_period()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_dominant_cycle_period)
- [`CycleIndicators$hilbert_transform_dominant_cycle_phase()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_dominant_cycle_phase)
- [`CycleIndicators$hilbert_transform_phasor_components()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_phasor_components)
- [`CycleIndicators$hilbert_transform_sine_wave()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_sine_wave)
- [`CycleIndicators$hilbert_transform_trend_line()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_trend_line)
- [`CycleIndicators$hilbert_transform_trend_mode()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_trend_mode)
- [`PriceTransforms$average_price()`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.html#method-average_price)
- [`PriceTransforms$median_price()`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.html#method-median_price)
- [`PriceTransforms$typical_price()`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.html#method-typical_price)
- [`PriceTransforms$weighted_close()`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.html#method-weighted_close)
- [`VolatilityIndicators$average_true_range()`](https://pramodathani.github.io/tradeR/reference/VolatilityIndicators.html#method-average_true_range)
- [`VolatilityIndicators$normalized_average_true_range()`](https://pramodathani.github.io/tradeR/reference/VolatilityIndicators.html#method-normalized_average_true_range)
- [`VolatilityIndicators$true_range()`](https://pramodathani.github.io/tradeR/reference/VolatilityIndicators.html#method-true_range)
- [`StatisticFunctions$beta()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-beta)
- [`StatisticFunctions$correlation_coefficient()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-correlation_coefficient)
- [`StatisticFunctions$linear_regression()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-linear_regression)
- [`StatisticFunctions$linear_regression_angle()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-linear_regression_angle)
- [`StatisticFunctions$linear_regression_intercept()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-linear_regression_intercept)
- [`StatisticFunctions$linear_regression_slope()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-linear_regression_slope)
- [`StatisticFunctions$standard_deviation()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-standard_deviation)
- [`StatisticFunctions$variance()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-variance)
- [`MathTransforms$arc_cosine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-arc_cosine)
- [`MathTransforms$arc_sine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-arc_sine)
- [`MathTransforms$arc_tangent()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-arc_tangent)
- [`MathTransforms$ceiling()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-ceiling)
- [`MathTransforms$cosine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-cosine)
- [`MathTransforms$exponential()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-exponential)
- [`MathTransforms$floor()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-floor)
- [`MathTransforms$hyperbolic_cosine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-hyperbolic_cosine)
- [`MathTransforms$hyperbolic_sine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-hyperbolic_sine)
- [`MathTransforms$hyperbolic_tangent()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-hyperbolic_tangent)
- [`MathTransforms$logarithm_base_10()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-logarithm_base_10)
- [`MathTransforms$natural_logarithm()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-natural_logarithm)
- [`MathTransforms$sine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-sine)
- [`MathTransforms$square_root()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-square_root)
- [`MathTransforms$tangent()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-tangent)

------------------------------------------------------------------------

### `MathOperators$add()`

Adds the sum of two candle columns.

#### Usage

    MathOperators$add(
      first_column = "high",
      second_column = "low",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `first_column`:

  The character name of the first candle column.

- `second_column`:

  The character name of the second candle column.

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

A `data.frame` of the candles with a `sum` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$add(days = 30)
    midpoint <- frame$sum / 2
    print(tail(midpoint, 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$add(
      first_column = "open",
      second_column = "close",
      days = 30
    )
    print(tail(frame[, c("datetime", "sum")], 5))

------------------------------------------------------------------------

### `MathOperators$subtract()`

Adds the second candle column subtracted from the first.

#### Usage

    MathOperators$subtract(
      first_column = "high",
      second_column = "low",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `first_column`:

  The character name of the first candle column.

- `second_column`:

  The character name of the second candle column.

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

A `data.frame` of the candles with a `difference` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$subtract(days = 30)
    print(tail(frame[, c("datetime", "difference")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$subtract(
      first_column = "close",
      second_column = "open",
      days = 90
    )
    up_days <- sum(frame$difference > 0)
    print(sprintf("Closed above its open on %d of %d days", up_days, nrow(frame)))

------------------------------------------------------------------------

### `MathOperators$multiply()`

Adds the product of two candle columns.

#### Usage

    MathOperators$multiply(
      first_column = "high",
      second_column = "low",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `first_column`:

  The character name of the first candle column.

- `second_column`:

  The character name of the second candle column.

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

A `data.frame` of the candles with a `product` column added, or `NULL`
when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$multiply(days = 30)
    print(tail(frame[, c("datetime", "product")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$multiply(
      first_column = "close",
      second_column = "volume",
      days = 30
    )
    crores <- round(frame$product / 10000000, 1)
    print(tail(data.frame(datetime = frame$datetime, crores = crores), 5))

------------------------------------------------------------------------

### `MathOperators$divide()`

Adds the first candle column divided by the second.

#### Usage

    MathOperators$divide(
      first_column = "high",
      second_column = "low",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `first_column`:

  The character name of the first candle column.

- `second_column`:

  The character name of the second candle column.

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

A `data.frame` of the candles with a `quotient` column added, or `NULL`
when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$divide(days = 30)
    range_percent <- (frame$quotient - 1) * 100
    print(tail(round(range_percent, 2), 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$divide(
      first_column = "close",
      second_column = "open",
      days = 30
    )
    print(tail(frame[, c("datetime", "quotient")], 5))

------------------------------------------------------------------------

### `MathOperators$maximum()`

Adds the highest value of one candle column over each window.

#### Usage

    MathOperators$maximum(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `window`:

  The integer number of candles in each calculation window.

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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with a `max` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$maximum(window = 20, days = 90)
    print(tail(frame[, c("datetime", "max")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$maximum(column = "high", window = 50, days = 365)
    new_highs <- sum(frame$high == frame$max, na.rm = TRUE)
    print(sprintf("New 50-day highs on %d days", new_highs))

------------------------------------------------------------------------

### `MathOperators$minimum()`

Adds the lowest value of one candle column over each window.

#### Usage

    MathOperators$minimum(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `window`:

  The integer number of candles in each calculation window.

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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with a `min` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$minimum(window = 20, days = 90)
    print(tail(frame[, c("datetime", "min")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$minimum(column = "low", window = 50, days = 365)
    new_lows <- sum(frame$low == frame$min, na.rm = TRUE)
    print(sprintf("New 50-day lows on %d days", new_lows))

------------------------------------------------------------------------

### `MathOperators$maximum_index()`

Adds the row position of the highest value of one candle column over
each window.

Positions are counted from 0 for the first candle, as Python's are, so
the row in R is the position plus 1. The first `window - 1` rows, which
have no full window, get 0, as Python's `talib` gives them.

#### Usage

    MathOperators$maximum_index(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `window`:

  The integer number of candles in each calculation window.

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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with an integer `maxindex` column added,
or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$maximum_index(window = 20, days = 90)
    print(tail(frame[, c("datetime", "maxindex")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$maximum_index(window = 20, days = 90)
    position <- frame$maxindex[[nrow(frame)]]
    highest_row <- position + 1
    highest_day <- format(frame$datetime[[highest_row]], "%Y-%m-%d")
    print(paste(highest_day, frame$close[[highest_row]]))

------------------------------------------------------------------------

### `MathOperators$minimum_index()`

Adds the row position of the lowest value of one candle column over each
window.

Positions are counted from 0 for the first candle, as Python's are, so
the row in R is the position plus 1. The first `window - 1` rows, which
have no full window, get 0, as Python's `talib` gives them.

#### Usage

    MathOperators$minimum_index(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `window`:

  The integer number of candles in each calculation window.

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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with an integer `minindex` column added,
or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$minimum_index(window = 20, days = 90)
    print(tail(frame[, c("datetime", "minindex")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$minimum_index(window = 20, days = 90)
    position <- frame$minindex[[nrow(frame)]]
    print(sprintf("%d trading days ago", nrow(frame) - 1L - position))

------------------------------------------------------------------------

### `MathOperators$minimum_maximum()`

Adds the lowest and highest values of one candle column over each
window.

#### Usage

    MathOperators$minimum_maximum(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `window`:

  The integer number of candles in each calculation window.

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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with `min` and `max` columns added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$minimum_maximum(window = 20, days = 90)
    columns <- c(
      "datetime",
      "min",
      "max"
    )
    print(tail(frame[, columns], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$minimum_maximum(window = 20, days = 90)
    latest <- frame[nrow(frame), ]
    distance_from_low <- latest$close - latest$min
    width <- latest$max - latest$min
    position <- distance_from_low / width
    print(sprintf("%.0f%% of the way from the low to the high", position * 100))

------------------------------------------------------------------------

### `MathOperators$minimum_maximum_index()`

Adds the row positions of the lowest and highest values of one candle
column over each window.

Positions are counted from 0 for the first candle, as Python's are, so
the row in R is the position plus 1. The first `window - 1` rows, which
have no full window, get 0, as Python's `talib` gives them.

#### Usage

    MathOperators$minimum_maximum_index(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `column`:

  The character name of the candle column to use, such as `close`.

- `window`:

  The integer number of candles in each calculation window.

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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with integer `minindex` and `maxindex`
columns added, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$minimum_maximum_index(window = 20, days = 90)
    columns <- c(
      "datetime",
      "minindex",
      "maxindex"
    )
    print(tail(frame[, columns], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$minimum_maximum_index(window = 20, days = 90)
    low_position <- frame$minindex[[nrow(frame)]]
    high_position <- frame$maxindex[[nrow(frame)]]
    if (high_position > low_position) {
      print("The high came after the low, so the swing is upward")
    } else {
      print("The low came after the high, so the swing is downward")
    }

------------------------------------------------------------------------

### `MathOperators$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MathOperators$clone(deep = FALSE)

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
frame <- infosys$subtract(
  first_column = "high",
  second_column = "low",
  days = 30
)
} # }

## ------------------------------------------------
## Method `MathOperators$add()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$add(days = 30)
midpoint <- frame$sum / 2
print(tail(midpoint, 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$add(
  first_column = "open",
  second_column = "close",
  days = 30
)
print(tail(frame[, c("datetime", "sum")], 5))
} # }

## ------------------------------------------------
## Method `MathOperators$subtract()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$subtract(days = 30)
print(tail(frame[, c("datetime", "difference")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$subtract(
  first_column = "close",
  second_column = "open",
  days = 90
)
up_days <- sum(frame$difference > 0)
print(sprintf("Closed above its open on %d of %d days", up_days, nrow(frame)))
} # }

## ------------------------------------------------
## Method `MathOperators$multiply()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$multiply(days = 30)
print(tail(frame[, c("datetime", "product")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$multiply(
  first_column = "close",
  second_column = "volume",
  days = 30
)
crores <- round(frame$product / 10000000, 1)
print(tail(data.frame(datetime = frame$datetime, crores = crores), 5))
} # }

## ------------------------------------------------
## Method `MathOperators$divide()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$divide(days = 30)
range_percent <- (frame$quotient - 1) * 100
print(tail(round(range_percent, 2), 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$divide(
  first_column = "close",
  second_column = "open",
  days = 30
)
print(tail(frame[, c("datetime", "quotient")], 5))
} # }

## ------------------------------------------------
## Method `MathOperators$maximum()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$maximum(window = 20, days = 90)
print(tail(frame[, c("datetime", "max")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$maximum(column = "high", window = 50, days = 365)
new_highs <- sum(frame$high == frame$max, na.rm = TRUE)
print(sprintf("New 50-day highs on %d days", new_highs))
} # }

## ------------------------------------------------
## Method `MathOperators$minimum()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$minimum(window = 20, days = 90)
print(tail(frame[, c("datetime", "min")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$minimum(column = "low", window = 50, days = 365)
new_lows <- sum(frame$low == frame$min, na.rm = TRUE)
print(sprintf("New 50-day lows on %d days", new_lows))
} # }

## ------------------------------------------------
## Method `MathOperators$maximum_index()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$maximum_index(window = 20, days = 90)
print(tail(frame[, c("datetime", "maxindex")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$maximum_index(window = 20, days = 90)
position <- frame$maxindex[[nrow(frame)]]
highest_row <- position + 1
highest_day <- format(frame$datetime[[highest_row]], "%Y-%m-%d")
print(paste(highest_day, frame$close[[highest_row]]))
} # }

## ------------------------------------------------
## Method `MathOperators$minimum_index()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$minimum_index(window = 20, days = 90)
print(tail(frame[, c("datetime", "minindex")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$minimum_index(window = 20, days = 90)
position <- frame$minindex[[nrow(frame)]]
print(sprintf("%d trading days ago", nrow(frame) - 1L - position))
} # }

## ------------------------------------------------
## Method `MathOperators$minimum_maximum()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$minimum_maximum(window = 20, days = 90)
columns <- c(
  "datetime",
  "min",
  "max"
)
print(tail(frame[, columns], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$minimum_maximum(window = 20, days = 90)
latest <- frame[nrow(frame), ]
distance_from_low <- latest$close - latest$min
width <- latest$max - latest$min
position <- distance_from_low / width
print(sprintf("%.0f%% of the way from the low to the high", position * 100))
} # }

## ------------------------------------------------
## Method `MathOperators$minimum_maximum_index()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$minimum_maximum_index(window = 20, days = 90)
columns <- c(
  "datetime",
  "minindex",
  "maxindex"
)
print(tail(frame[, columns], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$minimum_maximum_index(window = 20, days = 90)
low_position <- frame$minindex[[nrow(frame)]]
high_position <- frame$maxindex[[nrow(frame)]]
if (high_position > low_position) {
  print("The high came after the low, so the swing is upward")
} else {
  print("The low came after the high, so the swing is downward")
}
} # }
```
