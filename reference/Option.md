# An option contract, the right but not the obligation to buy the underlying at the strike price, for a call, or to sell it, for a put

It holds the members every option shares: its moneyness against the
underlying, its premium split into intrinsic and time value, and its
implied volatility and greeks from `BlackScholes` or `Black76`. The
family classes such as `EquityOption` inherit it, and each carries the
discovery functions `expiries()`, `strikes()` and `chain()` on its class
generator, reading its own segment. Built directly, `Option` accepts any
option, including one on an index.

The pricing methods treat the option as European and without dividends,
and take it to expire at 15:30 India time on its expiry date, which is
what UBI's own order engine assumes. MCX commodity options trade until
later in the evening, so for them 15:30 is an approximation.

The examples below show its properties and the functions on its class
generator, in this order:

- For `Option$expiries()`, list the next five Nifty option expiries.

- For `Option$expiries()`, compare how many option expiries are listed
  on an index and on a share.

- For `Option$strikes()`, print the lowest and highest strikes and how
  many there are for the nearest Reliance option expiry.

- For `Option$strikes()`, find the at-the-money strike, the listed
  strike nearest the Nifty level.

- For `Option$chain()`, print the first rows of the nearest Nifty option
  chain.

- For `Option$chain()`, count the calls and the puts in a Reliance
  option chain.

- For `Option$chain()`, build the three calls nearest the money from the
  chain's instrument ids and print their prices.

- For `is_call`, check the kind of an at-the-money Nifty option.

- For `is_call`, split a list of options into calls and puts.

- For `is_put`, check that a contract built with the `PE` option type is
  a put.

- For `is_put`, show that a call is not a put.

- For `intrinsic_value`, print the intrinsic value of the at-the-money
  call and put.

- For `intrinsic_value`, compare the intrinsic value of a deep
  in-the-money Reliance call with its premium.

- For `time_value`, print how much of the at-the-money Nifty call's
  premium is time value.

- For `time_value`, compare the time value of the call and the put at
  the same strike.

- For `in_the_money`, say whether the at-the-money call and put are in
  the money right now.

- For `in_the_money`, count the in-the-money calls among five strikes
  around the money.

- For `moneyness_percent`, print how far the at-the-money call and put
  are from the money.

- For `moneyness_percent`, print the moneyness of the lowest and highest
  Reliance call strikes, one deep in and one far out of the money.

- For `breakeven_price`, print the level the Nifty must reach by expiry
  for a buyer of the at-the-money call to break even.

- For `breakeven_price`, print the move needed to break even for the
  call and the put, as a percentage of the index.

- For `premium_per_lot`, print what one lot of the at-the-money Nifty
  call costs.

- For `premium_per_lot`, work out how many lots of the call and the put
  a budget of Rs 50,000 buys.

- For `notional_value`, print the value of the index one lot of the
  at-the-money call controls.

