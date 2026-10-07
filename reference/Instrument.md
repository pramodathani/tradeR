# One instrument in UBI's unified instrument universe

An instrument is looked up once, when it is created, through UBI's
`/api/instruments/details` route, and keeps only its identity, lot size
and tick size. Every candle, quote and price after that is read from UBI
at the moment it is asked for, with no caching here, because UBI runs on
the same machine and caches in its own Redis.

`Instrument` inherits every analysis class, from `PriceStatistics` to
`PerformanceMeasures`, so each of the analysis methods is available on
every instrument and fetches its own candles through `prices()`.

Code normally creates one of the family classes, such as `Equity` or
`EquityIndexOption`, rather than this class, because the family class
asks only for the fields that identify one of its own contracts.

The examples below start with a short tour of the class, then show its
properties and the functions on its class generator, in this order:

- For `Instrument$shared_unified_broker_interface()`, show that every
  instrument built without a client of its own shares the one client,
  and ask it whether the session is connected.

- For `Instrument$shared_unified_broker_interface()`, send a raw request
  to a UBI route that has no method of its own, here the last price of
  Infosys, through the shared client.

- For `Instrument$shared_unified_broker_interface()`, hand the shared
  client to an instrument explicitly, as code that manages its own
  clients would.

- For `quote`, print the headline fields of the full quote for Infosys.

- For `quote`, check whether the quote is stale before trusting it,
  which UBI reports in the quote itself.

- For `last_price`, print the last traded price of Infosys.

- For `last_price`, print the last price of three indices side by side.

- For `last_price`, value a hypothetical holding of 25 Infosys shares at
  the last price.

- For `ohlc`, print the day's range of the Nifty index so far.

