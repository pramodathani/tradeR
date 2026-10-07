# Rolling statistics an instrument calculates from its candles with TA-Lib

Rolling regressions, correlations and dispersion of candle columns. Each
method fetches the instrument's candles through `prices()`, adds one or
more columns and returns the candles. The class is a link in the chain
of analysis classes that `Instrument` inherits, and `Instrument`
supplies `prices()`.

Beta, standard deviation and variance come from the `talib` package. Its
R interface has no linear regression functions, and its correlation is a
newer rewrite that treats a missing value differently from Python's
`talib`, so the regression methods and the correlation follow TA-Lib
0.6.4's definitions in R, with the same empty values at the start.

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
-\> `StatisticFunctions`

## Methods

### Public methods

- [`StatisticFunctions$beta()`](#method-StatisticFunctions-beta)

- [`StatisticFunctions$correlation_coefficient()`](#method-StatisticFunctions-correlation_coefficient)

- [`StatisticFunctions$linear_regression()`](#method-StatisticFunctions-linear_regression)

- [`StatisticFunctions$linear_regression_slope()`](#method-StatisticFunctions-linear_regression_slope)

- [`StatisticFunctions$linear_regression_intercept()`](#method-StatisticFunctions-linear_regression_intercept)

- [`StatisticFunctions$linear_regression_angle()`](#method-StatisticFunctions-linear_regression_angle)

- [`StatisticFunctions$standard_deviation()`](#method-StatisticFunctions-standard_deviation)

- [`StatisticFunctions$variance()`](#method-StatisticFunctions-variance)

- [`StatisticFunctions$clone()`](#method-StatisticFunctions-clone)

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

------------------------------------------------------------------------

### `StatisticFunctions$beta()`

Adds the rolling beta of the instrument against a benchmark, such as an
index.

TA-Lib's beta works on the change from each candle to the next, so a
beta of 1 means the instrument moved in step with the benchmark. Candles
are matched by time, and a candle either side lacks is left out.

#### Usage

    StatisticFunctions$beta(
      benchmark,
      window = 14,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `benchmark`:

  The instrument to measure against, such as a `NonTradeableInstrument`
  for NIFTY, or any other object with a `prices()` method.

- `window`:

  The integer number of candles in each calculation window.

- `column`:

  The character name of the candle column to use from both, such as
  `close`.

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
request or could not be reached, and a plain error when TA-Lib rejects
`window`.

#### Returns

A `data.frame` of the matched candles with a `benchmark_<column>` column
and a `beta_<window>` column added, or `NULL` when UBI has no candles
for either instrument in the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- infosys$beta(benchmark = nifty, window = 20, days = 180)
    print(tail(frame[, c("datetime", "beta_20")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      frame <- share$beta(benchmark = nifty, window = 60, days = 365)
      latest_beta <- frame$beta_60[[nrow(frame)]]
      print(sprintf("%s: beta %.2f", symbol, latest_beta))
    }

------------------------------------------------------------------------

### `StatisticFunctions$correlation_coefficient()`

Adds the rolling Pearson correlation of the instrument's returns with a
benchmark's returns.

Returns, the fractional change from each candle to the next, are
correlated rather than price levels, because two unrelated prices that
both trend upwards would otherwise look strongly correlated. Candles are
matched by time, and a candle either side lacks is left out.

#### Usage

    StatisticFunctions$correlation_coefficient(
      benchmark,
      window = 14,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `benchmark`:

  The instrument to compare with, such as a `NonTradeableInstrument` for
  NIFTY, or any other object with a `prices()` method.

- `window`:

  The integer number of returns in each calculation window.

- `column`:

  The character name of the candle column to use from both, such as
  `close`.

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
below 1 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the matched candles with a `benchmark_<column>` column
and a `corr_<window>` column added, which lies between -1 and 1, or
`NULL` when UBI has no candles for either instrument in the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- infosys$correlation_coefficient(
      benchmark = nifty,
      window = 20,
      days = 180
    )
    print(tail(frame[, c("datetime", "corr_20")], 5))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- tcs$correlation_coefficient(
      benchmark = infosys,
      window = 30,
      days = 365
    )
    average <- mean(frame$corr_30, na.rm = TRUE)
    print(sprintf("Average correlation: %.2f", average))

------------------------------------------------------------------------

### `StatisticFunctions$linear_regression()`

Adds the end value of a rolling linear regression line through one
candle column.

#### Usage

    StatisticFunctions$linear_regression(
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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with a `lin_regr_<window>` column added,
or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$linear_regression(days = 90)
    print(tail(frame[, c("datetime", "lin_regr_14")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$linear_regression(window = 20, days = 120)
    last_row <- nrow(frame)
    gap <- frame$close[[last_row]] - frame$lin_regr_20[[last_row]]
    print(sprintf("The close is %.2f points from the regression line", gap))

------------------------------------------------------------------------

### `StatisticFunctions$linear_regression_slope()`

Adds the slope of a rolling linear regression line through one candle
column.

#### Usage

    StatisticFunctions$linear_regression_slope(
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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with a `lin_regr_slope_<window>` column
added, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$linear_regression_slope(days = 90)
    print(tail(frame[, c("datetime", "lin_regr_slope_14")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$linear_regression_slope(window = 50, days = 180)
    slope <- frame$lin_regr_slope_50[[nrow(frame)]]
    if (slope > 0) {
      print(sprintf("Rising by %.2f points a day", slope))
    } else {
      print(sprintf("Falling by %.2f points a day", -slope))
    }

------------------------------------------------------------------------

### `StatisticFunctions$linear_regression_intercept()`

Adds the intercept of a rolling linear regression line through one
candle column.

#### Usage

    StatisticFunctions$linear_regression_intercept(
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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with a `lin_regr_int_<window>` column
added, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$linear_regression_intercept(days = 90)
    print(tail(frame[, c("datetime", "lin_regr_int_14")], 5))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    intercept_frame <- infosys$linear_regression_intercept(days = 90)
    slope_frame <- infosys$linear_regression_slope(days = 90)
    line_frame <- infosys$linear_regression(days = 90)
    last_row <- nrow(line_frame)
    intercept <- intercept_frame$lin_regr_int_14[[last_row]]
    slope <- slope_frame$lin_regr_slope_14[[last_row]]
    print(sprintf("Rebuilt end value %.2f", intercept + 13 * slope))
    print(
      sprintf("linear_regression %.2f", line_frame$lin_regr_14[[last_row]])
    )

------------------------------------------------------------------------

### `StatisticFunctions$linear_regression_angle()`

Adds the angle in degrees of a rolling linear regression line through
one candle column.

#### Usage

    StatisticFunctions$linear_regression_angle(
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
request or could not be reached, and a plain error when `window` is
below 2 or above 100000, as TA-Lib does.

#### Returns

A `data.frame` of the candles with a `lin_regr_angle_<window>` column
added, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$linear_regression_angle(days = 90)
    print(tail(frame[, c("datetime", "lin_regr_angle_14")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$linear_regression_angle(window = 30, days = 120)
    angle <- frame$lin_regr_angle_30[[nrow(frame)]]
    print(sprintf("%.2f degrees", angle))

------------------------------------------------------------------------

### `StatisticFunctions$standard_deviation()`

Adds the rolling standard deviation of one candle column.

#### Usage

    StatisticFunctions$standard_deviation(
      window = 14,
      standard_deviations = 1,
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

- `standard_deviations`:

  The numeric multiple of the standard deviation to report.

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
request or could not be reached, and a plain error when TA-Lib rejects
`window`.

#### Returns

A `data.frame` of the candles with a `std_dev_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$standard_deviation(window = 20, days = 90)
    print(tail(frame[, c("datetime", "std_dev_20")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$standard_deviation(
      window = 20,
      standard_deviations = 2,
      days = 90
    )
    last_row <- nrow(frame)
    middle <- mean(frame$close[(last_row - 19):last_row])
    width <- frame$std_dev_20[[last_row]]
    print(sprintf("Upper %.2f, lower %.2f", middle + width, middle - width))

------------------------------------------------------------------------

### `StatisticFunctions$variance()`

Adds the rolling variance of one candle column.

#### Usage

    StatisticFunctions$variance(
      window = 14,
      standard_deviations = 1,
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

- `standard_deviations`:

  The numeric multiple passed to TA-Lib, which its variance calculation
  does not use.

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
request or could not be reached, and a plain error when TA-Lib rejects
`window`.

#### Returns

A `data.frame` of the candles with a `var_<window>` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    frame <- infosys$variance(window = 20, days = 90)
    print(tail(frame[, c("datetime", "var_20")], 5))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    frame <- nifty$variance(
      window = 10,
      from_date = "2026-01-01",
      to_date = "2026-06-30"
    )
    peak_row <- which.max(frame$var_10)
    peak_day <- format(frame$datetime[[peak_row]], "%Y-%m-%d")
    print(paste(peak_day, round(frame$var_10[[peak_row]], 1)))

------------------------------------------------------------------------

### `StatisticFunctions$clone()`

The objects of this class are cloneable with this method.

#### Usage

    StatisticFunctions$clone(deep = FALSE)

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
frame <- infosys$linear_regression_slope(window = 14, days = 365)
nifty <- NonTradeableInstrument$new(
  exchange = "nse",
  segment = "equity_indices",
  symbol = "NIFTY"
)
frame <- infosys$beta(nifty, window = 60, days = 730)
} # }

## ------------------------------------------------
## Method `StatisticFunctions$beta()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- infosys$beta(benchmark = nifty, window = 20, days = 180)
print(tail(frame[, c("datetime", "beta_20")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  frame <- share$beta(benchmark = nifty, window = 60, days = 365)
  latest_beta <- frame$beta_60[[nrow(frame)]]
  print(sprintf("%s: beta %.2f", symbol, latest_beta))
}
} # }

## ------------------------------------------------
## Method `StatisticFunctions$correlation_coefficient()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- infosys$correlation_coefficient(
  benchmark = nifty,
  window = 20,
  days = 180
)
print(tail(frame[, c("datetime", "corr_20")], 5))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- tcs$correlation_coefficient(
  benchmark = infosys,
  window = 30,
  days = 365
)
average <- mean(frame$corr_30, na.rm = TRUE)
print(sprintf("Average correlation: %.2f", average))
} # }

## ------------------------------------------------
## Method `StatisticFunctions$linear_regression()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$linear_regression(days = 90)
print(tail(frame[, c("datetime", "lin_regr_14")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$linear_regression(window = 20, days = 120)
last_row <- nrow(frame)
gap <- frame$close[[last_row]] - frame$lin_regr_20[[last_row]]
print(sprintf("The close is %.2f points from the regression line", gap))
} # }

## ------------------------------------------------
## Method `StatisticFunctions$linear_regression_slope()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$linear_regression_slope(days = 90)
print(tail(frame[, c("datetime", "lin_regr_slope_14")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$linear_regression_slope(window = 50, days = 180)
slope <- frame$lin_regr_slope_50[[nrow(frame)]]
if (slope > 0) {
  print(sprintf("Rising by %.2f points a day", slope))
} else {
  print(sprintf("Falling by %.2f points a day", -slope))
}
} # }

## ------------------------------------------------
## Method `StatisticFunctions$linear_regression_intercept()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$linear_regression_intercept(days = 90)
print(tail(frame[, c("datetime", "lin_regr_int_14")], 5))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
intercept_frame <- infosys$linear_regression_intercept(days = 90)
slope_frame <- infosys$linear_regression_slope(days = 90)
line_frame <- infosys$linear_regression(days = 90)
last_row <- nrow(line_frame)
intercept <- intercept_frame$lin_regr_int_14[[last_row]]
slope <- slope_frame$lin_regr_slope_14[[last_row]]
print(sprintf("Rebuilt end value %.2f", intercept + 13 * slope))
print(
  sprintf("linear_regression %.2f", line_frame$lin_regr_14[[last_row]])
)
} # }

## ------------------------------------------------
## Method `StatisticFunctions$linear_regression_angle()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$linear_regression_angle(days = 90)
print(tail(frame[, c("datetime", "lin_regr_angle_14")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$linear_regression_angle(window = 30, days = 120)
angle <- frame$lin_regr_angle_30[[nrow(frame)]]
print(sprintf("%.2f degrees", angle))
} # }

## ------------------------------------------------
## Method `StatisticFunctions$standard_deviation()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$standard_deviation(window = 20, days = 90)
print(tail(frame[, c("datetime", "std_dev_20")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$standard_deviation(
  window = 20,
  standard_deviations = 2,
  days = 90
)
last_row <- nrow(frame)
middle <- mean(frame$close[(last_row - 19):last_row])
width <- frame$std_dev_20[[last_row]]
print(sprintf("Upper %.2f, lower %.2f", middle + width, middle - width))
} # }

## ------------------------------------------------
## Method `StatisticFunctions$variance()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
frame <- infosys$variance(window = 20, days = 90)
print(tail(frame[, c("datetime", "var_20")], 5))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
frame <- nifty$variance(
  window = 10,
  from_date = "2026-01-01",
  to_date = "2026-06-30"
)
peak_row <- which.max(frame$var_10)
peak_day <- format(frame$datetime[[peak_row]], "%Y-%m-%d")
print(paste(peak_day, round(frame$var_10[[peak_row]], 1)))
} # }
```