- For `notional_value`, compare the premium with the notional value,
  which is the leverage an option gives.

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
-\>
[`Instrument`](https://pramodathani.github.io/tradeR/reference/Instrument.md)
-\>
[`TradeableInstrument`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.md)
-\>
[`Derivative`](https://pramodathani.github.io/tradeR/reference/Derivative.md)
-\> `Option`

## Active bindings

- `is_call`:

  A logical that is `TRUE` when the option is a call, the right to buy
  the underlying.

- `is_put`:

  A logical that is `TRUE` when the option is a put, the right to sell
  the underlying.

- `intrinsic_value`:

  The numeric worth of the option if exercised now, read from the
  underlying's last price, or `NULL` when that price is unknown. For a
  call it is how far the underlying is above the strike, and for a put
  how far it is below, and it is never less than zero.

- `time_value`:

  The numeric part of the premium above the intrinsic value, which is
  what the time left until expiry is worth, read from two quotes, or
  `NULL` when either is unknown.

- `in_the_money`:

  A logical that is `TRUE` when the option has intrinsic value, read
  from the underlying's last price, or `NULL` when that price is
  unknown.

- `moneyness_percent`:

  How far the option is in or out of the money, as a numeric percentage
  of the underlying's last price, or `NULL` when that price is unknown
  or zero. Positive means in the money and negative means out of it, for
  a call and a put alike, so a call struck 2 per cent above the
  underlying reads about -2.

- `breakeven_price`:

  The numeric underlying price at expiry at which a buyer of the option
  at its last price neither gains nor loses, or `NULL` when the last
  price is unknown.

- `premium_per_lot`:

  The numeric cost of buying one lot of the option at its last price,
  which is the last price times the lot size, or `NULL` when either is
  unknown.

- `notional_value`:

  The numeric value of the underlying one lot controls at the strike
  price, which is the strike times the lot size, or `NULL` when the lot
  size is unknown.

## Methods

### Public methods

- [`Option$new()`](#method-Option-initialize)

- [`Option$implied_volatility()`](#method-Option-implied_volatility)

- [`Option$greeks()`](#method-Option-greeks)

- [`Option$clone()`](#method-Option-clone)

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
- [`Instrument$equals()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-equals)
- [`Instrument$format()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-format)
- [`Instrument$prices()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-prices)
- [`Instrument$print()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-print)
- [`Instrument$ticks()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-ticks)
- [`TradeableInstrument$add_to_position()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-add_to_position)
- [`TradeableInstrument$buy_at_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_best_bid_price)
- [`TradeableInstrument$buy_at_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_best_offer_price)
- [`TradeableInstrument$buy_at_fifth_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_fifth_best_bid_price)
- [`TradeableInstrument$buy_at_fifth_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_fifth_best_offer_price)
- [`TradeableInstrument$buy_at_fourth_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_fourth_best_bid_price)
- [`TradeableInstrument$buy_at_fourth_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_fourth_best_offer_price)
- [`TradeableInstrument$buy_at_last_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_last_price)
- [`TradeableInstrument$buy_at_limit_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_limit_price)
- [`TradeableInstrument$buy_at_market_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_market_price)
- [`TradeableInstrument$buy_at_marketable_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_marketable_price)
- [`TradeableInstrument$buy_at_mid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_mid_price)
- [`TradeableInstrument$buy_at_second_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_second_best_bid_price)
- [`TradeableInstrument$buy_at_second_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_second_best_offer_price)
- [`TradeableInstrument$buy_at_third_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_third_best_bid_price)
- [`TradeableInstrument$buy_at_third_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_third_best_offer_price)
- [`TradeableInstrument$buy_at_volume_weighted_average_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-buy_at_volume_weighted_average_price)
- [`TradeableInstrument$cancel_open_orders()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-cancel_open_orders)
- [`TradeableInstrument$cancel_order()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-cancel_order)
- [`TradeableInstrument$cancel_parent()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-cancel_parent)
- [`TradeableInstrument$liquidate_all_positions()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-liquidate_all_positions)
- [`TradeableInstrument$liquidate_position()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-liquidate_position)
- [`TradeableInstrument$modify_order()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-modify_order)
- [`TradeableInstrument$parent()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-parent)
- [`TradeableInstrument$parent_orders()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-parent_orders)
- [`TradeableInstrument$parent_trades()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-parent_trades)
- [`TradeableInstrument$place_order()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-place_order)
- [`TradeableInstrument$reduce_position()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-reduce_position)
- [`TradeableInstrument$sell_at_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_best_bid_price)
- [`TradeableInstrument$sell_at_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_best_offer_price)
- [`TradeableInstrument$sell_at_fifth_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_fifth_best_bid_price)
- [`TradeableInstrument$sell_at_fifth_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_fifth_best_offer_price)
- [`TradeableInstrument$sell_at_fourth_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_fourth_best_bid_price)
- [`TradeableInstrument$sell_at_fourth_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_fourth_best_offer_price)
- [`TradeableInstrument$sell_at_last_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_last_price)
- [`TradeableInstrument$sell_at_limit_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_limit_price)
- [`TradeableInstrument$sell_at_market_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_market_price)
- [`TradeableInstrument$sell_at_marketable_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_marketable_price)
- [`TradeableInstrument$sell_at_mid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_mid_price)
- [`TradeableInstrument$sell_at_second_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_second_best_bid_price)
- [`TradeableInstrument$sell_at_second_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_second_best_offer_price)
- [`TradeableInstrument$sell_at_third_best_bid_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_third_best_bid_price)
- [`TradeableInstrument$sell_at_third_best_offer_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_third_best_offer_price)
- [`TradeableInstrument$sell_at_volume_weighted_average_price()`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.html#method-sell_at_volume_weighted_average_price)

------------------------------------------------------------------------

### `Option$new()`

Looks the option up in UBI and checks that it is an option with a strike
price and an option type.

#### Usage

    Option$new(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      underlying = NULL,
      unified_broker_interface = NULL
    )

#### Arguments

- `instrument_id`:

  The character UUID of the option, or `NULL` to look it up by exchange,
  segment and identity fields.

- `exchange`:

  The character exchange, such as `"nse"`, or `NULL` when
  `instrument_id` is given.

- `segment`:

  The character segment, such as `"equity_options"`, or `NULL` when
  `instrument_id` is given.

- `symbol`:

  The character symbol, or `NULL`.

- `underlying_symbol`:

  The character symbol of the option's underlying, or `NULL`.

- `expiry_date`:

  The expiry as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.

- `strike_price`:

  The numeric strike price, or `NULL`.

- `option_type`:

  The character option type, `"CE"` or `"PE"`, or `NULL`.

- `underlying`:

  The `Instrument` the option is written on, or `NULL` to use UBI's link
  or the family's default, looked up on every read.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to send requests through, or `NULL` to
  share one client among all instruments.

#### Details

Errors: signals `TypeError` when `underlying` is given and is not an
`Instrument`; `OptionError` when the instrument is a future rather than
an option, or UBI gave it no strike price or option type;
`DerivativeError` when the instrument is not a contract at all, or has
no expiry date; `TradeableInstrumentError` when the instrument is an
index; `InstrumentError` when UBI has no instrument matching the lookup;
`BadRequestError` when the lookup is incomplete or malformed; and
another `UnifiedBrokerInterfaceError` subclass for any other failure
reported by, or on the way to, UBI.

#### Returns

A new `Option` object.

------------------------------------------------------------------------

### `Option$implied_volatility()`

Finds the volatility at which the pricing model reproduces the option's
last price.

The model is Black-76 when the option is priced off a future, which is
the default for an option on a commodity, a currency pair or a bond and
the case whenever the given underlying is a future, and Black-Scholes
otherwise. The underlying's price is read from UBI unless one is given,
and a figure given is taken as the same kind of price, spot or forward,
as the underlying it stands in for. The option still needs a last price
of its own, which some contracts lack.

The examples below, in order:

- Print the implied volatility of the at-the-money Nifty call.

- Compare the call's and the put's implied volatility at the same strike
  with a 6 per cent rate.

- Ask what the implied volatility would be if the index were one per
  cent higher at today's premium.

#### Usage

    Option$implied_volatility(
      risk_free_rate = OPTION_PRICING_DEFAULT_RISK_FREE_RATE,
      underlying_price = NULL
    )

#### Arguments

- `risk_free_rate`:

  The numeric annual risk-free interest rate, continuously compounded,
  such as 0.065 for 6.5 per cent.

- `underlying_price`:

  The numeric price of the underlying to use, or `NULL` to read the
  underlying's last price from UBI.

#### Details

Errors: signals `ValueError` when `underlying_price` is given and is not
above zero; `UnderlyingError` when no underlying price is given and the
option's underlying cannot be found; `ServiceUnavailableError` when UBI
has no recent quote for the option, or for the underlying when no price
is given; and another `UnifiedBrokerInterfaceError` subclass for any
other failure reported by, or on the way to, UBI.

#### Returns

The numeric annual volatility, such as 0.12 for 12 per cent, or `NULL`
when either price is unknown, when the option is at or past 15:30 India
time on its expiry date, or when the premium is below the option's
discounted intrinsic value.

#### Examples

    expiries <- EquityIndexOption$expiries(
      exchange = "nse",
      underlying_symbol = "NIFTY"
    )
    expiry_date <- expiries[[2]]
    strikes <- EquityIndexOption$strikes(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date
    )
    level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    nearest_strike <- strikes[[1]]
    for (strike in strikes) {
      if (abs(strike - level) < abs(nearest_strike - level)) {
        nearest_strike <- strike
      }
    }
    call <- EquityIndexOption$new(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date,
      strike_price = nearest_strike,
      option_type = "CE"
    )

    volatility <- call$implied_volatility()
    if (is.null(volatility)) {
      cat("No implied volatility could be found.", "\n")
    } else {
      cat(sprintf("%.2f%% a year", volatility * 100), "\n")
    }

    expiries <- EquityIndexOption$expiries(
      exchange = "nse",
      underlying_symbol = "NIFTY"
    )
    expiry_date <- expiries[[2]]
    strikes <- EquityIndexOption$strikes(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date
    )
    level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    nearest_strike <- strikes[[1]]
    for (strike in strikes) {
      if (abs(strike - level) < abs(nearest_strike - level)) {
        nearest_strike <- strike
      }
    }
    options <- list()
    for (option_type in c(
      "CE",
      "PE"
    )) {
      option <- EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiry_date,
        strike_price = nearest_strike,
        option_type = option_type
      )
      options[[length(options) + 1]] <- option
    }

    for (option in options) {
      volatility <- option$implied_volatility(risk_free_rate = 0.06)
      cat(option$option_type, volatility, "\n")
    }

    expiries <- EquityIndexOption$expiries(
      exchange = "nse",
      underlying_symbol = "NIFTY"
    )
    expiry_date <- expiries[[2]]
    strikes <- EquityIndexOption$strikes(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date
    )
    level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    nearest_strike <- strikes[[1]]
    for (strike in strikes) {
      if (abs(strike - level) < abs(nearest_strike - level)) {
        nearest_strike <- strike
      }
    }
    call <- EquityIndexOption$new(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date,
      strike_price = nearest_strike,
      option_type = "CE"
    )

    volatility <- call$implied_volatility(underlying_price = level * 1.01)
    cat("At an index 1% higher:", volatility, "\n")

------------------------------------------------------------------------

### `Option$greeks()`

Works out the option's fair price and greeks with the pricing model that
fits its underlying.

The model is Black-76 when the option is priced off a future and
Black-Scholes otherwise, as `implied_volatility()` explains, and the
answer names it. Under Black-76 delta and gamma are measured against the
future's price, and rho holds that price still, so it only discounts.
Without a volatility, the option's implied volatility is used, so the
fair price equals the last price and the greeks describe the option as
the market prices it. Theta is per calendar day, and vega and rho are
per percentage point, which is how brokers' option chains show them.

The examples below, in order:

- Print the greeks of the at-the-money Nifty call at its implied
  volatility.

- Work out the fair value of the call at a volatility of 15 per cent and
  compare it with its premium.

- Add up the delta of a straddle, one call and one put at the same
  strike, which is close to zero at the money.

#### Usage

    Option$greeks(
      risk_free_rate = OPTION_PRICING_DEFAULT_RISK_FREE_RATE,
      volatility = NULL,
      underlying_price = NULL
    )

#### Arguments

- `risk_free_rate`:

  The numeric annual risk-free interest rate, continuously compounded,
  such as 0.065 for 6.5 per cent.

- `volatility`:

  The numeric annual volatility to use, such as 0.12 for 12 per cent, or
  `NULL` to use the option's implied volatility.

- `underlying_price`:

  The numeric price of the underlying to use, or `NULL` to read the
  underlying's last price from UBI.

#### Details

Errors: signals `ValueError` when `underlying_price` or `volatility` is
given and is not above zero; `UnderlyingError` when no underlying price
is given and the option's underlying cannot be found;
`ServiceUnavailableError` when UBI has no recent quote for the option,
or for the underlying when no price is given; and another
`UnifiedBrokerInterfaceError` subclass for any other failure reported
by, or on the way to, UBI.

#### Returns

A named list with `model`, the character `"black_76"` or
`"black_scholes"`, and `volatility`, `price`, `delta`, `gamma`, `theta`,
`vega` and `rho`, each numeric, or `NULL` when the prices needed are
unknown, when the option is at or past 15:30 India time on its expiry
date, or when no implied volatility can be found.

#### Examples

    expiries <- EquityIndexOption$expiries(
      exchange = "nse",
      underlying_symbol = "NIFTY"
    )
    expiry_date <- expiries[[2]]
    strikes <- EquityIndexOption$strikes(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date
    )
    level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    nearest_strike <- strikes[[1]]
    for (strike in strikes) {
      if (abs(strike - level) < abs(nearest_strike - level)) {
        nearest_strike <- strike
      }
    }
    call <- EquityIndexOption$new(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date,
      strike_price = nearest_strike,
      option_type = "CE"
    )

    greeks <- call$greeks()
    if (is.null(greeks)) {
      cat("The greeks could not be worked out.", "\n")
    } else {
      for (name in names(greeks)) {
        value <- greeks[[name]]
        cat(name, value, "\n")
      }
    }

    expiries <- EquityIndexOption$expiries(
      exchange = "nse",
      underlying_symbol = "NIFTY"
    )
    expiry_date <- expiries[[2]]
    strikes <- EquityIndexOption$strikes(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date
    )
    level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    nearest_strike <- strikes[[1]]
    for (strike in strikes) {
      if (abs(strike - level) < abs(nearest_strike - level)) {
        nearest_strike <- strike
      }
    }
    call <- EquityIndexOption$new(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date,
      strike_price = nearest_strike,
      option_type = "CE"
    )

    greeks <- call$greeks(volatility = 0.15)
    cat("Model:", greeks[["model"]], "\n")
    cat("Fair value:", round(greeks[["price"]], 2), "\n")
    cat("Premium:", call$last_price, "\n")

    expiries <- EquityIndexOption$expiries(
      exchange = "nse",
      underlying_symbol = "NIFTY"
    )
    expiry_date <- expiries[[2]]
    strikes <- EquityIndexOption$strikes(
      exchange = "nse",
      underlying_symbol = "NIFTY",
      expiry_date = expiry_date
    )
    level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    nearest_strike <- strikes[[1]]
    for (strike in strikes) {
      if (abs(strike - level) < abs(nearest_strike - level)) {
        nearest_strike <- strike
      }
    }
    options <- list()
    for (option_type in c(
      "CE",
      "PE"
    )) {
      option <- EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiry_date,
        strike_price = nearest_strike,
        option_type = option_type
      )
      options[[length(options) + 1]] <- option
    }

    total_delta <- 0.0
    for (option in options) {
      greeks <- option$greeks()
      cat(option$option_type, round(greeks[["delta"]], 3), "\n")
      total_delta <- total_delta + greeks[["delta"]]
    }
    cat("Straddle delta:", round(total_delta, 3), "\n")

------------------------------------------------------------------------

### `Option$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Option$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
for (expiry_date in as.list(head(expiries, 5))) {
  print(expiry_date)
}

index_expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
share_expiries <- EquityOption$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
cat("NIFTY:", length(index_expiries), "\n")
cat("RELIANCE:", length(share_expiries), "\n")

expiries <- EquityOption$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
strikes <- EquityOption$strikes(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]]
)
cat(
  length(strikes),
  "strikes from",
  strikes[[1]],
  "to",
  strikes[[length(strikes)]],
  "\n"
)

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
cat(
  sprintf("Nifty at %s, at-the-money strike %s", level, nearest_strike),
  "\n"
)

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
chain <- EquityIndexOption$chain(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)
cat(nrow(chain), "contracts", "\n")
print(head(
  chain[, c(
    "strike_price",
    "option_type",
    "instrument_id"
  )]
))

expiries <- EquityOption$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
chain <- EquityOption$chain(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]]
)
print(sort(table(chain$option_type), decreasing = TRUE))

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
chain <- EquityIndexOption$chain(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[2]]
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
calls <- chain[chain$option_type == "CE", , drop = FALSE]
calls$distance <- abs(calls$strike_price - level)
nearest_calls <- head(calls[order(calls$distance), , drop = FALSE], 3)
for (instrument_id in nearest_calls$instrument_id) {
  option <- IndexOption$new(instrument_id = instrument_id)
  cat(option$strike_price, option$last_price, "\n")
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

cat(format(call), "is a call:", call$is_call, "\n")

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

for (option in options) {
  if (option$is_call) {
    cat("Call:", format(option), "\n")
  } else {
    cat("Put:", format(option), "\n")
  }
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

put <- options[[2]]
cat(format(put), "is a put:", put$is_put, "\n")

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

print(call$is_put)

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

for (option in options) {
  cat(option$option_type, option$intrinsic_value, "\n")
}

expiries <- EquityOption$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
strikes <- EquityOption$strikes(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]]
)
call <- EquityOption$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]],
  strike_price = strikes[[1]],
  option_type = "CE"
)
cat("Strike:", call$strike_price, "\n")
cat("Intrinsic value:", call$intrinsic_value, "\n")
cat("Premium:", call$last_price, "\n")

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