- For `ohlc`, say whether Infosys opened with a gap up or a gap down
  against the previous close.

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
-\>
[`MathOperators`](https://pramodathani.github.io/tradeR/reference/MathOperators.md)
-\>
[`CandlestickPatterns`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.md)
-\>
[`Signals`](https://pramodathani.github.io/tradeR/reference/Signals.md)
-\>
[`StrategyBacktests`](https://pramodathani.github.io/tradeR/reference/StrategyBacktests.md)
-\>
[`PerformanceMeasures`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.md)
-\> `Instrument`

## Public fields

- `instrument_id`:

  The character UUID UBI computes for the instrument, the same at every
  broker.

- `exchange`:

  The character lower-case exchange, such as `"nse"` or `"mcx"`.

- `segment`:

  The character exchange-prefixed segment, such as `"nse_equities"`.

- `shape`:

  The character shape of the segment: `"security"`, `"future"` or
  `"option"`.

- `symbol`:

  The character symbol of a security, or `NULL` for a future or option.

- `underlying_symbol`:

  The character symbol of a future's or option's underlying, or `NULL`
  for a security.

- `expiry_date`:

  The `Date` a future or option expires, or `NULL` for a security.

- `strike_price`:

  The numeric strike price of an option, or `NULL` for anything else.

- `option_type`:

  The character option type, `"CE"` or `"PE"`, or `NULL` for anything
  else.

- `underlying_instrument_id`:

  The character UUID UBI gives for the instrument a future or option is
  written on, or `NULL` for a security or when UBI does not say.

- `mapping_date`:

  The `Date` of the UBI mapping the details were read from.

- `first_seen_date`:

  The `Date` UBI first saw the instrument, or `NULL` when unknown.

- `last_seen_date`:

  The `Date` UBI last saw the instrument, or `NULL` when unknown.

- `lot_size`:

  The integer number of underlying units in one lot, or `NULL` when
  UBI's brokers do not agree.

- `tick_size`:

  The numeric smallest price step in rupees, or `NULL` when UBI's
  brokers do not agree.

- `carried_by`:

  A list of named lists, one per broker carrying the instrument, each
  with that broker's own token, order symbol, lot size and tick size.

## Active bindings

- `quote`:

  The instrument's full unified quote as a named list, read from UBI on
  every access.

- `last_price`:

  The instrument's last traded price as a numeric value, or `NULL` when
  UBI has none, read from UBI on every access.

- `ohlc`:

  The day's open, high and low with the last and previous close prices,
  as a named list read from UBI on every access.

## Methods

### Public methods

- [`Instrument$new()`](#method-Instrument-initialize)

- [`Instrument$format()`](#method-Instrument-format)

- [`Instrument$print()`](#method-Instrument-print)

- [`Instrument$equals()`](#method-Instrument-equals)

- [`Instrument$prices()`](#method-Instrument-prices)

- [`Instrument$ticks()`](#method-Instrument-ticks)

- [`Instrument$clone()`](#method-Instrument-clone)

Inherited methods

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
- [`MathOperators$add()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-add)
- [`MathOperators$divide()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-divide)
- [`MathOperators$maximum()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-maximum)
- [`MathOperators$maximum_index()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-maximum_index)
- [`MathOperators$minimum()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-minimum)
- [`MathOperators$minimum_index()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-minimum_index)
- [`MathOperators$minimum_maximum()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-minimum_maximum)
- [`MathOperators$minimum_maximum_index()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-minimum_maximum_index)
- [`MathOperators$multiply()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-multiply)
- [`MathOperators$subtract()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-subtract)
- [`CandlestickPatterns$candle_abandoned_baby()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_abandoned_baby)
- [`CandlestickPatterns$candle_advance_block()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_advance_block)
- [`CandlestickPatterns$candle_belt_hold()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_belt_hold)
- [`CandlestickPatterns$candle_breakaway()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_breakaway)
- [`CandlestickPatterns$candle_closing_marubozu()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_closing_marubozu)
- [`CandlestickPatterns$candle_concealing_baby_swallow()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_concealing_baby_swallow)
- [`CandlestickPatterns$candle_counter_attack()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_counter_attack)
- [`CandlestickPatterns$candle_dark_cloud_cover()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_dark_cloud_cover)
- [`CandlestickPatterns$candle_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_doji)
- [`CandlestickPatterns$candle_doji_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_doji_star)
- [`CandlestickPatterns$candle_dragonfly_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_dragonfly_doji)
- [`CandlestickPatterns$candle_engulfing()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_engulfing)
- [`CandlestickPatterns$candle_evening_doji_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_evening_doji_star)
- [`CandlestickPatterns$candle_evening_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_evening_star)
- [`CandlestickPatterns$candle_gravestone_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_gravestone_doji)
- [`CandlestickPatterns$candle_hammer()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_hammer)
- [`CandlestickPatterns$candle_hanging_man()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_hanging_man)
- [`CandlestickPatterns$candle_harami()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_harami)
- [`CandlestickPatterns$candle_harami_cross()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_harami_cross)
- [`CandlestickPatterns$candle_high_wave()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_high_wave)
- [`CandlestickPatterns$candle_hikkake()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_hikkake)
- [`CandlestickPatterns$candle_homing_pigeon()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_homing_pigeon)
- [`CandlestickPatterns$candle_identical_three_crows()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_identical_three_crows)
- [`CandlestickPatterns$candle_in_neck()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_in_neck)
- [`CandlestickPatterns$candle_inverted_hammer()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_inverted_hammer)
- [`CandlestickPatterns$candle_kicking()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_kicking)
- [`CandlestickPatterns$candle_kicking_by_length()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_kicking_by_length)
- [`CandlestickPatterns$candle_ladder_bottom()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_ladder_bottom)
- [`CandlestickPatterns$candle_long_legged_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_long_legged_doji)
- [`CandlestickPatterns$candle_long_line()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_long_line)
- [`CandlestickPatterns$candle_marubozu()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_marubozu)
- [`CandlestickPatterns$candle_mat_hold()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_mat_hold)
- [`CandlestickPatterns$candle_matching_low()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_matching_low)
- [`CandlestickPatterns$candle_modified_hikkake()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_modified_hikkake)
- [`CandlestickPatterns$candle_morning_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_morning_star)
- [`CandlestickPatterns$candle_morning_star_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_morning_star_doji)
- [`CandlestickPatterns$candle_on_neck()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_on_neck)
- [`CandlestickPatterns$candle_piercing()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_piercing)
- [`CandlestickPatterns$candle_rickshaw_man()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_rickshaw_man)
- [`CandlestickPatterns$candle_rise_fall_three_methods()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_rise_fall_three_methods)
- [`CandlestickPatterns$candle_separating_lines()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_separating_lines)
- [`CandlestickPatterns$candle_shooting_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_shooting_star)
- [`CandlestickPatterns$candle_short_line()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_short_line)
- [`CandlestickPatterns$candle_side_by_side_white_lines()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_side_by_side_white_lines)
- [`CandlestickPatterns$candle_spinning_top()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_spinning_top)
- [`CandlestickPatterns$candle_stalled_pattern()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_stalled_pattern)
- [`CandlestickPatterns$candle_stick_sandwich()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_stick_sandwich)
- [`CandlestickPatterns$candle_takuri()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_takuri)
- [`CandlestickPatterns$candle_tasuki_gap()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_tasuki_gap)
- [`CandlestickPatterns$candle_three_black_crows()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_black_crows)
- [`CandlestickPatterns$candle_three_inside_up_down()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_inside_up_down)
- [`CandlestickPatterns$candle_three_line_strike()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_line_strike)
- [`CandlestickPatterns$candle_three_outside_up_down()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_outside_up_down)
- [`CandlestickPatterns$candle_three_stars_in_the_south()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_stars_in_the_south)
- [`CandlestickPatterns$candle_three_white_soldiers()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_white_soldiers)
- [`CandlestickPatterns$candle_thrusting_pattern()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_thrusting_pattern)
- [`CandlestickPatterns$candle_tristar()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_tristar)
- [`CandlestickPatterns$candle_two_crows()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_two_crows)
- [`CandlestickPatterns$candle_unique_three_river()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_unique_three_river)
- [`CandlestickPatterns$candle_up_side_down_side_gap_three_methods()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_up_side_down_side_gap_three_methods)
- [`CandlestickPatterns$candle_up_side_gap_two_crows()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_up_side_gap_two_crows)
- [`Signals$is_cross_over()`](https://pramodathani.github.io/tradeR/reference/Signals.html#method-is_cross_over)
- [`Signals$is_cross_under()`](https://pramodathani.github.io/tradeR/reference/Signals.html#method-is_cross_under)
- [`StrategyBacktests$run_backtest()`](https://pramodathani.github.io/tradeR/reference/StrategyBacktests.html#method-run_backtest)
- [`PerformanceMeasures$alpha()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-alpha)
- [`PerformanceMeasures$annualised_return()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-annualised_return)
- [`PerformanceMeasures$annualised_volatility()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-annualised_volatility)
- [`PerformanceMeasures$benchmark_beta()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-benchmark_beta)
- [`PerformanceMeasures$calmar_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-calmar_ratio)
- [`PerformanceMeasures$cumulative_return()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-cumulative_return)
- [`PerformanceMeasures$down_capture_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-down_capture_ratio)
- [`PerformanceMeasures$drawdowns()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-drawdowns)
- [`PerformanceMeasures$expected_shortfall()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-expected_shortfall)
- [`PerformanceMeasures$information_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-information_ratio)
- [`PerformanceMeasures$maximum_drawdown()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-maximum_drawdown)
- [`PerformanceMeasures$performance_summary()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-performance_summary)
- [`PerformanceMeasures$sharpe_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-sharpe_ratio)
- [`PerformanceMeasures$sortino_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-sortino_ratio)
- [`PerformanceMeasures$tracking_error()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-tracking_error)
- [`PerformanceMeasures$up_capture_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-up_capture_ratio)
- [`PerformanceMeasures$value_at_risk()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-value_at_risk)

------------------------------------------------------------------------

### `Instrument$new()`

Looks the instrument up in UBI and keeps its details.

Give either `instrument_id`, or `exchange`, `segment` and the identity
fields the segment's shape needs: `symbol` for a security,
`underlying_symbol` and `expiry_date` for a future, and all four of
`underlying_symbol`, `expiry_date`, `strike_price` and `option_type` for
an option.

#### Usage

    Instrument$new(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      unified_broker_interface = NULL,
      details = NULL
    )

#### Arguments

- `instrument_id`:

  The character UUID of the instrument, or `NULL` to look it up by
  exchange, segment and identity fields.

- `exchange`:

  The character exchange, such as `"nse"`, or `NULL` when
  `instrument_id` is given.

- `segment`:

  The character segment, bare such as `"equities"` or prefixed such as
  `"nse_equities"`, or `NULL` when `instrument_id` is given.

- `symbol`:

  The character symbol of a security, or `NULL`.

- `underlying_symbol`:

  The character symbol of a future's or option's underlying, or `NULL`.

- `expiry_date`:

  The expiry of a future or option as a `Date` or a `"YYYY-MM-DD"`
  character value, or `NULL`.

- `strike_price`:

  The numeric strike price of an option, or `NULL`.

- `option_type`:

  The character option type of an option, `"CE"` or `"PE"`, or `NULL`.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to send requests through, or `NULL` to
  share one client among all instruments.

- `details`:

  The named list UBI returned for this instrument from
  `/api/instruments/details`, such as one entry of a list request, which
  is used instead of looking the instrument up again, or `NULL` to look
  it up from the other arguments.

#### Details

Errors: signals `InstrumentError` when UBI has no instrument matching
the lookup; `BadRequestError` when the lookup is incomplete or
malformed, such as a future without an `expiry_date`; and another
`UnifiedBrokerInterfaceError` subclass for any other failure reported
by, or on the way to, UBI.

#### Returns

A new `Instrument` object.

------------------------------------------------------------------------

### `Instrument$format()`

Describes the instrument by exchange, segment and identity fields.

#### Usage

    Instrument$format(...)

#### Arguments

- `...`:

  Ignored, accepted so that
  [`format()`](https://rdrr.io/r/base/format.html) works.

#### Returns

A character value such as
`"Equity(exchange='nse', segment='nse_equities', symbol='INFY')"`.

------------------------------------------------------------------------

### `Instrument$print()`

Prints the description [`format()`](https://rdrr.io/r/base/format.html)
gives.

#### Usage

    Instrument$print(...)

#### Arguments

- `...`:

  Ignored.

#### Returns

The instrument, invisibly.

------------------------------------------------------------------------

### `Instrument$equals()`

Compares two instruments by their UBI instrument id.

#### Usage

    Instrument$equals(other)

#### Arguments

- `other`:

  The object to compare with, of any type.

#### Returns

A logical that is `TRUE` when `other` is an `Instrument` with the same
`instrument_id`, and `FALSE` otherwise.

------------------------------------------------------------------------

### `Instrument$prices()`

Fetches the instrument's candles for a range from UBI.

Give either `from_date` and `to_date`, or `days`. UBI serves any range
in one request.

The examples below, in order:

- Print the last five daily candles of Infosys.

- Work out the Nifty index's return over a fixed range of dates from its
  first and last close.

- Compare adjusted and unadjusted closes of Reliance over five years,
  where a split or bonus shows up as a price factor below 1.

#### Usage

    Instrument$prices(
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

Errors: signals `BadRequestError` when the range or interval is invalid,
such as both `days` and `from_date` given; and another
`UnifiedBrokerInterfaceError` subclass for any other failure reported
by, or on the way to, UBI.

#### Returns

A `data.frame` sorted by time, with `exchange`, `segment`, `interval`,
`datetime` in India time, `open`, `high`, `low`, `close`, `volume` and
`oi` columns, plus `price_factor` when the prices are adjusted, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- TradeableInstrument$new(
      exchange = "nse",
      segment = "equities",
      symbol = "INFY"
    )
    candles <- infosys$prices(interval = "day", days = 10)
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      "volume"
    )
    print(tail(candles[, columns], 5))

    nifty <- NonTradeableInstrument$new(
      exchange = "nse",
      segment = "equity_indices",
      symbol = "NIFTY"
    )
    candles <- nifty$prices(
      interval = "day",
      from_date = "2026-01-01",
      to_date = "2026-06-30"
    )
    first_close <- candles$close[[1]]
    last_close <- candles$close[[nrow(candles)]]
    change_percent <- (last_close - first_close) / first_close * 100
    cat(
      sprintf(
        "Nifty from %s to %s: %.2f%%",
        first_close,
        last_close,
        change_percent
      ),
      "\n"
    )

    reliance <- TradeableInstrument$new(
      exchange = "nse",
      segment = "equities",
      symbol = "RELIANCE"
    )
    adjusted <- reliance$prices(days = 1825, adjusted = TRUE)
    unadjusted <- reliance$prices(days = 1825, adjusted = FALSE)
    cat("First adjusted close:", adjusted$close[[1]], "\n")
    cat("First unadjusted close:", unadjusted$close[[1]], "\n")
    cat("Smallest price factor:", min(adjusted$price_factor), "\n")

------------------------------------------------------------------------

### `Instrument$ticks()`

Fetches every tick UBI's unified live feed recorded for the instrument
in a period.

The period includes `start` and leaves out `end`. A value without an
offset is read as India time, and a bare date means midnight at the
start of that day. A busy instrument records many ticks a second, so ask
for short periods.

The examples below, in order:

- Print the best bid and offer of Vodafone Idea for the first minute of
  a session.

- Work out the share of ticks in an hour at which the spread was a
  single tick.

#### Usage

    Instrument$ticks(start, end, adjusted = TRUE)

#### Arguments

- `start`:

  The first instant to include, as a `POSIXct` or a character value such
  as `"2026-09-29 10:00"`.

- `end`:

  The first instant to leave out, as a `POSIXct` or a character value
  such as `"2026-09-29 15:30"`.

- `adjusted`:

  A logical that is `TRUE` for prices adjusted for splits and bonuses.

#### Details

Errors: signals `BadRequestError` when the period is invalid, such as an
end that is not after the start; and another
`UnifiedBrokerInterfaceError` subclass for any other failure reported
by, or on the way to, UBI.

#### Returns

A `data.frame` sorted by time, with `exchange`, `segment`, `datetime`
(when the tick was received), `exchange_time` and `last_trade_time`, all
in India time, then `broker`, `last_price`, `last_quantity`,
`average_price`, `volume`, `buy_quantity`, `sell_quantity`, `oi` and the
order book flattened into `bid1_price` to `bid5_orders` and
`offer1_price` to `offer5_orders`, or `NULL` when no tick was recorded
in the period.

#### Examples

    vodafone_idea <- TradeableInstrument$new(
      exchange = "nse",
      segment = "equities",
      symbol = "IDEA"
    )
    ticks <- vodafone_idea$ticks(
      start = "2026-09-29 09:15",
      end = "2026-09-29 09:16"
    )
    columns <- c(
      "datetime",
      "bid1_price",
      "offer1_price"
    )
    print(head(ticks[, columns], 10))

    vodafone_idea <- TradeableInstrument$new(
      exchange = "nse",
      segment = "equities",
      symbol = "IDEA"
    )
    ticks <- vodafone_idea$ticks(
      start = "2026-09-29 10:00",
      end = "2026-09-29 11:00"
    )
    spread <- ticks$offer1_price - ticks$bid1_price
    tick_size <- as.numeric(vodafone_idea$tick_size)
    one_tick <- abs(spread - tick_size) < 1e-9
    cat(
      sprintf(
        "%s ticks, %.1f%% at one tick",
        nrow(ticks),
        mean(one_tick) * 100
      ),
      "\n"
    )

------------------------------------------------------------------------

### `Instrument$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Instrument$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)
print(infosys)
infosys$last_price
tail(infosys$prices(days = 10))

shared_client <- Instrument$shared_unified_broker_interface()
again <- Instrument$shared_unified_broker_interface()
print(identical(shared_client, again))
print(shared_client$status())

shared_client <- Instrument$shared_unified_broker_interface()
answer <- shared_client$get(
  "/api/instruments/ltp",
  params = list(
    exchange = "nse",
    segment = "equities",
    symbol = "INFY"
  )
)
print(answer[["last_price"]])

shared_client <- Instrument$shared_unified_broker_interface()
infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY",
  unified_broker_interface = shared_client
)
cat(format(infosys), infosys$last_price, "\n")

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)
quote <- infosys$quote
cat("Last price:", quote[["last_price"]], "\n")
cat("Previous close:", quote[["previous_close"]], "\n")
cat("Change percent:", quote[["change_percent"]], "\n")
cat("Volume:", quote[["volume"]], "\n")
cat("Served by:", quote[["broker"]], "from", quote[["source"]], "\n")

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)
quote <- reliance$quote
if (quote[["stale"]]) {
  cat("The quote has been stale since", quote[["stale_since"]], "\n")
} else {
  cat("The quote is fresh:", quote[["last_price"]], "\n")
}

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)
print(infosys$last_price)

symbols <- c(
  "NIFTY",
  "BANKNIFTY",
  "FINNIFTY"
)
for (symbol in symbols) {
  index <- NonTradeableInstrument$new(
    exchange = "nse",
    segment = "equity_indices",
    symbol = symbol
  )
  cat(sprintf("%s: %s", symbol, index$last_price), "\n")
}

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)
share_count <- 25
last_price <- infosys$last_price
if (is.null(last_price)) {
  cat("UBI has no last price for Infosys.", "\n")
} else {
  cat(
    sprintf(
      "%s shares are worth Rs %.2f",
      share_count,
      share_count * last_price
    ),
    "\n"
  )
}

nifty <- NonTradeableInstrument$new(
  exchange = "nse",
  segment = "equity_indices",
  symbol = "NIFTY"
)
day <- nifty$ohlc
cat("Open:", day[["ohlc"]][["open"]], "\n")
cat("High:", day[["ohlc"]][["high"]], "\n")
cat("Low:", day[["ohlc"]][["low"]], "\n")
cat("Last:", day[["last_price"]], "\n")
cat("Previous close:", day[["previous_close"]], "\n")

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)
day <- infosys$ohlc
opening_price <- day[["ohlc"]][["open"]]
previous_close <- day[["previous_close"]]
gap_percent <- (opening_price - previous_close) / previous_close * 100
if (gap_percent > 0) {
  cat(sprintf("Gap up of %.2f%%", gap_percent), "\n")
} else {
  cat(sprintf("Gap down of %.2f%%", -gap_percent), "\n")
}
} # }

## ------------------------------------------------
## Method `Instrument$prices()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)
candles <- infosys$prices(interval = "day", days = 10)
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  "volume"
)
print(tail(candles[, columns], 5))

nifty <- NonTradeableInstrument$new(
  exchange = "nse",
  segment = "equity_indices",
  symbol = "NIFTY"
)
candles <- nifty$prices(
  interval = "day",
  from_date = "2026-01-01",
  to_date = "2026-06-30"
)
first_close <- candles$close[[1]]
last_close <- candles$close[[nrow(candles)]]
change_percent <- (last_close - first_close) / first_close * 100
cat(
  sprintf(
    "Nifty from %s to %s: %.2f%%",
    first_close,
    last_close,
    change_percent
  ),
  "\n"
)

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)
adjusted <- reliance$prices(days = 1825, adjusted = TRUE)
unadjusted <- reliance$prices(days = 1825, adjusted = FALSE)
cat("First adjusted close:", adjusted$close[[1]], "\n")
cat("First unadjusted close:", unadjusted$close[[1]], "\n")
cat("Smallest price factor:", min(adjusted$price_factor), "\n")
} # }

## ------------------------------------------------
## Method `Instrument$ticks()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
vodafone_idea <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "IDEA"
)
ticks <- vodafone_idea$ticks(
  start = "2026-09-29 09:15",
  end = "2026-09-29 09:16"
)
columns <- c(
  "datetime",
  "bid1_price",
  "offer1_price"
)
print(head(ticks[, columns], 10))

vodafone_idea <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "IDEA"
)
ticks <- vodafone_idea$ticks(
  start = "2026-09-29 10:00",
  end = "2026-09-29 11:00"
)
spread <- ticks$offer1_price - ticks$bid1_price
tick_size <- as.numeric(vodafone_idea$tick_size)
one_tick <- abs(spread - tick_size) < 1e-9
cat(
  sprintf(
    "%s ticks, %.1f%% at one tick",
    nrow(ticks),
    mean(one_tick) * 100
  ),
  "\n"
)
} # }
```
