# Candlestick pattern recognisers an instrument runs over its candles

TA-Lib's recognisers for named one to five candle formations. Each
method fetches the instrument's candles through `prices()`, adds one
column and returns the candles. The class is a link in the chain of
analysis classes that `Instrument` inherits, and `Instrument` supplies
`prices()`.

The recognisers come from the `talib` package, which wraps the same
TA-Lib C library as Python's `talib`. Its signals are read as 100 and
-100, not 1 and -1, and the candles at the start that TA-Lib cannot
judge get 0, as in Python.

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
-\> `CandlestickPatterns`

## Methods

### Public methods

- [`CandlestickPatterns$candle_two_crows()`](#method-CandlestickPatterns-candle_two_crows)

- [`CandlestickPatterns$candle_three_black_crows()`](#method-CandlestickPatterns-candle_three_black_crows)

- [`CandlestickPatterns$candle_three_inside_up_down()`](#method-CandlestickPatterns-candle_three_inside_up_down)

- [`CandlestickPatterns$candle_three_line_strike()`](#method-CandlestickPatterns-candle_three_line_strike)

- [`CandlestickPatterns$candle_three_outside_up_down()`](#method-CandlestickPatterns-candle_three_outside_up_down)

- [`CandlestickPatterns$candle_three_stars_in_the_south()`](#method-CandlestickPatterns-candle_three_stars_in_the_south)

- [`CandlestickPatterns$candle_three_white_soldiers()`](#method-CandlestickPatterns-candle_three_white_soldiers)

- [`CandlestickPatterns$candle_abandoned_baby()`](#method-CandlestickPatterns-candle_abandoned_baby)

- [`CandlestickPatterns$candle_advance_block()`](#method-CandlestickPatterns-candle_advance_block)

- [`CandlestickPatterns$candle_belt_hold()`](#method-CandlestickPatterns-candle_belt_hold)

- [`CandlestickPatterns$candle_breakaway()`](#method-CandlestickPatterns-candle_breakaway)

- [`CandlestickPatterns$candle_closing_marubozu()`](#method-CandlestickPatterns-candle_closing_marubozu)

- [`CandlestickPatterns$candle_concealing_baby_swallow()`](#method-CandlestickPatterns-candle_concealing_baby_swallow)

- [`CandlestickPatterns$candle_counter_attack()`](#method-CandlestickPatterns-candle_counter_attack)

- [`CandlestickPatterns$candle_dark_cloud_cover()`](#method-CandlestickPatterns-candle_dark_cloud_cover)

- [`CandlestickPatterns$candle_doji()`](#method-CandlestickPatterns-candle_doji)

- [`CandlestickPatterns$candle_doji_star()`](#method-CandlestickPatterns-candle_doji_star)

- [`CandlestickPatterns$candle_dragonfly_doji()`](#method-CandlestickPatterns-candle_dragonfly_doji)

- [`CandlestickPatterns$candle_engulfing()`](#method-CandlestickPatterns-candle_engulfing)

- [`CandlestickPatterns$candle_evening_doji_star()`](#method-CandlestickPatterns-candle_evening_doji_star)

- [`CandlestickPatterns$candle_evening_star()`](#method-CandlestickPatterns-candle_evening_star)

- [`CandlestickPatterns$candle_side_by_side_white_lines()`](#method-CandlestickPatterns-candle_side_by_side_white_lines)

- [`CandlestickPatterns$candle_gravestone_doji()`](#method-CandlestickPatterns-candle_gravestone_doji)

- [`CandlestickPatterns$candle_hammer()`](#method-CandlestickPatterns-candle_hammer)

- [`CandlestickPatterns$candle_hanging_man()`](#method-CandlestickPatterns-candle_hanging_man)

- [`CandlestickPatterns$candle_harami()`](#method-CandlestickPatterns-candle_harami)

- [`CandlestickPatterns$candle_harami_cross()`](#method-CandlestickPatterns-candle_harami_cross)

- [`CandlestickPatterns$candle_high_wave()`](#method-CandlestickPatterns-candle_high_wave)

- [`CandlestickPatterns$candle_hikkake()`](#method-CandlestickPatterns-candle_hikkake)

- [`CandlestickPatterns$candle_modified_hikkake()`](#method-CandlestickPatterns-candle_modified_hikkake)

- [`CandlestickPatterns$candle_homing_pigeon()`](#method-CandlestickPatterns-candle_homing_pigeon)

- [`CandlestickPatterns$candle_identical_three_crows()`](#method-CandlestickPatterns-candle_identical_three_crows)

- [`CandlestickPatterns$candle_in_neck()`](#method-CandlestickPatterns-candle_in_neck)

- [`CandlestickPatterns$candle_inverted_hammer()`](#method-CandlestickPatterns-candle_inverted_hammer)

- [`CandlestickPatterns$candle_kicking()`](#method-CandlestickPatterns-candle_kicking)

- [`CandlestickPatterns$candle_kicking_by_length()`](#method-CandlestickPatterns-candle_kicking_by_length)

- [`CandlestickPatterns$candle_ladder_bottom()`](#method-CandlestickPatterns-candle_ladder_bottom)

- [`CandlestickPatterns$candle_long_legged_doji()`](#method-CandlestickPatterns-candle_long_legged_doji)

- [`CandlestickPatterns$candle_long_line()`](#method-CandlestickPatterns-candle_long_line)

- [`CandlestickPatterns$candle_marubozu()`](#method-CandlestickPatterns-candle_marubozu)

- [`CandlestickPatterns$candle_matching_low()`](#method-CandlestickPatterns-candle_matching_low)

- [`CandlestickPatterns$candle_mat_hold()`](#method-CandlestickPatterns-candle_mat_hold)

- [`CandlestickPatterns$candle_morning_star()`](#method-CandlestickPatterns-candle_morning_star)

- [`CandlestickPatterns$candle_morning_star_doji()`](#method-CandlestickPatterns-candle_morning_star_doji)

- [`CandlestickPatterns$candle_on_neck()`](#method-CandlestickPatterns-candle_on_neck)

- [`CandlestickPatterns$candle_piercing()`](#method-CandlestickPatterns-candle_piercing)

- [`CandlestickPatterns$candle_rickshaw_man()`](#method-CandlestickPatterns-candle_rickshaw_man)

- [`CandlestickPatterns$candle_rise_fall_three_methods()`](#method-CandlestickPatterns-candle_rise_fall_three_methods)

- [`CandlestickPatterns$candle_separating_lines()`](#method-CandlestickPatterns-candle_separating_lines)

- [`CandlestickPatterns$candle_shooting_star()`](#method-CandlestickPatterns-candle_shooting_star)

- [`CandlestickPatterns$candle_short_line()`](#method-CandlestickPatterns-candle_short_line)

- [`CandlestickPatterns$candle_spinning_top()`](#method-CandlestickPatterns-candle_spinning_top)

- [`CandlestickPatterns$candle_stalled_pattern()`](#method-CandlestickPatterns-candle_stalled_pattern)

- [`CandlestickPatterns$candle_stick_sandwich()`](#method-CandlestickPatterns-candle_stick_sandwich)

- [`CandlestickPatterns$candle_takuri()`](#method-CandlestickPatterns-candle_takuri)

- [`CandlestickPatterns$candle_tasuki_gap()`](#method-CandlestickPatterns-candle_tasuki_gap)

- [`CandlestickPatterns$candle_thrusting_pattern()`](#method-CandlestickPatterns-candle_thrusting_pattern)

- [`CandlestickPatterns$candle_tristar()`](#method-CandlestickPatterns-candle_tristar)

- [`CandlestickPatterns$candle_unique_three_river()`](#method-CandlestickPatterns-candle_unique_three_river)

- [`CandlestickPatterns$candle_up_side_gap_two_crows()`](#method-CandlestickPatterns-candle_up_side_gap_two_crows)

- [`CandlestickPatterns$candle_up_side_down_side_gap_three_methods()`](#method-CandlestickPatterns-candle_up_side_down_side_gap_three_methods)

- [`CandlestickPatterns$clone()`](#method-CandlestickPatterns-clone)

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

------------------------------------------------------------------------

### `CandlestickPatterns$candle_two_crows()`

Marks where the two crows candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_two_crows(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_two_crows` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_two_crows(days = 365)
    pattern_column <- "candle_two_crows"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_two_crows"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_two_crows(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_three_black_crows()`

Marks where the three black crows candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_three_black_crows(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_three_black_crows` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_three_black_crows(days = 730)
    pattern_column <- "candle_three_black_crows"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_three_black_crows(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_three_black_crows"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_three_inside_up_down()`

Marks where the three inside up or down candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_three_inside_up_down(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_three_inside_up_down`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_three_inside_up_down(days = 1095)
    pattern_column <- "candle_three_inside_up_down"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_three_inside_up_down(days = 1825)
    pattern_column <- "candle_three_inside_up_down"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_three_line_strike()`

Marks where the three line strike candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_three_line_strike(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_three_line_strike` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_three_line_strike"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_three_line_strike(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_three_line_strike(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_three_line_strike"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_three_outside_up_down()`

Marks where the three outside up or down candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_three_outside_up_down(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_three_outside_up_down`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_three_outside_up_down(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_three_outside_up_down"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_three_outside_up_down(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_three_outside_up_down"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_three_stars_in_the_south()`

Marks where the three stars in the south candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_three_stars_in_the_south(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_three_stars_in_the_south`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_three_stars_in_the_south(days = 1825)
    pattern_column <- "candle_three_stars_in_the_south"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_three_stars_in_the_south(days = 365)
    pattern_column <- "candle_three_stars_in_the_south"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_three_white_soldiers()`

Marks where the three white soldiers candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_three_white_soldiers(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_three_white_soldiers`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_three_white_soldiers(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_three_white_soldiers"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_three_white_soldiers(days = 730)
    pattern_column <- "candle_three_white_soldiers"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

------------------------------------------------------------------------

### `CandlestickPatterns$candle_abandoned_baby()`

Marks where the abandoned baby candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_abandoned_baby(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_abandoned_baby` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_abandoned_baby(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_abandoned_baby"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_abandoned_baby(days = 1095)
    pattern_column <- "candle_abandoned_baby"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_advance_block()`

Marks where the advance block candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_advance_block(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_advance_block` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_advance_block(days = 365)
    pattern_column <- "candle_advance_block"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_advance_block"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_advance_block(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_belt_hold()`

Marks where the belt hold candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_belt_hold(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_belt_hold` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_belt_hold(days = 730)
    pattern_column <- "candle_belt_hold"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_belt_hold(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_belt_hold"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_breakaway()`

Marks where the breakaway candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_breakaway(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_breakaway` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_breakaway(days = 1095)
    pattern_column <- "candle_breakaway"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_breakaway(days = 1825)
    pattern_column <- "candle_breakaway"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_closing_marubozu()`

Marks where the closing marubozu candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_closing_marubozu(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_closing_marubozu` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_closing_marubozu"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_closing_marubozu(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_closing_marubozu(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_closing_marubozu"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_concealing_baby_swallow()`

Marks where the concealing baby swallow candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_concealing_baby_swallow(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_concealing_baby_swallow`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_concealing_baby_swallow(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_concealing_baby_swallow"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_concealing_baby_swallow(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_concealing_baby_swallow"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_counter_attack()`

Marks where the counterattack candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_counter_attack(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_counter_attack` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_counter_attack(days = 1825)
    pattern_column <- "candle_counter_attack"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_counter_attack(days = 365)
    pattern_column <- "candle_counter_attack"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_dark_cloud_cover()`

Marks where the dark cloud cover candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_dark_cloud_cover(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_dark_cloud_cover` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_dark_cloud_cover(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_dark_cloud_cover"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_dark_cloud_cover(days = 730)
    pattern_column <- "candle_dark_cloud_cover"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

------------------------------------------------------------------------

### `CandlestickPatterns$candle_doji()`

Marks where the doji candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_doji(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_doji` column added, which
is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or
`NULL` when UBI has no candles for the range.

#### Examples

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_doji(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_doji"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_doji(days = 1095)
    pattern_column <- "candle_doji"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_doji_star()`

Marks where the doji star candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_doji_star(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_doji_star` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_doji_star(days = 365)
    pattern_column <- "candle_doji_star"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_doji_star"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_doji_star(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_dragonfly_doji()`

Marks where the dragonfly doji candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_dragonfly_doji(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_dragonfly_doji` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_dragonfly_doji(days = 730)
    pattern_column <- "candle_dragonfly_doji"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_dragonfly_doji(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_dragonfly_doji"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_engulfing()`

Marks where the engulfing candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_engulfing(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_engulfing` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_engulfing(days = 1095)
    pattern_column <- "candle_engulfing"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_engulfing(days = 1825)
    pattern_column <- "candle_engulfing"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_evening_doji_star()`

Marks where the evening doji star candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_evening_doji_star(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_evening_dojistar` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_evening_dojistar"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_evening_doji_star(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_evening_doji_star(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_evening_dojistar"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_evening_star()`

Marks where the evening star candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_evening_star(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_evening_star` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_evening_star(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_evening_star"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_evening_star(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_evening_star"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_side_by_side_white_lines()`

Marks where the up or down gap side by side white lines candlestick
pattern appears.

#### Usage

    CandlestickPatterns$candle_side_by_side_white_lines(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_side_by_side_white_lines`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_side_by_side_white_lines(days = 1825)
    pattern_column <- "candle_side_by_side_white_lines"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_side_by_side_white_lines(days = 365)
    pattern_column <- "candle_side_by_side_white_lines"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_gravestone_doji()`

Marks where the gravestone doji candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_gravestone_doji(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_gravestone_doji` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_gravestone_doji(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_gravestone_doji"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_gravestone_doji(days = 730)
    pattern_column <- "candle_gravestone_doji"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

------------------------------------------------------------------------

### `CandlestickPatterns$candle_hammer()`

Marks where the hammer candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_hammer(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_hammer` column added, which
is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or
`NULL` when UBI has no candles for the range.

#### Examples

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_hammer(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_hammer"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_hammer(days = 1095)
    pattern_column <- "candle_hammer"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_hanging_man()`

Marks where the hanging man candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_hanging_man(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_hangingman` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_hanging_man(days = 365)
    pattern_column <- "candle_hangingman"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_hangingman"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_hanging_man(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_harami()`

Marks where the harami candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_harami(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_harami` column added, which
is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or
`NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_harami(days = 730)
    pattern_column <- "candle_harami"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_harami(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_harami"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_harami_cross()`

Marks where the harami cross candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_harami_cross(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_harami_cross` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_harami_cross(days = 1095)
    pattern_column <- "candle_harami_cross"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_harami_cross(days = 1825)
    pattern_column <- "candle_harami_cross"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_high_wave()`

Marks where the high wave candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_high_wave(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_high_wave` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_high_wave"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_high_wave(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_high_wave(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_high_wave"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_hikkake()`

Marks where the hikkake candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_hikkake(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_hikkake` column added,
which is 100 for a bullish match, -100 for a bearish match, 200 or -200
when the match is confirmed and 0 otherwise, or `NULL` when UBI has no
candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_hikkake(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_hikkake"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_hikkake(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_hikkake"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_modified_hikkake()`

Marks where the modified hikkake candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_modified_hikkake(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_modified_hikkake` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_modified_hikkake(days = 1825)
    pattern_column <- "candle_modified_hikkake"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_modified_hikkake(days = 365)
    pattern_column <- "candle_modified_hikkake"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_homing_pigeon()`

Marks where the homing pigeon candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_homing_pigeon(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_homing_pigeon` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_homing_pigeon(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_homing_pigeon"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_homing_pigeon(days = 730)
    pattern_column <- "candle_homing_pigeon"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

------------------------------------------------------------------------

### `CandlestickPatterns$candle_identical_three_crows()`

Marks where the identical three crows candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_identical_three_crows(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_identical_three_crows`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_identical_three_crows(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_identical_three_crows"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_identical_three_crows(days = 1095)
    pattern_column <- "candle_identical_three_crows"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_in_neck()`

Marks where the in-neck candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_in_neck(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_in_neck` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_in_neck(days = 365)
    pattern_column <- "candle_in_neck"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_in_neck"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_in_neck(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_inverted_hammer()`

Marks where the inverted hammer candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_inverted_hammer(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_inverted_hammer` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_inverted_hammer(days = 730)
    pattern_column <- "candle_inverted_hammer"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_inverted_hammer(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_inverted_hammer"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_kicking()`

Marks where the kicking candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_kicking(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_kicking` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_kicking(days = 1095)
    pattern_column <- "candle_kicking"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_kicking(days = 1825)
    pattern_column <- "candle_kicking"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_kicking_by_length()`

Marks where the kicking, bull or bear decided by the longer marubozu,
candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_kicking_by_length(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_kicking_by_length` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_kicking_by_length"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_kicking_by_length(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_kicking_by_length(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_kicking_by_length"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_ladder_bottom()`

Marks where the ladder bottom candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_ladder_bottom(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_ladder_bottom` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_ladder_bottom(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_ladder_bottom"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_ladder_bottom(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_ladder_bottom"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_long_legged_doji()`

Marks where the long legged doji candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_long_legged_doji(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_long_legged_doji` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_long_legged_doji(days = 1825)
    pattern_column <- "candle_long_legged_doji"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_long_legged_doji(days = 365)
    pattern_column <- "candle_long_legged_doji"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_long_line()`

Marks where the long line candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_long_line(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_long_line` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_long_line(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_long_line"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_long_line(days = 730)
    pattern_column <- "candle_long_line"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

------------------------------------------------------------------------

### `CandlestickPatterns$candle_marubozu()`

Marks where the marubozu candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_marubozu(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_marubozu` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_marubozu(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_marubozu"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_marubozu(days = 1095)
    pattern_column <- "candle_marubozu"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_matching_low()`

Marks where the matching low candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_matching_low(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_matching_low` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_matching_low(days = 365)
    pattern_column <- "candle_matching_low"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_matching_low"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_matching_low(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_mat_hold()`

Marks where the mat hold candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_mat_hold(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_mat_hold` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_mat_hold(days = 730)
    pattern_column <- "candle_mat_hold"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_mat_hold(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_mat_hold"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_morning_star()`

Marks where the morning star candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_morning_star(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_morning_star` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_morning_star(days = 1095)
    pattern_column <- "candle_morning_star"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_morning_star(days = 1825)
    pattern_column <- "candle_morning_star"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_morning_star_doji()`

Marks where the morning doji star candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_morning_star_doji(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_morning_star_doji` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_morning_star_doji"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_morning_star_doji(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_morning_star_doji(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_morning_star_doji"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_on_neck()`

Marks where the on-neck candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_on_neck(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_on_neck` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_on_neck(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_on_neck"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_on_neck(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_on_neck"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_piercing()`

Marks where the piercing candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_piercing(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_piercing` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_piercing(days = 1825)
    pattern_column <- "candle_piercing"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_piercing(days = 365)
    pattern_column <- "candle_piercing"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_rickshaw_man()`

Marks where the rickshaw man candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_rickshaw_man(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_rickshaw_man` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_rickshaw_man(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_rickshaw_man"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_rickshaw_man(days = 730)
    pattern_column <- "candle_rickshaw_man"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

------------------------------------------------------------------------

### `CandlestickPatterns$candle_rise_fall_three_methods()`

Marks where the rising or falling three methods candlestick pattern
appears.

#### Usage

    CandlestickPatterns$candle_rise_fall_three_methods(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_rise_fall_three_methods`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_rise_fall_three_methods(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_rise_fall_three_methods"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_rise_fall_three_methods(days = 1095)
    pattern_column <- "candle_rise_fall_three_methods"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_separating_lines()`

Marks where the separating lines candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_separating_lines(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_separating_lines` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_separating_lines(days = 365)
    pattern_column <- "candle_separating_lines"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_separating_lines"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_separating_lines(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_shooting_star()`

Marks where the shooting star candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_shooting_star(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_shooting_star` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_shooting_star(days = 730)
    pattern_column <- "candle_shooting_star"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_shooting_star(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_shooting_star"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_short_line()`

Marks where the short line candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_short_line(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_short_line` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_short_line(days = 1095)
    pattern_column <- "candle_short_line"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_short_line(days = 1825)
    pattern_column <- "candle_short_line"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_spinning_top()`

Marks where the spinning top candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_spinning_top(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_spinning_top` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_spinning_top"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_spinning_top(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_spinning_top(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_spinning_top"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_stalled_pattern()`

Marks where the stalled candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_stalled_pattern(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_stalled_pattern` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_stalled_pattern(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_stalled_pattern"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_stalled_pattern(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_stalled_pattern"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_stick_sandwich()`

Marks where the stick sandwich candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_stick_sandwich(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_stick_sandwich` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_stick_sandwich(days = 1825)
    pattern_column <- "candle_stick_sandwich"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_stick_sandwich(days = 365)
    pattern_column <- "candle_stick_sandwich"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_takuri()`

Marks where the takuri, a dragonfly doji with a very long lower shadow,
candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_takuri(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_takuri` column added, which
is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or
`NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_takuri(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_takuri"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_takuri(days = 730)
    pattern_column <- "candle_takuri"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

------------------------------------------------------------------------

### `CandlestickPatterns$candle_tasuki_gap()`

Marks where the tasuki gap candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_tasuki_gap(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_tasuki_gap` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_tasuki_gap(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_tasuki_gap"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_tasuki_gap(days = 1095)
    pattern_column <- "candle_tasuki_gap"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_thrusting_pattern()`

Marks where the thrusting candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_thrusting_pattern(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_thrusting_pattern` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    pattern_frame <- infosys$candle_thrusting_pattern(days = 365)
    pattern_column <- "candle_thrusting_pattern"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in the last year.")
    }
    for (position in seq_len(nrow(matches))) {
      row <- matches[position, ]
      print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    }

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_thrusting_pattern"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_thrusting_pattern(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_tristar()`

Marks where the tristar candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_tristar(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_tristar` column added,
which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_tristar(days = 730)
    pattern_column <- "candle_tristar"
    bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_tristar(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_tristar"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_unique_three_river()`

Marks where the unique three river candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_unique_three_river(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_unique_three_river` column
added, which is 100 for a bullish match, -100 for a bearish match and 0
otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    pattern_frame <- reliance$candle_unique_three_river(days = 1095)
    pattern_column <- "candle_unique_three_river"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match on Reliance in three years.")
    } else {
      latest <- matches[nrow(matches), ]
      latest_date <- format(latest$datetime, "%Y-%m-%d")
      close_price <- latest$close
      print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    }

    hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    pattern_frame <- hdfc_bank$candle_unique_three_river(days = 1825)
    pattern_column <- "candle_unique_three_river"
    closes <- pattern_frame$close
    next_closes <- c(closes[-1], NA)
    next_day_return <- next_closes / closes - 1
    after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    after_pattern <- after_pattern[!is.na(after_pattern)]
    if (length(after_pattern) == 0) {
      print("No match with a following day to measure.")
    } else {
      average <- mean(after_pattern)
      match_count <- length(after_pattern)
      print(
        sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
      )
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_up_side_gap_two_crows()`

Marks where the upside gap two crows candlestick pattern appears.

#### Usage

    CandlestickPatterns$candle_up_side_gap_two_crows(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_up_side_gap_two_crows`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    symbols <- c(
      "INFY",
      "TCS",
      "HDFCBANK"
    )
    pattern_column <- "candle_up_side_gap_two_crows"
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      pattern_frame <- share$candle_up_side_gap_two_crows(days = 1825)
      match_count <- sum(pattern_frame[[pattern_column]] != 0)
      print(sprintf("%s: %d matches in five years", symbol, match_count))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    pattern_frame <- nifty$candle_up_side_gap_two_crows(days = 30)
    latest <- pattern_frame[nrow(pattern_frame), ]
    latest_date <- format(latest$datetime, "%Y-%m-%d")
    signal <- latest[["candle_up_side_gap_two_crows"]]
    if (signal > 0) {
      print(sprintf("Bullish match on %s.", latest_date))
    } else if (signal < 0) {
      print(sprintf("Bearish match on %s.", latest_date))
    } else {
      print(sprintf("No match on the latest candle, %s.", latest_date))
    }

------------------------------------------------------------------------

### `CandlestickPatterns$candle_up_side_down_side_gap_three_methods()`

Marks where the upside or downside gap three methods candlestick pattern
appears.

#### Usage

    CandlestickPatterns$candle_up_side_down_side_gap_three_methods(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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

A `data.frame` of the candles with a `candle_up_side_gap_three_methods`
column added, which is 100 for a bullish match, -100 for a bearish match
and 0 otherwise, or `NULL` when UBI has no candles for the range.

#### Examples

    tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    pattern_frame <- tcs$candle_up_side_down_side_gap_three_methods(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    pattern_column <- "candle_up_side_gap_three_methods"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    if (nrow(matches) == 0) {
      print("No match in 2025.")
    } else {
      months <- format(matches$datetime, "%Y-%m")
      print(table(months))
    }

    state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    pattern_frame <- state_bank$candle_up_side_down_side_gap_three_methods(
      days = 180,
      adjusted = FALSE
    )
    pattern_column <- "candle_up_side_gap_three_methods"
    matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    columns <- c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      pattern_column
    )
    if (nrow(matches) == 0) {
      print("No match in the last six months.")
    } else {
      print(matches[, columns], row.names = FALSE)
    }

------------------------------------------------------------------------

### `CandlestickPatterns$clone()`

The objects of this class are cloneable with this method.

#### Usage

    CandlestickPatterns$clone(deep = FALSE)

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
frame <- infosys$candle_hammer(days = 365)
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_two_crows()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_two_crows(days = 365)
pattern_column <- "candle_two_crows"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_two_crows"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_two_crows(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_three_black_crows()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_three_black_crows(days = 730)
pattern_column <- "candle_three_black_crows"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_three_black_crows(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_three_black_crows"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_three_inside_up_down()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_three_inside_up_down(days = 1095)
pattern_column <- "candle_three_inside_up_down"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}

hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_three_inside_up_down(days = 1825)
pattern_column <- "candle_three_inside_up_down"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_three_line_strike()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_three_line_strike"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_three_line_strike(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_three_line_strike(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_three_line_strike"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_three_outside_up_down()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_three_outside_up_down(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_three_outside_up_down"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}

state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_three_outside_up_down(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_three_outside_up_down"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_three_stars_in_the_south()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_three_stars_in_the_south(days = 1825)
pattern_column <- "candle_three_stars_in_the_south"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_three_stars_in_the_south(days = 365)
pattern_column <- "candle_three_stars_in_the_south"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_three_white_soldiers()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_three_white_soldiers(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_three_white_soldiers"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_three_white_soldiers(days = 730)
pattern_column <- "candle_three_white_soldiers"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_abandoned_baby()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_abandoned_baby(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_abandoned_baby"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_abandoned_baby(days = 1095)
pattern_column <- "candle_abandoned_baby"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_advance_block()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_advance_block(days = 365)
pattern_column <- "candle_advance_block"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_advance_block"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_advance_block(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_belt_hold()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_belt_hold(days = 730)
pattern_column <- "candle_belt_hold"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_belt_hold(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_belt_hold"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_breakaway()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_breakaway(days = 1095)
pattern_column <- "candle_breakaway"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}

hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_breakaway(days = 1825)
pattern_column <- "candle_breakaway"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_closing_marubozu()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_closing_marubozu"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_closing_marubozu(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_closing_marubozu(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_closing_marubozu"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_concealing_baby_swallow()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_concealing_baby_swallow(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_concealing_baby_swallow"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}

state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_concealing_baby_swallow(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_concealing_baby_swallow"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_counter_attack()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_counter_attack(days = 1825)
pattern_column <- "candle_counter_attack"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_counter_attack(days = 365)
pattern_column <- "candle_counter_attack"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_dark_cloud_cover()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_dark_cloud_cover(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_dark_cloud_cover"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_dark_cloud_cover(days = 730)
pattern_column <- "candle_dark_cloud_cover"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_doji()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_doji(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_doji"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_doji(days = 1095)
pattern_column <- "candle_doji"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_doji_star()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_doji_star(days = 365)
pattern_column <- "candle_doji_star"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_doji_star"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_doji_star(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_dragonfly_doji()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_dragonfly_doji(days = 730)
pattern_column <- "candle_dragonfly_doji"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_dragonfly_doji(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_dragonfly_doji"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_engulfing()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_engulfing(days = 1095)
pattern_column <- "candle_engulfing"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}

hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_engulfing(days = 1825)
pattern_column <- "candle_engulfing"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_evening_doji_star()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_evening_dojistar"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_evening_doji_star(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_evening_doji_star(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_evening_dojistar"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_evening_star()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_evening_star(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_evening_star"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}

state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_evening_star(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_evening_star"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_side_by_side_white_lines()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_side_by_side_white_lines(days = 1825)
pattern_column <- "candle_side_by_side_white_lines"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_side_by_side_white_lines(days = 365)
pattern_column <- "candle_side_by_side_white_lines"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_gravestone_doji()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_gravestone_doji(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_gravestone_doji"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_gravestone_doji(days = 730)
pattern_column <- "candle_gravestone_doji"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_hammer()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_hammer(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_hammer"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_hammer(days = 1095)
pattern_column <- "candle_hammer"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_hanging_man()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_hanging_man(days = 365)
pattern_column <- "candle_hangingman"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_hangingman"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_hanging_man(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_harami()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_harami(days = 730)
pattern_column <- "candle_harami"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_harami(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_harami"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_harami_cross()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_harami_cross(days = 1095)
pattern_column <- "candle_harami_cross"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}

hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_harami_cross(days = 1825)
pattern_column <- "candle_harami_cross"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_high_wave()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_high_wave"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_high_wave(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_high_wave(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_high_wave"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_hikkake()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_hikkake(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_hikkake"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}

state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_hikkake(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_hikkake"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_modified_hikkake()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_modified_hikkake(days = 1825)
pattern_column <- "candle_modified_hikkake"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_modified_hikkake(days = 365)
pattern_column <- "candle_modified_hikkake"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_homing_pigeon()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_homing_pigeon(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_homing_pigeon"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_homing_pigeon(days = 730)
pattern_column <- "candle_homing_pigeon"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_identical_three_crows()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_identical_three_crows(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_identical_three_crows"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_identical_three_crows(days = 1095)
pattern_column <- "candle_identical_three_crows"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_in_neck()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_in_neck(days = 365)
pattern_column <- "candle_in_neck"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_in_neck"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_in_neck(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_inverted_hammer()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_inverted_hammer(days = 730)
pattern_column <- "candle_inverted_hammer"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_inverted_hammer(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_inverted_hammer"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_kicking()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_kicking(days = 1095)
pattern_column <- "candle_kicking"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}

hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_kicking(days = 1825)
pattern_column <- "candle_kicking"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_kicking_by_length()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_kicking_by_length"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_kicking_by_length(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_kicking_by_length(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_kicking_by_length"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_ladder_bottom()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_ladder_bottom(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_ladder_bottom"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}

state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_ladder_bottom(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_ladder_bottom"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_long_legged_doji()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_long_legged_doji(days = 1825)
pattern_column <- "candle_long_legged_doji"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_long_legged_doji(days = 365)
pattern_column <- "candle_long_legged_doji"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_long_line()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_long_line(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_long_line"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_long_line(days = 730)
pattern_column <- "candle_long_line"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_marubozu()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_marubozu(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_marubozu"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_marubozu(days = 1095)
pattern_column <- "candle_marubozu"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_matching_low()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_matching_low(days = 365)
pattern_column <- "candle_matching_low"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_matching_low"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_matching_low(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_mat_hold()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_mat_hold(days = 730)
pattern_column <- "candle_mat_hold"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_mat_hold(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_mat_hold"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_morning_star()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_morning_star(days = 1095)
pattern_column <- "candle_morning_star"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}

hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_morning_star(days = 1825)
pattern_column <- "candle_morning_star"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_morning_star_doji()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_morning_star_doji"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_morning_star_doji(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_morning_star_doji(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_morning_star_doji"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_on_neck()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_on_neck(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_on_neck"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}

state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_on_neck(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_on_neck"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_piercing()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_piercing(days = 1825)
pattern_column <- "candle_piercing"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_piercing(days = 365)
pattern_column <- "candle_piercing"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_rickshaw_man()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_rickshaw_man(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_rickshaw_man"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_rickshaw_man(days = 730)
pattern_column <- "candle_rickshaw_man"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_rise_fall_three_methods()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_rise_fall_three_methods(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_rise_fall_three_methods"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_rise_fall_three_methods(days = 1095)
pattern_column <- "candle_rise_fall_three_methods"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_separating_lines()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_separating_lines(days = 365)
pattern_column <- "candle_separating_lines"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_separating_lines"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_separating_lines(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_shooting_star()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_shooting_star(days = 730)
pattern_column <- "candle_shooting_star"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_shooting_star(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_shooting_star"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_short_line()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_short_line(days = 1095)
pattern_column <- "candle_short_line"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}

hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_short_line(days = 1825)
pattern_column <- "candle_short_line"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_spinning_top()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_spinning_top"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_spinning_top(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_spinning_top(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_spinning_top"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_stalled_pattern()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_stalled_pattern(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_stalled_pattern"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}

state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_stalled_pattern(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_stalled_pattern"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_stick_sandwich()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_stick_sandwich(days = 1825)
pattern_column <- "candle_stick_sandwich"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_stick_sandwich(days = 365)
pattern_column <- "candle_stick_sandwich"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_takuri()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_takuri(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_takuri"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_takuri(days = 730)
pattern_column <- "candle_takuri"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_tasuki_gap()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_tasuki_gap(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_tasuki_gap"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_tasuki_gap(days = 1095)
pattern_column <- "candle_tasuki_gap"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_thrusting_pattern()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
pattern_frame <- infosys$candle_thrusting_pattern(days = 365)
pattern_column <- "candle_thrusting_pattern"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in the last year.")
}
for (position in seq_len(nrow(matches))) {
  row <- matches[position, ]
  print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
}

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_thrusting_pattern"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_thrusting_pattern(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_tristar()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_tristar(days = 730)
pattern_column <- "candle_tristar"
bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))

tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_tristar(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_tristar"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_unique_three_river()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pattern_frame <- reliance$candle_unique_three_river(days = 1095)
pattern_column <- "candle_unique_three_river"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match on Reliance in three years.")
} else {
  latest <- matches[nrow(matches), ]
  latest_date <- format(latest$datetime, "%Y-%m-%d")
  close_price <- latest$close
  print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
}

hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
pattern_frame <- hdfc_bank$candle_unique_three_river(days = 1825)
pattern_column <- "candle_unique_three_river"
closes <- pattern_frame$close
next_closes <- c(closes[-1], NA)
next_day_return <- next_closes / closes - 1
after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
after_pattern <- after_pattern[!is.na(after_pattern)]
if (length(after_pattern) == 0) {
  print("No match with a following day to measure.")
} else {
  average <- mean(after_pattern)
  match_count <- length(after_pattern)
  print(
    sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
  )
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_up_side_gap_two_crows()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
pattern_column <- "candle_up_side_gap_two_crows"
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  pattern_frame <- share$candle_up_side_gap_two_crows(days = 1825)
  match_count <- sum(pattern_frame[[pattern_column]] != 0)
  print(sprintf("%s: %d matches in five years", symbol, match_count))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
pattern_frame <- nifty$candle_up_side_gap_two_crows(days = 30)
latest <- pattern_frame[nrow(pattern_frame), ]
latest_date <- format(latest$datetime, "%Y-%m-%d")
signal <- latest[["candle_up_side_gap_two_crows"]]
if (signal > 0) {
  print(sprintf("Bullish match on %s.", latest_date))
} else if (signal < 0) {
  print(sprintf("Bearish match on %s.", latest_date))
} else {
  print(sprintf("No match on the latest candle, %s.", latest_date))
}
} # }

## ------------------------------------------------
## Method `CandlestickPatterns$candle_up_side_down_side_gap_three_methods()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
tcs <- Equity$new(exchange = "nse", symbol = "TCS")
pattern_frame <- tcs$candle_up_side_down_side_gap_three_methods(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
pattern_column <- "candle_up_side_gap_three_methods"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
if (nrow(matches) == 0) {
  print("No match in 2025.")
} else {
  months <- format(matches$datetime, "%Y-%m")
  print(table(months))
}

state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
pattern_frame <- state_bank$candle_up_side_down_side_gap_three_methods(
  days = 180,
  adjusted = FALSE
)
pattern_column <- "candle_up_side_gap_three_methods"
matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
columns <- c(
  "datetime",
  "open",
  "high",
  "low",
  "close",
  pattern_column
)
if (nrow(matches) == 0) {
  print("No match in the last six months.")
} else {
  print(matches[, columns], row.names = FALSE)
}
} # }
```