cat("Premium:", call$last_price, "\n")
cat("Time value:", call$time_value, "\n")

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

for (option in options) {
  cat(option$option_type, option$time_value, "\n")
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

for (option in options) {
  cat(
    option$option_type,
    option$strike_price,
    option$in_the_money,
    "\n"
  )
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[2]]
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_index <- 1
for (index in seq_along(strikes)) {
  if (abs(strikes[[index]] - level) < abs(strikes[[nearest_index]] - level)) {
    nearest_index <- index
  }
}
in_the_money_count <- 0
first_index <- max(1, nearest_index - 2)
last_index <- min(length(strikes), nearest_index + 2)
for (strike in strikes[first_index:last_index]) {
  call <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiries[[2]],
    strike_price = strike,
    option_type = "CE"
  )
  if (call$in_the_money) {
    in_the_money_count <- in_the_money_count + 1
  }
}
cat(sprintf("%s of 5 calls are in the money", in_the_money_count), "\n")

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

for (option in options) {
  cat(
    option$option_type,
    sprintf("%.3f%%", option$moneyness_percent),
    "\n"
  )
}

expiries <- EquityOption$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
strikes <- EquityOption$strikes(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]]
)
for (strike in list(
  strikes[[1]],
  strikes[[length(strikes)]]
)) {
  call <- EquityOption$new(
    exchange = "nse",
    underlying_symbol = "RELIANCE",
    expiry_date = expiries[[1]],
    strike_price = strike,
    option_type = "CE"
  )
  cat(strike, sprintf("%.2f%%", call$moneyness_percent), "\n")
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

cat(
  call$strike_price,
  "+",
  call$last_price,
  "=",
  call$breakeven_price,
  "\n"
)

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

for (option in options) {
  breakeven <- option$breakeven_price
  move <- (breakeven - level) / level * 100
  cat(option$option_type, breakeven, sprintf("%+.2f%%", move), "\n")
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

cat(call$lot_size, "units cost Rs", call$premium_per_lot, "\n")

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

budget <- 50000
for (option in options) {
  premium <- option$premium_per_lot
  cat(option$option_type, as.integer(budget %/% premium), "lots", "\n")
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

cat(
  sprintf(
    "Rs %s",
    formatC(call$notional_value, format = "f", digits = 0, big.mark = ",")
  ),
  "\n"
)

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

leverage <- call$notional_value / call$premium_per_lot
cat(
  sprintf("One rupee of premium controls Rs %.1f of index", leverage),
  "\n"
)
} # }

## ------------------------------------------------
## Method `Option$implied_volatility()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

volatility <- call$implied_volatility()
if (is.null(volatility)) {
  cat("No implied volatility could be found.", "\n")
} else {
  cat(sprintf("%.2f%% a year", volatility * 100), "\n")
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

for (option in options) {
  volatility <- option$implied_volatility(risk_free_rate = 0.06)
  cat(option$option_type, volatility, "\n")
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

volatility <- call$implied_volatility(underlying_price = level * 1.01)
cat("At an index 1% higher:", volatility, "\n")
} # }

## ------------------------------------------------
## Method `Option$greeks()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

greeks <- call$greeks()
if (is.null(greeks)) {
  cat("The greeks could not be worked out.", "\n")
} else {
  for (name in names(greeks)) {
    value <- greeks[[name]]
    cat(name, value, "\n")
  }
}

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
call <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date,
  strike_price = nearest_strike,
  option_type = "CE"
)

greeks <- call$greeks(volatility = 0.15)
cat("Model:", greeks[["model"]], "\n")
cat("Fair value:", round(greeks[["price"]], 2), "\n")
cat("Premium:", call$last_price, "\n")

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
expiry_date <- expiries[[2]]
strikes <- EquityIndexOption$strikes(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiry_date
)
level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
nearest_strike <- strikes[[1]]
for (strike in strikes) {
  if (abs(strike - level) < abs(nearest_strike - level)) {
    nearest_strike <- strike
  }
}
options <- list()
for (option_type in c(
  "CE",
  "PE"
)) {
  option <- EquityIndexOption$new(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date,
    strike_price = nearest_strike,
    option_type = option_type
  )
  options[[length(options) + 1]] <- option
}

total_delta <- 0.0
for (option in options) {
  greeks <- option$greeks()
  cat(option$option_type, round(greeks[["delta"]], 3), "\n")
  total_delta <- total_delta + greeks[["delta"]]
}
cat("Straddle delta:", round(total_delta, 3), "\n")
} # }
```
