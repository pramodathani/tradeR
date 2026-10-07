# Return, risk and benchmark-relative measures calculated from closing prices

The last link of the chain of analysis classes, which `Instrument` and
`AssetBasket` inherit, so the same Sharpe ratio or drawdown can be asked
of one share, an index, a fund or a whole basket.

Each public method fetches candles through `prices()`, works on the
closing prices, and returns one number, or a `data.frame` for
`drawdowns()`, or a named list for `performance_summary()`.

Returns are the fractional change of the close from one candle to the
next. Annual figures scale by the number of candles in a trading year,
252 for `day` candles and the number of candles in 252 sessions of 375
minutes for an intraday interval such as `5minute`. A `risk_free_rate`
is an annual fraction, so 6.5 percent is 0.065.

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
-\> `PerformanceMeasures`

## Methods

### Public methods

- [`PerformanceMeasures$cumulative_return()`](#method-PerformanceMeasures-cumulative_return)

- [`PerformanceMeasures$annualised_return()`](#method-PerformanceMeasures-annualised_return)

- [`PerformanceMeasures$annualised_volatility()`](#method-PerformanceMeasures-annualised_volatility)

- [`PerformanceMeasures$sharpe_ratio()`](#method-PerformanceMeasures-sharpe_ratio)

- [`PerformanceMeasures$sortino_ratio()`](#method-PerformanceMeasures-sortino_ratio)

- [`PerformanceMeasures$drawdowns()`](#method-PerformanceMeasures-drawdowns)

- [`PerformanceMeasures$maximum_drawdown()`](#method-PerformanceMeasures-maximum_drawdown)

- [`PerformanceMeasures$calmar_ratio()`](#method-PerformanceMeasures-calmar_ratio)

- [`PerformanceMeasures$value_at_risk()`](#method-PerformanceMeasures-value_at_risk)

- [`PerformanceMeasures$expected_shortfall()`](#method-PerformanceMeasures-expected_shortfall)

- [`PerformanceMeasures$benchmark_beta()`](#method-PerformanceMeasures-benchmark_beta)

- [`PerformanceMeasures$alpha()`](#method-PerformanceMeasures-alpha)

- [`PerformanceMeasures$tracking_error()`](#method-PerformanceMeasures-tracking_error)

- [`PerformanceMeasures$information_ratio()`](#method-PerformanceMeasures-information_ratio)

- [`PerformanceMeasures$up_capture_ratio()`](#method-PerformanceMeasures-up_capture_ratio)

- [`PerformanceMeasures$down_capture_ratio()`](#method-PerformanceMeasures-down_capture_ratio)

- [`PerformanceMeasures$performance_summary()`](#method-PerformanceMeasures-performance_summary)

- [`PerformanceMeasures$clone()`](#method-PerformanceMeasures-clone)

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

------------------------------------------------------------------------

### `PerformanceMeasures$cumulative_return()`

Calculates the total growth of the close from the first candle to the
last.

#### Usage

    PerformanceMeasures$cumulative_return(
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

The numeric fractional growth, such as 0.12 for 12 percent, or `NULL`
when there are fewer than two candles.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    growth <- infosys$cumulative_return(days = 365)
    cat(sprintf("Infosys over one year: %.2f%%\n", growth * 100))

    symbols <- c(
      "INFY",
      "TCS",
      "RELIANCE"
    )
    returns <- numeric(0)
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      returns[[symbol]] <- share$cumulative_return(
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
    }
    for (symbol in names(sort(returns, decreasing = TRUE))) {
      cat(sprintf("%s: %.2f%%\n", symbol, returns[[symbol]] * 100))
    }

------------------------------------------------------------------------

### `PerformanceMeasures$annualised_return()`

Calculates the compound annual growth rate of the close over the range.

#### Usage

    PerformanceMeasures$annualised_return(
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

Errors: signals `ValueError` when the interval is neither `day` nor a
minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when
UBI refused the request or could not be reached.

#### Returns

The numeric annual growth rate, such as 0.15 for 15 percent a year, or
`NULL` when there are fewer than two candles or the first or last close
is not above zero.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    growth_rate <- nifty$annualised_return(days = 1825)
    cat(sprintf("Nifty over five years: %.2f%% a year\n", growth_rate * 100))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    periods <- c(
      365,
      1095,
      1825
    )
    for (period in periods) {
      growth_rate <- infosys$annualised_return(days = period)
      cat(sprintf("%d days: %.2f%% a year\n", period, growth_rate * 100))
    }

------------------------------------------------------------------------

### `PerformanceMeasures$annualised_volatility()`

Calculates the standard deviation of returns, scaled to a year.

#### Usage

    PerformanceMeasures$annualised_volatility(
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

Errors: signals `ValueError` when the interval is neither `day` nor a
minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when
UBI refused the request or could not be reached.

#### Returns

The numeric annual volatility, such as 0.22 for 22 percent, or `NULL`
when there are fewer than three candles.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    volatility <- infosys$annualised_volatility(days = 365)
    cat(sprintf("Infosys volatility: %.2f%%\n", volatility * 100))

    symbols <- c(
      "INFY",
      "TCS",
      "RELIANCE"
    )
    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    index_volatility <- nifty$annualised_volatility(days = 730)
    cat(sprintf("Nifty: %.2f%%\n", index_volatility * 100))
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      volatility <- share$annualised_volatility(days = 730)
      if (volatility > index_volatility) {
        cat(sprintf("%s: %.2f%%, more than the index\n", symbol, volatility * 100))
      } else {
        cat(sprintf("%s: %.2f%%, less than the index\n", symbol, volatility * 100))
      }
    }

------------------------------------------------------------------------

### `PerformanceMeasures$sharpe_ratio()`

Calculates the Sharpe ratio: the annual return above the risk-free rate
for each unit of annual volatility.

A ratio above 1 is usually thought good. The annual return here is the
mean return scaled to a year, which is the textbook form, rather than
the compound growth rate `annualised_return()` gives.

#### Usage

    PerformanceMeasures$sharpe_ratio(
      risk_free_rate = 0,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `risk_free_rate`:

  The numeric annual risk-free rate as a fraction, such as 0.065 for a
  6.5 percent treasury bill.

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

Errors: signals `ValueError` when the interval is neither `day` nor a
minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when
UBI refused the request or could not be reached.

#### Returns

The numeric Sharpe ratio, or `NULL` when there are fewer than three
candles or the price never moved.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    ratio <- infosys$sharpe_ratio(risk_free_rate = 0.065, days = 365)
    cat(sprintf("Sharpe ratio: %.2f\n", ratio))

    symbols <- c(
      "INFY",
      "TCS",
      "RELIANCE"
    )
    best_symbol <- NULL
    best_ratio <- NULL
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      ratio <- share$sharpe_ratio(risk_free_rate = 0.065, days = 730)
      cat(sprintf("%s: %.2f\n", symbol, ratio))
      if (is.null(best_ratio) || ratio > best_ratio) {
        best_symbol <- symbol
        best_ratio <- ratio
      }
    }
    cat(sprintf("Best Sharpe ratio: %s\n", best_symbol))

------------------------------------------------------------------------

### `PerformanceMeasures$sortino_ratio()`

Calculates the Sortino ratio, which is the Sharpe ratio with only the
falls counted as risk.

The downside deviation is the root mean square of each period's
shortfall below the risk-free rate, counting a period that beat it as
zero.

#### Usage

    PerformanceMeasures$sortino_ratio(
      risk_free_rate = 0,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `risk_free_rate`:

  The numeric annual risk-free rate as a fraction, such as 0.065.

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

Errors: signals `ValueError` when the interval is neither `day` nor a
minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when
UBI refused the request or could not be reached.

#### Returns

The numeric Sortino ratio, or `NULL` when there are fewer than three
candles or no period fell short of the risk-free rate.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    ratio <- nifty$sortino_ratio(risk_free_rate = 0.065, days = 730)
    cat(sprintf("Nifty Sortino ratio: %.2f\n", ratio))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    sortino <- infosys$sortino_ratio(risk_free_rate = 0.065, days = 365)
    sharpe <- infosys$sharpe_ratio(risk_free_rate = 0.065, days = 365)
    cat(sprintf("Sortino %.2f against Sharpe %.2f\n", sortino, sharpe))
    if (sortino > sharpe) {
      cat("The rises are larger than the falls.\n")
    } else {
      cat("The falls weigh at least as much as the rises.\n")
    }

------------------------------------------------------------------------

### `PerformanceMeasures$drawdowns()`

Calculates how far the close stood below its highest earlier close at
every candle.

#### Usage

    PerformanceMeasures$drawdowns(
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

A `data.frame` with `datetime`, `close`, `running_peak` and `drawdown`
columns, where `drawdown` is zero at a new peak and negative below one,
such as -0.1 for ten percent below, or `NULL` when there are fewer than
two candles.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    drawdown_frame <- infosys$drawdowns(days = 365)
    latest <- drawdown_frame[nrow(drawdown_frame), ]
    cat(sprintf("Close %s, peak %s\n", latest$close, latest$running_peak))
    cat(sprintf("Drawdown from the peak: %.2f%%\n", latest$drawdown * 100))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    drawdown_frame <- nifty$drawdowns(days = 1095)
    deep_days <- drawdown_frame[drawdown_frame$drawdown < -0.05, ]
    day_count <- nrow(drawdown_frame)
    cat(sprintf("%d of %d days were 5%% down.\n", nrow(deep_days), day_count))

------------------------------------------------------------------------

### `PerformanceMeasures$maximum_drawdown()`

Finds the worst fall of the close from an earlier peak in the range.

#### Usage

    PerformanceMeasures$maximum_drawdown(
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

The numeric worst drawdown as a negative fraction, such as -0.25 for a
25 percent fall, zero when the close never fell, or `NULL` when there
are fewer than two candles.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    worst_fall <- infosys$maximum_drawdown(days = 730)
    cat(sprintf("Maximum drawdown: %.2f%%\n", worst_fall * 100))

    symbols <- c(
      "INFY",
      "TCS",
      "RELIANCE"
    )
    symbols <- c(
      symbols,
      "NIFTY"
    )
    for (symbol in symbols) {
      if (symbol == "NIFTY") {
        instrument <- EquityIndex$new(
          exchange = "nse",
          symbol = symbol
        )
      } else {
        instrument <- Equity$new(exchange = "nse", symbol = symbol)
      }
      worst_fall <- instrument$maximum_drawdown(
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
      cat(sprintf("%s: %.2f%%\n", symbol, worst_fall * 100))
    }

------------------------------------------------------------------------

### `PerformanceMeasures$calmar_ratio()`

Calculates the Calmar ratio: the compound annual growth rate divided by
the size of the worst drawdown.

#### Usage

    PerformanceMeasures$calmar_ratio(
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

Errors: signals `ValueError` when the interval is neither `day` nor a
minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when
UBI refused the request or could not be reached.

#### Returns

The numeric Calmar ratio, or `NULL` when there are fewer than two
candles or the close never fell.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    ratio <- nifty$calmar_ratio(days = 1095)
    cat(sprintf("Nifty Calmar ratio: %.2f\n", ratio))

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    growth_rate <- infosys$annualised_return(days = 730)
    worst_fall <- infosys$maximum_drawdown(days = 730)
    ratio <- infosys$calmar_ratio(days = 730)
    cat(
      sprintf(
        "%.2f%% a year, worst fall %.2f%%\n",
        growth_rate * 100,
        worst_fall * 100
      )
    )
    if (is.null(ratio)) {
      cat("The close never fell, so there is no Calmar ratio.\n")
    } else {
      cat(sprintf("Calmar ratio: %.2f\n", ratio))
    }

------------------------------------------------------------------------

### `PerformanceMeasures$value_at_risk()`

Estimates the loss over one candle that is not exceeded with the given
confidence.

The `historical` method reads the loss straight from the returns in the
range. The `parametric` method assumes returns follow a normal
distribution with the range's mean and standard deviation, which
understates the rare large falls real prices have.

#### Usage

    PerformanceMeasures$value_at_risk(
      confidence = 0.95,
      method = PERFORMANCE_MEASURES_HISTORICAL_METHOD,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `confidence`:

  The numeric confidence level between 0 and 1, such as 0.95 for the
  loss exceeded on only one candle in twenty.

- `method`:

  The character method, `"historical"` or `"parametric"`.

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

Errors: signals `ValueError` when the method is neither `historical` nor
`parametric`, or confidence is not between 0 and 1;
`UnifiedBrokerInterfaceError` when UBI refused the request or could not
be reached.

#### Returns

The numeric loss as a positive fraction of the value, such as 0.021 for
2.1 percent, or `NULL` when there are fewer than three candles.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    loss <- infosys$value_at_risk(confidence = 0.95, days = 365)
    cat(sprintf("One-day value at risk: %.2f%%\n", loss * 100))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    methods <- c(
      "historical",
      "parametric"
    )
    for (method in methods) {
      loss <- nifty$value_at_risk(
        confidence = 0.99,
        method = method,
        days = 1095
      )
      cat(sprintf("%s: %.2f%%\n", method, loss * 100))
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    holding_value <- 500000
    loss <- infosys$value_at_risk(confidence = 0.95, days = 730)
    loss_in_rupees <- holding_value * loss
    cat(
      sprintf(
        "Loss under Rs %s on 19 days in 20\n",
        format(round(loss_in_rupees), big.mark = ",")
      )
    )

------------------------------------------------------------------------

### `PerformanceMeasures$expected_shortfall()`

Calculates the average loss over one candle on the candles whose loss
reached the historical value at risk.

This is also called the conditional value at risk. It answers how bad
the bad days are, where the value at risk only says where they begin.

#### Usage

    PerformanceMeasures$expected_shortfall(
      confidence = 0.95,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `confidence`:

  The numeric confidence level between 0 and 1, such as 0.95.

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

Errors: signals `ValueError` when confidence is not between 0 and 1;
`UnifiedBrokerInterfaceError` when UBI refused the request or could not
be reached.

#### Returns

The numeric average loss as a positive fraction, or `NULL` when there
are fewer than three candles.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    shortfall <- infosys$expected_shortfall(confidence = 0.95, days = 365)
    cat(sprintf("Expected shortfall: %.2f%%\n", shortfall * 100))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    loss <- nifty$value_at_risk(confidence = 0.95, days = 1095)
    shortfall <- nifty$expected_shortfall(confidence = 0.95, days = 1095)
    cat(sprintf("Bad days begin at a loss of %.2f%%\n", loss * 100))
    cat(sprintf("They average a loss of %.2f%%\n", shortfall * 100))

------------------------------------------------------------------------

### `PerformanceMeasures$benchmark_beta()`

Calculates one beta against a benchmark over the whole range.

This is the slope of the returns regressed on the benchmark's returns,
so 1.2 means the price tended to move 1.2 percent for each percent the
benchmark moved. [`beta()`](https://rdrr.io/r/base/Special.html) gives
the rolling TA-Lib version instead.

#### Usage

    PerformanceMeasures$benchmark_beta(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `benchmark`:

  The object to measure against, such as an index instrument or a
  basket, or anything else with a `prices()` method.

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

The numeric beta, or `NULL` when fewer than three candles match the
benchmark's or the benchmark never moved.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    beta <- infosys$benchmark_beta(nifty, days = 730)
    cat(sprintf("Infosys beta against the Nifty: %.2f\n", beta))

    symbols <- c(
      "INFY",
      "TCS",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      beta <- share$benchmark_beta(nifty, days = 365)
      if (beta < 1) {
        cat(sprintf("%s: beta %.2f, defensive\n", symbol, beta))
      } else {
        cat(sprintf("%s: beta %.2f, aggressive\n", symbol, beta))
      }
    }

------------------------------------------------------------------------

### `PerformanceMeasures$alpha()`

Calculates Jensen's alpha: the annual return beyond what the benchmark's
moves and the beta explain.

#### Usage

    PerformanceMeasures$alpha(
      benchmark,
      risk_free_rate = 0,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `benchmark`:

  The object to measure against, such as an index instrument or a
  basket, or anything else with a `prices()` method.

- `risk_free_rate`:

  The numeric annual risk-free rate as a fraction, such as 0.065.

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

Errors: signals `ValueError` when the interval is neither `day` nor a
minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when
UBI refused the request or could not be reached.

#### Returns

The numeric annual alpha as a fraction, such as 0.03 for three percent a
year ahead, or `NULL` when fewer than three candles match or the
benchmark never moved.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    excess <- infosys$alpha(nifty, risk_free_rate = 0.065, days = 365)
    cat(sprintf("Jensen's alpha: %.2f%% a year\n", excess * 100))

    symbols <- c(
      "INFY",
      "TCS",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      excess <- share$alpha(
        nifty,
        risk_free_rate = 0.065,
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
      cat(sprintf("%s: alpha %.2f%%\n", symbol, excess * 100))
    }

------------------------------------------------------------------------

### `PerformanceMeasures$tracking_error()`

Calculates the annual volatility of the difference between the returns
and the benchmark's.

A fund that follows an index closely has a tracking error near zero.

#### Usage

    PerformanceMeasures$tracking_error(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `benchmark`:

  The object to measure against, such as an index instrument or a
  basket, or anything else with a `prices()` method.

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

Errors: signals `ValueError` when the interval is neither `day` nor a
minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when
UBI refused the request or could not be reached.

#### Returns

The numeric annual tracking error as a fraction, or `NULL` when fewer
than three candles match the benchmark's.

#### Examples

    nifty_bees <- ExchangeTradedFund$new(
      exchange = "nse",
      symbol = "NIFTYBEES"
    )
    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    error <- nifty_bees$tracking_error(nifty, days = 365)
    cat(sprintf("Tracking error: %.2f%%\n", error * 100))

    symbols <- c(
      "INFY",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      error <- share$tracking_error(nifty, days = 730)
      cat(sprintf("%s: %.2f%%\n", symbol, error * 100))
    }

------------------------------------------------------------------------

### `PerformanceMeasures$information_ratio()`

Calculates the information ratio: the annual return above the benchmark
for each unit of tracking error.

#### Usage

    PerformanceMeasures$information_ratio(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `benchmark`:

  The object to measure against, such as an index instrument or a
  basket, or anything else with a `prices()` method.

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

Errors: signals `ValueError` when the interval is neither `day` nor a
minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when
UBI refused the request or could not be reached.

#### Returns

The numeric information ratio, or `NULL` when fewer than three candles
match the benchmark's or the returns never differed from it.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    ratio <- infosys$information_ratio(nifty, days = 730)
    cat(sprintf("Information ratio: %.2f\n", ratio))

    symbols <- c(
      "INFY",
      "TCS",
      "RELIANCE"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      ratio <- share$information_ratio(nifty, days = 365)
      if (ratio > 0.5) {
        cat(sprintf("%s: %.2f, consistently ahead\n", symbol, ratio))
      } else {
        cat(sprintf("%s: %.2f, not consistently ahead\n", symbol, ratio))
      }
    }

------------------------------------------------------------------------

### `PerformanceMeasures$up_capture_ratio()`

Calculates how much of the benchmark's rises were captured, on the
candles where the benchmark rose.

#### Usage

    PerformanceMeasures$up_capture_ratio(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `benchmark`:

  The object to measure against, such as an index instrument or a
  basket, or anything else with a `prices()` method.

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

The numeric ratio of the mean return to the benchmark's mean return on
those candles, such as 1.1 for rising ten percent more, or `NULL` when
fewer than three candles match or the benchmark never rose.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    ratio <- infosys$up_capture_ratio(nifty, days = 365)
    cat(sprintf("Up capture: %.2f\n", ratio))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    up_ratio <- tcs$up_capture_ratio(nifty, days = 730)
    down_ratio <- tcs$down_capture_ratio(nifty, days = 730)
    cat(sprintf("Up capture %.2f, down capture %.2f\n", up_ratio, down_ratio))
    if (up_ratio > down_ratio) {
      cat("TCS caught more of the rises than of the falls.\n")
    } else {
      cat("TCS caught no more of the rises than of the falls.\n")
    }

------------------------------------------------------------------------

### `PerformanceMeasures$down_capture_ratio()`

Calculates how much of the benchmark's falls were suffered, on the
candles where the benchmark fell.

#### Usage

    PerformanceMeasures$down_capture_ratio(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `benchmark`:

  The object to measure against, such as an index instrument or a
  basket, or anything else with a `prices()` method.

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

The numeric ratio of the mean return to the benchmark's mean return on
those candles, where below 1 means falling less than the benchmark, or
`NULL` when fewer than three candles match or the benchmark never fell.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    ratio <- infosys$down_capture_ratio(nifty, days = 365)
    cat(sprintf("Down capture: %.2f\n", ratio))

    symbols <- c(
      "INFY",
      "TCS",
      "RELIANCE"
    )
    safest_symbol <- NULL
    lowest_ratio <- NULL
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      ratio <- share$down_capture_ratio(
        nifty,
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
      cat(sprintf("%s: %.2f\n", symbol, ratio))
      if (is.null(lowest_ratio) || ratio < lowest_ratio) {
        safest_symbol <- symbol
        lowest_ratio <- ratio
      }
    }
    cat(sprintf("Fell least with the index: %s\n", safest_symbol))

------------------------------------------------------------------------

### `PerformanceMeasures$performance_summary()`

Calculates every measure in this class from one fetch of the candles.

#### Usage

    PerformanceMeasures$performance_summary(
      benchmark = NULL,
      risk_free_rate = 0,
      confidence = 0.95,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `benchmark`:

  The object to measure against, such as an index instrument or a
  basket, or `NULL` to leave out the benchmark measures.

- `risk_free_rate`:

  The numeric annual risk-free rate as a fraction, such as 0.065.

- `confidence`:

  The numeric confidence level for the value at risk and expected
  shortfall, such as 0.95.

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

Errors: signals `ValueError` when the interval is neither `day` nor a
minute interval such as `5minute`, or confidence is not between 0 and 1;
`UnifiedBrokerInterfaceError` when UBI refused the request or could not
be reached.

#### Returns

A named list from `cumulative_return` to `expected_shortfall` and, when
a benchmark is given, `benchmark_beta` to `down_capture_ratio`, where a
measure that cannot be calculated is `NULL`; or `NULL` when there are
fewer than two candles.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    summary <- infosys$performance_summary(
      risk_free_rate = 0.065,
      days = 365
    )
    str(summary)

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    summary <- infosys$performance_summary(
      benchmark = nifty,
      risk_free_rate = 0.065,
      confidence = 0.99,
      days = 730
    )
    str(summary)

    symbols <- c(
      "INFY",
      "TCS",
      "RELIANCE"
    )
    measures <- c(
      "annualised_return",
      "sharpe_ratio",
      "maximum_drawdown",
      "benchmark_beta"
    )
    table <- data.frame(row.names = measures)
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      summary <- share$performance_summary(
        benchmark = nifty,
        risk_free_rate = 0.065,
        days = 365
      )
      column <- numeric(0)
      for (measure in measures) {
        value <- summary[[measure]]
        if (is.null(value)) {
          value <- NA
        }
        column[[measure]] <- value
      }
      table[[symbol]] <- column
    }
    print(table)

------------------------------------------------------------------------

### `PerformanceMeasures$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PerformanceMeasures$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY 50")
ratio <- infosys$sharpe_ratio(risk_free_rate = 0.065, days = 365)
worst <- infosys$maximum_drawdown(days = 730)
summary <- infosys$performance_summary(
  benchmark = nifty,
  risk_free_rate = 0.065,
  days = 365
)
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$cumulative_return()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
growth <- infosys$cumulative_return(days = 365)
cat(sprintf("Infosys over one year: %.2f%%\n", growth * 100))

symbols <- c(
  "INFY",
  "TCS",
  "RELIANCE"
)
returns <- numeric(0)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  returns[[symbol]] <- share$cumulative_return(
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
}
for (symbol in names(sort(returns, decreasing = TRUE))) {
  cat(sprintf("%s: %.2f%%\n", symbol, returns[[symbol]] * 100))
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$annualised_return()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
growth_rate <- nifty$annualised_return(days = 1825)
cat(sprintf("Nifty over five years: %.2f%% a year\n", growth_rate * 100))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
periods <- c(
  365,
  1095,
  1825
)
for (period in periods) {
  growth_rate <- infosys$annualised_return(days = period)
  cat(sprintf("%d days: %.2f%% a year\n", period, growth_rate * 100))
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$annualised_volatility()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
volatility <- infosys$annualised_volatility(days = 365)
cat(sprintf("Infosys volatility: %.2f%%\n", volatility * 100))

symbols <- c(
  "INFY",
  "TCS",
  "RELIANCE"
)
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
index_volatility <- nifty$annualised_volatility(days = 730)
cat(sprintf("Nifty: %.2f%%\n", index_volatility * 100))
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  volatility <- share$annualised_volatility(days = 730)
  if (volatility > index_volatility) {
    cat(sprintf("%s: %.2f%%, more than the index\n", symbol, volatility * 100))
  } else {
    cat(sprintf("%s: %.2f%%, less than the index\n", symbol, volatility * 100))
  }
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$sharpe_ratio()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
ratio <- infosys$sharpe_ratio(risk_free_rate = 0.065, days = 365)
cat(sprintf("Sharpe ratio: %.2f\n", ratio))

symbols <- c(
  "INFY",
  "TCS",
  "RELIANCE"
)
best_symbol <- NULL
best_ratio <- NULL
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  ratio <- share$sharpe_ratio(risk_free_rate = 0.065, days = 730)
  cat(sprintf("%s: %.2f\n", symbol, ratio))
  if (is.null(best_ratio) || ratio > best_ratio) {
    best_symbol <- symbol
    best_ratio <- ratio
  }
}
cat(sprintf("Best Sharpe ratio: %s\n", best_symbol))
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$sortino_ratio()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
ratio <- nifty$sortino_ratio(risk_free_rate = 0.065, days = 730)
cat(sprintf("Nifty Sortino ratio: %.2f\n", ratio))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
sortino <- infosys$sortino_ratio(risk_free_rate = 0.065, days = 365)
sharpe <- infosys$sharpe_ratio(risk_free_rate = 0.065, days = 365)
cat(sprintf("Sortino %.2f against Sharpe %.2f\n", sortino, sharpe))
if (sortino > sharpe) {
  cat("The rises are larger than the falls.\n")
} else {
  cat("The falls weigh at least as much as the rises.\n")
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$drawdowns()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
drawdown_frame <- infosys$drawdowns(days = 365)
latest <- drawdown_frame[nrow(drawdown_frame), ]
cat(sprintf("Close %s, peak %s\n", latest$close, latest$running_peak))
cat(sprintf("Drawdown from the peak: %.2f%%\n", latest$drawdown * 100))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
drawdown_frame <- nifty$drawdowns(days = 1095)
deep_days <- drawdown_frame[drawdown_frame$drawdown < -0.05, ]
day_count <- nrow(drawdown_frame)
cat(sprintf("%d of %d days were 5%% down.\n", nrow(deep_days), day_count))
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$maximum_drawdown()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
worst_fall <- infosys$maximum_drawdown(days = 730)
cat(sprintf("Maximum drawdown: %.2f%%\n", worst_fall * 100))

symbols <- c(
  "INFY",
  "TCS",
  "RELIANCE"
)
symbols <- c(
  symbols,
  "NIFTY"
)
for (symbol in symbols) {
  if (symbol == "NIFTY") {
    instrument <- EquityIndex$new(
      exchange = "nse",
      symbol = symbol
    )
  } else {
    instrument <- Equity$new(exchange = "nse", symbol = symbol)
  }
  worst_fall <- instrument$maximum_drawdown(
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
  cat(sprintf("%s: %.2f%%\n", symbol, worst_fall * 100))
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$calmar_ratio()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
ratio <- nifty$calmar_ratio(days = 1095)
cat(sprintf("Nifty Calmar ratio: %.2f\n", ratio))

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
growth_rate <- infosys$annualised_return(days = 730)
worst_fall <- infosys$maximum_drawdown(days = 730)
ratio <- infosys$calmar_ratio(days = 730)
cat(
  sprintf(
    "%.2f%% a year, worst fall %.2f%%\n",
    growth_rate * 100,
    worst_fall * 100
  )
)
if (is.null(ratio)) {
  cat("The close never fell, so there is no Calmar ratio.\n")
} else {
  cat(sprintf("Calmar ratio: %.2f\n", ratio))
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$value_at_risk()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
loss <- infosys$value_at_risk(confidence = 0.95, days = 365)
cat(sprintf("One-day value at risk: %.2f%%\n", loss * 100))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
methods <- c(
  "historical",
  "parametric"
)
for (method in methods) {
  loss <- nifty$value_at_risk(
    confidence = 0.99,
    method = method,
    days = 1095
  )
  cat(sprintf("%s: %.2f%%\n", method, loss * 100))
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
holding_value <- 500000
loss <- infosys$value_at_risk(confidence = 0.95, days = 730)
loss_in_rupees <- holding_value * loss
cat(
  sprintf(
    "Loss under Rs %s on 19 days in 20\n",
    format(round(loss_in_rupees), big.mark = ",")
  )
)
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$expected_shortfall()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
shortfall <- infosys$expected_shortfall(confidence = 0.95, days = 365)
cat(sprintf("Expected shortfall: %.2f%%\n", shortfall * 100))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
loss <- nifty$value_at_risk(confidence = 0.95, days = 1095)
shortfall <- nifty$expected_shortfall(confidence = 0.95, days = 1095)
cat(sprintf("Bad days begin at a loss of %.2f%%\n", loss * 100))
cat(sprintf("They average a loss of %.2f%%\n", shortfall * 100))
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$benchmark_beta()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
beta <- infosys$benchmark_beta(nifty, days = 730)
cat(sprintf("Infosys beta against the Nifty: %.2f\n", beta))

symbols <- c(
  "INFY",
  "TCS",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  beta <- share$benchmark_beta(nifty, days = 365)
  if (beta < 1) {
    cat(sprintf("%s: beta %.2f, defensive\n", symbol, beta))
  } else {
    cat(sprintf("%s: beta %.2f, aggressive\n", symbol, beta))
  }
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$alpha()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
excess <- infosys$alpha(nifty, risk_free_rate = 0.065, days = 365)
cat(sprintf("Jensen's alpha: %.2f%% a year\n", excess * 100))

symbols <- c(
  "INFY",
  "TCS",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  excess <- share$alpha(
    nifty,
    risk_free_rate = 0.065,
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
  cat(sprintf("%s: alpha %.2f%%\n", symbol, excess * 100))
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$tracking_error()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty_bees <- ExchangeTradedFund$new(
  exchange = "nse",
  symbol = "NIFTYBEES"
)
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
error <- nifty_bees$tracking_error(nifty, days = 365)
cat(sprintf("Tracking error: %.2f%%\n", error * 100))

symbols <- c(
  "INFY",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  error <- share$tracking_error(nifty, days = 730)
  cat(sprintf("%s: %.2f%%\n", symbol, error * 100))
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$information_ratio()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
ratio <- infosys$information_ratio(nifty, days = 730)
cat(sprintf("Information ratio: %.2f\n", ratio))

symbols <- c(
  "INFY",
  "TCS",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  ratio <- share$information_ratio(nifty, days = 365)
  if (ratio > 0.5) {
    cat(sprintf("%s: %.2f, consistently ahead\n", symbol, ratio))
  } else {
    cat(sprintf("%s: %.2f, not consistently ahead\n", symbol, ratio))
  }
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$up_capture_ratio()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
ratio <- infosys$up_capture_ratio(nifty, days = 365)
cat(sprintf("Up capture: %.2f\n", ratio))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
up_ratio <- tcs$up_capture_ratio(nifty, days = 730)
down_ratio <- tcs$down_capture_ratio(nifty, days = 730)
cat(sprintf("Up capture %.2f, down capture %.2f\n", up_ratio, down_ratio))
if (up_ratio > down_ratio) {
  cat("TCS caught more of the rises than of the falls.\n")
} else {
  cat("TCS caught no more of the rises than of the falls.\n")
}
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$down_capture_ratio()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
ratio <- infosys$down_capture_ratio(nifty, days = 365)
cat(sprintf("Down capture: %.2f\n", ratio))

symbols <- c(
  "INFY",
  "TCS",
  "RELIANCE"
)
safest_symbol <- NULL
lowest_ratio <- NULL
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  ratio <- share$down_capture_ratio(
    nifty,
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
  cat(sprintf("%s: %.2f\n", symbol, ratio))
  if (is.null(lowest_ratio) || ratio < lowest_ratio) {
    safest_symbol <- symbol
    lowest_ratio <- ratio
  }
}
cat(sprintf("Fell least with the index: %s\n", safest_symbol))
} # }

## ------------------------------------------------
## Method `PerformanceMeasures$performance_summary()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
summary <- infosys$performance_summary(
  risk_free_rate = 0.065,
  days = 365
)
str(summary)

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
summary <- infosys$performance_summary(
  benchmark = nifty,
  risk_free_rate = 0.065,
  confidence = 0.99,
  days = 730
)
str(summary)

symbols <- c(
  "INFY",
  "TCS",
  "RELIANCE"
)
measures <- c(
  "annualised_return",
  "sharpe_ratio",
  "maximum_drawdown",
  "benchmark_beta"
)
table <- data.frame(row.names = measures)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  summary <- share$performance_summary(
    benchmark = nifty,
    risk_free_rate = 0.065,
    days = 365
  )
  column <- numeric(0)
  for (measure in measures) {
    value <- summary[[measure]]
    if (is.null(value)) {
      value <- NA
    }
    column[[measure]] <- value
  }
  table[[symbol]] <- column
}
print(table)
} # }
```
