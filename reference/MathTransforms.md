# Element-by-element mathematical functions an instrument applies to one candle column

Each method fetches the instrument's candles through `prices()`, adds
one column and returns the candles. The class is a link in the chain of
analysis classes that `Instrument` inherits, and `Instrument` supplies
`prices()`.

The `talib` package has no math transforms, so each is computed with the
base R function that TA-Lib's C code calls, such as
[`acos()`](https://rdrr.io/r/base/Trig.html) for TA-Lib's `ACOS`.
TA-Lib's math transforms need no earlier candles, so every row gets a
value.

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
-\> `MathTransforms`

## Methods

### Public methods

- [`MathTransforms$arc_cosine()`](#method-MathTransforms-arc_cosine)

- [`MathTransforms$arc_sine()`](#method-MathTransforms-arc_sine)

- [`MathTransforms$arc_tangent()`](#method-MathTransforms-arc_tangent)

- [`MathTransforms$ceiling()`](#method-MathTransforms-ceiling)

- [`MathTransforms$cosine()`](#method-MathTransforms-cosine)

- [`MathTransforms$hyperbolic_cosine()`](#method-MathTransforms-hyperbolic_cosine)

- [`MathTransforms$exponential()`](#method-MathTransforms-exponential)

- [`MathTransforms$floor()`](#method-MathTransforms-floor)

- [`MathTransforms$natural_logarithm()`](#method-MathTransforms-natural_logarithm)

- [`MathTransforms$logarithm_base_10()`](#method-MathTransforms-logarithm_base_10)

- [`MathTransforms$sine()`](#method-MathTransforms-sine)

- [`MathTransforms$hyperbolic_sine()`](#method-MathTransforms-hyperbolic_sine)

- [`MathTransforms$square_root()`](#method-MathTransforms-square_root)

- [`MathTransforms$tangent()`](#method-MathTransforms-tangent)

- [`MathTransforms$hyperbolic_tangent()`](#method-MathTransforms-hyperbolic_tangent)

- [`MathTransforms$clone()`](#method-MathTransforms-clone)

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

------------------------------------------------------------------------

### `MathTransforms$arc_cosine()`

Adds the arc cosine of one candle column.

Values outside -1 to 1 have no arc cosine and give `NaN`, as in TA-Lib.

#### Usage

    MathTransforms$arc_cosine(
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

A `data.frame` of the candles with a `acos` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$arc_cosine(column = "price_factor", days = 30)
    print(tail(frame[, c("datetime", "acos")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$arc_cosine(days = 30)
    missing <- sum(is.na(frame$acos))
    print(sprintf("%d of %d values are undefined", missing, nrow(frame)))

------------------------------------------------------------------------

### `MathTransforms$arc_sine()`

Adds the arc sine of one candle column.

Values outside -1 to 1 have no arc sine and give `NaN`, as in TA-Lib.

#### Usage

    MathTransforms$arc_sine(
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

A `data.frame` of the candles with a `asin` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$arc_sine(column = "price_factor", days = 30)
    print(tail(frame[, c("datetime", "asin")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$arc_sine(days = 30)
    missing <- sum(is.na(frame$asin))
    print(sprintf("%d of %d values are undefined", missing, nrow(frame)))

------------------------------------------------------------------------

### `MathTransforms$arc_tangent()`

Adds the arc tangent of one candle column.

#### Usage

    MathTransforms$arc_tangent(
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

A `data.frame` of the candles with a `atan` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    frame <- vodafone_idea$arc_tangent(days = 30)
    print(tail(frame[, c("datetime", "atan")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$arc_tangent(column = "low", days = 30)
    print(tail(frame[, c("datetime", "atan")], 5))

------------------------------------------------------------------------

### `MathTransforms$ceiling()`

Adds the ceiling of one candle column.

#### Usage

    MathTransforms$ceiling(
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

A `data.frame` of the candles with a `ceil` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    frame <- vodafone_idea$ceiling(days = 30)
    columns <- c(
      "datetime",
      "close",
      "ceil"
    )
    print(tail(frame[, columns], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$ceiling(days = 180)
    whole <- sum(frame$ceil == frame$close)
    print(sprintf("Closed on a whole rupee on %d of %d days", whole, nrow(frame)))

------------------------------------------------------------------------

### `MathTransforms$cosine()`

Adds the cosine of one candle column.

#### Usage

    MathTransforms$cosine(
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

A `data.frame` of the candles with a `cos` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$cosine(days = 30)
    print(tail(frame[, c("datetime", "cos")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$cosine(column = "price_factor", days = 30)
    print(tail(frame[, c("datetime", "cos")], 5))

------------------------------------------------------------------------

### `MathTransforms$hyperbolic_cosine()`

Adds the hyperbolic cosine of one candle column.

#### Usage

    MathTransforms$hyperbolic_cosine(
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

A `data.frame` of the candles with a `cosh` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    frame <- vodafone_idea$hyperbolic_cosine(days = 30)
    print(tail(frame[, c("datetime", "cosh")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$hyperbolic_cosine(days = 30)
    infinite <- sum(is.infinite(frame$cosh))
    print(sprintf("%d of %d values overflowed to infinity", infinite, nrow(frame)))

------------------------------------------------------------------------

### `MathTransforms$exponential()`

Adds the exponential of one candle column.

#### Usage

    MathTransforms$exponential(
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

A `data.frame` of the candles with a `exp` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    frame <- vodafone_idea$exponential(days = 30)
    print(tail(frame[, c("datetime", "exp")], 5))

    vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    frame <- vodafone_idea$exponential(days = 30)
    error <- max(abs(log(frame$exp) - frame$close))
    print(sprintf("Largest round-trip error: %g", error))

------------------------------------------------------------------------

### `MathTransforms$floor()`

Adds the floor of one candle column.

#### Usage

    MathTransforms$floor(
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

A `data.frame` of the candles with a `floor` column added, or `NULL`
when UBI has no candles for the range.

#### Examples

    vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    frame <- vodafone_idea$floor(days = 30)
    columns <- c(
      "datetime",
      "close",
      "floor"
    )
    print(tail(frame[, columns], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$floor(days = 90)
    paise <- (frame$close - frame$floor) * 100
    print(sprintf("Average paise part of the close: %.1f", mean(paise)))

------------------------------------------------------------------------

### `MathTransforms$natural_logarithm()`

Adds the natural logarithm of one candle column.

Negative values have no logarithm and give `NaN`, as in TA-Lib.

#### Usage

    MathTransforms$natural_logarithm(
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

A `data.frame` of the candles with a `ln` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$natural_logarithm(days = 30)
    print(tail(frame[, c("datetime", "ln")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$natural_logarithm(days = 365)
    total_log_return <- sum(diff(frame$ln))
    print(sprintf("Total log return %.4f", total_log_return))
    print(sprintf("Total return %.2f%%", (exp(total_log_return) - 1) * 100))

------------------------------------------------------------------------

### `MathTransforms$logarithm_base_10()`

Adds the base 10 logarithm of one candle column.

Negative values have no logarithm and give `NaN`, as in TA-Lib.

#### Usage

    MathTransforms$logarithm_base_10(
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

A `data.frame` of the candles with a `log10` column added, or `NULL`
when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$logarithm_base_10(days = 30)
    print(tail(frame[, c("datetime", "log10")], 5))

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      frame <- share$logarithm_base_10(days = 10)
      digits <- floor(frame$log10[[nrow(frame)]]) + 1
      print(sprintf("%s: %d digits", symbol, as.integer(digits)))
    }

------------------------------------------------------------------------

### `MathTransforms$sine()`

Adds the sine of one candle column.

#### Usage

    MathTransforms$sine(
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

A `data.frame` of the candles with a `sin` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$sine(days = 30)
    print(tail(frame[, c("datetime", "sin")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$sine(column = "price_factor", days = 30)
    print(tail(frame[, c("datetime", "sin")], 5))

------------------------------------------------------------------------

### `MathTransforms$hyperbolic_sine()`

Adds the hyperbolic sine of one candle column.

#### Usage

    MathTransforms$hyperbolic_sine(
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

A `data.frame` of the candles with a `sinh` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    frame <- vodafone_idea$hyperbolic_sine(days = 30)
    print(tail(frame[, c("datetime", "sinh")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$hyperbolic_sine(column = "price_factor", days = 30)
    print(tail(frame[, c("datetime", "sinh")], 5))

------------------------------------------------------------------------

### `MathTransforms$square_root()`

Adds the square root of one candle column.

Negative values have no square root and give `NaN`, as in TA-Lib.

#### Usage

    MathTransforms$square_root(
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

A `data.frame` of the candles with a `sqrt` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$square_root(days = 30)
    print(tail(frame[, c("datetime", "sqrt")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$square_root(
      column = "high",
      from_date = "2026-09-21",
      to_date = "2026-09-25"
    )
    print(frame[, c("datetime", "sqrt")])

------------------------------------------------------------------------

### `MathTransforms$tangent()`

Adds the tangent of one candle column.

#### Usage

    MathTransforms$tangent(
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

A `data.frame` of the candles with a `tan` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$tangent(days = 30)
    print(tail(frame[, c("datetime", "tan")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    tangent_frame <- infosys$tangent(days = 30)
    sine_frame <- infosys$sine(days = 30)
    cosine_frame <- infosys$cosine(days = 30)
    tangent <- tangent_frame$tan[[nrow(tangent_frame)]]
    sine <- sine_frame$sin[[nrow(sine_frame)]]
    cosine <- cosine_frame$cos[[nrow(cosine_frame)]]
    print(sprintf("tan %.6f, sin / cos %.6f", tangent, sine / cosine))

------------------------------------------------------------------------

### `MathTransforms$hyperbolic_tangent()`

Adds the hyperbolic tangent of one candle column.

#### Usage

    MathTransforms$hyperbolic_tangent(
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

A `data.frame` of the candles with a `tanh` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    frame <- vodafone_idea$hyperbolic_tangent(days = 30)
    print(tail(frame[, c("datetime", "tanh")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$hyperbolic_tangent(
      column = "price_factor",
      days = 30
    )
    print(tail(frame[, c("datetime", "tanh")], 5))

------------------------------------------------------------------------

### `MathTransforms$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MathTransforms$clone(deep = FALSE)

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
frame <- infosys$natural_logarithm(days = 365)
} # }

## ------------------------------------------------
## Method `MathTransforms$arc_cosine()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$arc_cosine(column = "price_factor", days = 30)
print(tail(frame[, c("datetime", "acos")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$arc_cosine(days = 30)
missing <- sum(is.na(frame$acos))
print(sprintf("%d of %d values are undefined", missing, nrow(frame)))
} # }

## ------------------------------------------------
## Method `MathTransforms$arc_sine()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$arc_sine(column = "price_factor", days = 30)
print(tail(frame[, c("datetime", "asin")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$arc_sine(days = 30)
missing <- sum(is.na(frame$asin))
print(sprintf("%d of %d values are undefined", missing, nrow(frame)))
} # }

## ------------------------------------------------
## Method `MathTransforms$arc_tangent()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
frame <- vodafone_idea$arc_tangent(days = 30)
print(tail(frame[, c("datetime", "atan")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$arc_tangent(column = "low", days = 30)
print(tail(frame[, c("datetime", "atan")], 5))
} # }

## ------------------------------------------------
## Method `MathTransforms$ceiling()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
frame <- vodafone_idea$ceiling(days = 30)
columns <- c(
  "datetime",
  "close",
  "ceil"
)
print(tail(frame[, columns], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$ceiling(days = 180)
whole <- sum(frame$ceil == frame$close)
print(sprintf("Closed on a whole rupee on %d of %d days", whole, nrow(frame)))
} # }

## ------------------------------------------------
## Method `MathTransforms$cosine()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$cosine(days = 30)
print(tail(frame[, c("datetime", "cos")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$cosine(column = "price_factor", days = 30)
print(tail(frame[, c("datetime", "cos")], 5))
} # }

## ------------------------------------------------
## Method `MathTransforms$hyperbolic_cosine()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
frame <- vodafone_idea$hyperbolic_cosine(days = 30)
print(tail(frame[, c("datetime", "cosh")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$hyperbolic_cosine(days = 30)
infinite <- sum(is.infinite(frame$cosh))
print(sprintf("%d of %d values overflowed to infinity", infinite, nrow(frame)))
} # }

## ------------------------------------------------
## Method `MathTransforms$exponential()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
frame <- vodafone_idea$exponential(days = 30)
print(tail(frame[, c("datetime", "exp")], 5))

vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
frame <- vodafone_idea$exponential(days = 30)
error <- max(abs(log(frame$exp) - frame$close))
print(sprintf("Largest round-trip error: %g", error))
} # }

## ------------------------------------------------
## Method `MathTransforms$floor()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
frame <- vodafone_idea$floor(days = 30)
columns <- c(
  "datetime",
  "close",
  "floor"
)
print(tail(frame[, columns], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$floor(days = 90)
paise <- (frame$close - frame$floor) * 100
print(sprintf("Average paise part of the close: %.1f", mean(paise)))
} # }

## ------------------------------------------------
## Method `MathTransforms$natural_logarithm()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$natural_logarithm(days = 30)
print(tail(frame[, c("datetime", "ln")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$natural_logarithm(days = 365)
total_log_return <- sum(diff(frame$ln))
print(sprintf("Total log return %.4f", total_log_return))
print(sprintf("Total return %.2f%%", (exp(total_log_return) - 1) * 100))
} # }

## ------------------------------------------------
## Method `MathTransforms$logarithm_base_10()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$logarithm_base_10(days = 30)
print(tail(frame[, c("datetime", "log10")], 5))

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  frame <- share$logarithm_base_10(days = 10)
  digits <- floor(frame$log10[[nrow(frame)]]) + 1
  print(sprintf("%s: %d digits", symbol, as.integer(digits)))
}
} # }

## ------------------------------------------------
## Method `MathTransforms$sine()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$sine(days = 30)
print(tail(frame[, c("datetime", "sin")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$sine(column = "price_factor", days = 30)
print(tail(frame[, c("datetime", "sin")], 5))
} # }

## ------------------------------------------------
## Method `MathTransforms$hyperbolic_sine()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
frame <- vodafone_idea$hyperbolic_sine(days = 30)
print(tail(frame[, c("datetime", "sinh")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$hyperbolic_sine(column = "price_factor", days = 30)
print(tail(frame[, c("datetime", "sinh")], 5))
} # }

## ------------------------------------------------
## Method `MathTransforms$square_root()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$square_root(days = 30)
print(tail(frame[, c("datetime", "sqrt")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$square_root(
  column = "high",
  from_date = "2026-09-21",
  to_date = "2026-09-25"
)
print(frame[, c("datetime", "sqrt")])
} # }

## ------------------------------------------------
## Method `MathTransforms$tangent()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$tangent(days = 30)
print(tail(frame[, c("datetime", "tan")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
tangent_frame <- infosys$tangent(days = 30)
sine_frame <- infosys$sine(days = 30)
cosine_frame <- infosys$cosine(days = 30)
tangent <- tangent_frame$tan[[nrow(tangent_frame)]]
sine <- sine_frame$sin[[nrow(sine_frame)]]
cosine <- cosine_frame$cos[[nrow(cosine_frame)]]
print(sprintf("tan %.6f, sin / cos %.6f", tangent, sine / cosine))
} # }

## ------------------------------------------------
## Method `MathTransforms$hyperbolic_tangent()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
frame <- vodafone_idea$hyperbolic_tangent(days = 30)
print(tail(frame[, c("datetime", "tanh")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$hyperbolic_tangent(
  column = "price_factor",
  days = 30
)
print(tail(frame[, c("datetime", "tanh")], 5))
} # }
```
