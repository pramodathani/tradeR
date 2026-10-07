# A named group of instruments that is priced, analysed and stored as one

`AssetBasket` holds a list of `BasketMember` objects and reads what it
needs about all of them in one list request to UBI:
`POST /api/instruments/ltp`, `/ohlc`, `/quote` and `/prices` each take
the whole basket at once and answer one entry per member. The live
members report the basket as it stands now, such as its weights, its day
move, its breadth and its biggest movers. The history members line up
the members' candles and measure how they move together, such as the
correlation matrix and each member's share of the risk.

`prices()` gives candles for the basket as a whole, the sum over members
of a fixed quantity times each member's candle, so the basket inherits
every analysis class an instrument does, from moving averages to
`sharpe_ratio()` and `run_backtest()`. A weighted basket turns its
weights into quantities at the first candle of the range, starting from
`base_value`, which is how a price index moves between rebalances. The
open and close are exact. The high and low are the sums of the members'
highs and lows, an approximation, because the members do not all reach
their highs at the same moment. Volume and open interest have no meaning
for a basket and are left empty.

A weight vector, such as `weights`, is a named numeric vector whose
names are the member labels. A table indexed by time, such as
`member_closes()`, is a `data.frame` whose first column is `datetime`
followed by one column per member label. A table indexed by member, such
as `covariance_matrix()`, is a `data.frame` whose row names are the
member labels.

The generator carries `AssetBasket$KIND`, the kind stored with the
basket, `"basket"`.

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
-\> `AssetBasket`

## Public fields

- `KIND`:

  The character kind of basket a class is, such as `"index"`, stored
  with the basket so that it is rebuilt as the same class.

- `name`:

  The character name of the basket, such as `"NIFTY"` or
  `"my long-term portfolio"`.

- `members`:

  The list of `BasketMember` objects the basket holds, in order.

- `linked_instrument`:

  The `Instrument` the basket describes the contents of, such as the
  NIFTY index or an exchange traded fund, or `NULL` when it describes no
  single instrument.

- `unmapped_weight`:

  The numeric share of the whole, between 0 and 1, held in things UBI
  cannot price, such as a fund's cash, which the members' weights leave
  out.

- `base_value`:

  The numeric value the basket's candles start from at the first candle
  of a range when its members are weighted rather than counted.

## Active bindings

- `instruments`:

  The list of `Instrument` objects the basket holds, in member order.

- `size`:

  The integer number of members in the basket.

- `labels`:

  A character vector of member labels, such as `"nse:INFY"`, in member
  order.

- `weights`:

  A named numeric vector of weights whose names are the member labels,
  normalised to sum to 1, or equal weights when no member has a weight.

- `last_prices`:

  A `data.frame` with one row per member, holding `label`,
  `instrument_id`, `last_price`, `last_trade_time` and an `error` that
  is `NA` unless UBI had no price for the member, read from UBI in one
  request on every access.

- `ohlc`:

  A `data.frame` with one row per member, holding `label`,
  `instrument_id`, `open`, `high`, `low`, `last_price`,
  `previous_close`, `change_percent` and an `error` that is `NA` unless
  UBI had no quote for the member, read from UBI in one request on every
  access.

- `quotes`:

  A `data.frame` with one row per member, holding `label`,
  `instrument_id`, every field of UBI's unified quote such as
  `last_price`, `volume`, `oi` and `depth`, and an `error` that is `NA`
  unless UBI had no quote for the member, read from UBI in one request
  on every access. A field whose values are not single values, such as
  `depth`, is a list column.

- `day_change_percent`:

  The numeric weighted move of the basket since the previous close, in
  percent, such as 0.8, or `NULL` when any member has no quote, read
  from UBI on every access.

- `advancers`:

  The integer number of members trading above their previous close, read
  from UBI on every access.

- `decliners`:

  The integer number of members trading below their previous close, read
  from UBI on every access.

- `breadth`:

  A named list counting the members that are `advancers`, `decliners`,
  `unchanged` and `unavailable` since the previous close, each an
  integer, with the numeric `advance_decline_ratio` of advancers to
  decliners or `NULL` when nothing declined, read from UBI on every
  access.

- `exposure_by_segment`:

  A named numeric vector of the total weight in each segment, named by
  segment such as `"nse_equities"`, largest first.

- `exposure_by_exchange`:

  A named numeric vector of the total weight on each exchange, named by
  exchange such as `"nse"`, largest first.

- `concentration`:

  The numeric Herfindahl index of the weights, the sum of their squares,
  which is 1 for a single holding and 1 divided by the size for equal
  weights.

- `effective_number_of_members`:

  The numeric number of equal-weighted members that would be as
  concentrated as this basket, which is 1 divided by the Herfindahl
  index.

- `largest_weight`:

  The numeric weight of the basket's biggest member.

## Methods

### Public methods

- [`AssetBasket$new()`](#method-AssetBasket-initialize)

- [`AssetBasket$format()`](#method-AssetBasket-format)

- [`AssetBasket$print()`](#method-AssetBasket-print)

- [`AssetBasket$member_prices()`](#method-AssetBasket-member_prices)

- [`AssetBasket$member_closes()`](#method-AssetBasket-member_closes)

- [`AssetBasket$member_returns()`](#method-AssetBasket-member_returns)

- [`AssetBasket$covariance_matrix()`](#method-AssetBasket-covariance_matrix)

- [`AssetBasket$correlation_matrix()`](#method-AssetBasket-correlation_matrix)

- [`AssetBasket$risk_contributions()`](#method-AssetBasket-risk_contributions)

- [`AssetBasket$diversification_ratio()`](#method-AssetBasket-diversification_ratio)

- [`AssetBasket$return_contributions()`](#method-AssetBasket-return_contributions)

- [`AssetBasket$top_gainers()`](#method-AssetBasket-top_gainers)

- [`AssetBasket$top_losers()`](#method-AssetBasket-top_losers)

- [`AssetBasket$overlap_with()`](#method-AssetBasket-overlap_with)

- [`AssetBasket$add_member()`](#method-AssetBasket-add_member)

- [`AssetBasket$remove_member()`](#method-AssetBasket-remove_member)

- [`AssetBasket$document()`](#method-AssetBasket-document)

- [`AssetBasket$prices()`](#method-AssetBasket-prices)

- [`AssetBasket$clone()`](#method-AssetBasket-clone)

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

### `AssetBasket$new()`

Initialises the basket and checks its members.

#### Usage

    AssetBasket$new(
      name,
      members,
      linked_instrument = NULL,
      unmapped_weight = 0,
      unified_broker_interface = NULL
    )

#### Arguments

- `name`:

  The character name of the basket.

- `members`:

  A list of `BasketMember` objects with at least one member, each a
  different instrument, and either every member or no member given a
  weight.

- `linked_instrument`:

  The `Instrument` whose contents the basket describes, or `NULL`.

- `unmapped_weight`:

  The numeric share of the whole, between 0 and 1, held outside the
  members.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to send requests through, or `NULL` to
  share the one every instrument uses.

#### Details

Errors: signals `BasketMemberError` when `members` is empty, names an
instrument twice, or gives weights to only some members; and
`ValueError` when `unmapped_weight` is not between 0 and 1.

#### Returns

A new `AssetBasket` object.

------------------------------------------------------------------------

### `AssetBasket$format()`

Describes the basket by its class, name and size.

#### Usage

    AssetBasket$format(...)

#### Arguments

- `...`:

  Ignored, accepted so that
  [`format()`](https://rdrr.io/r/base/format.html) works.

#### Returns

A character value such as `"Index(name='NIFTY', size=50)"`.

------------------------------------------------------------------------

### `AssetBasket$print()`

Prints the description [`format()`](https://rdrr.io/r/base/format.html)
gives.

#### Usage

    AssetBasket$print(...)

#### Arguments

- `...`:

  Ignored.

#### Returns

The basket, invisibly.

------------------------------------------------------------------------

### `AssetBasket$member_prices()`

Fetches every member's candles for a range in one request.

#### Usage

    AssetBasket$member_prices(
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

Errors: signals `BasketMemberError` when UBI answered an error for one
or more members, all of which the message lists; `BadRequestError` when
the range or interval is invalid; and another
`UnifiedBrokerInterfaceError` subclass for any other failure reported
by, or on the way to, UBI.

#### Returns

A `data.frame` with one row per member and candle, sorted by label and
time, holding `label`, `instrument_id`, `exchange`, `segment`,
`interval`, `datetime` in India time, `open`, `high`, `low`, `close`,
`volume` and `oi`, plus any other column UBI sends such as
`price_factor`, or `NULL` when no member has a candle in the range. A
member with no candles has no rows.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    frame <- basket$member_prices(days = 10)
    print(tail(frame[, c("label", "datetime", "close")], 6))

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    frame <- banks$member_prices(
      interval = "day",
      from_date = "2026-06-01",
      to_date = "2026-09-25"
    )
    print(table(frame$label))

------------------------------------------------------------------------

### `AssetBasket$member_closes()`

Lines up every member's closing prices by time.

Only the candles every member has are kept, so a member listed during
the range shortens it.

#### Usage

    AssetBasket$member_closes(
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

Errors: signals `BasketMemberError` when UBI answered an error for one
or more members; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

A `data.frame` with a `datetime` column followed by one numeric column
of closes per member label, in member order, or `NULL` when any member
has no candles in the range or no candle is shared by all.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    closes <- basket$member_closes(days = 30)
    print(tail(closes))

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    closes <- banks$member_closes(days = 90)
    for (label in banks$labels) {
      normalised <- closes[[label]] / closes[[label]][[1]] * 100
      cat(label, round(normalised[[length(normalised)]], 1), "\n")
    }

------------------------------------------------------------------------

### `AssetBasket$member_returns()`

Calculates every member's return from each shared candle to the next.

#### Usage

    AssetBasket$member_returns(
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

Errors: signals `BasketMemberError` when UBI answered an error for one
or more members; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

A `data.frame` with a `datetime` column followed by one numeric column
of fractional returns per member label, or `NULL` when there are fewer
than two shared candles.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    returns <- basket$member_returns(days = 14)
    print(returns)

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    returns <- banks$member_returns(days = 365)
    volatilities <- c()
    for (label in banks$labels) {
      volatilities[[label]] <- sd(returns[[label]])
    }
    print(sort(volatilities))

------------------------------------------------------------------------

### `AssetBasket$covariance_matrix()`

Calculates the covariance of every pair of members' returns over one
candle.

#### Usage

    AssetBasket$covariance_matrix(
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

Errors: signals `BasketMemberError` when UBI answered an error for one
or more members; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

A square `data.frame` whose row names and column names are the member
labels, or `NULL` when there are fewer than three shared candles.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    print(basket$covariance_matrix(days = 180))

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    covariance <- banks$covariance_matrix(days = 365)
    print(round(covariance * 252, 4))

------------------------------------------------------------------------

### `AssetBasket$correlation_matrix()`

Calculates the Pearson correlation of every pair of members' returns.

A value near 1 means two members rise and fall together and add little
diversification to each other.

#### Usage

    AssetBasket$correlation_matrix(
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

Errors: signals `BasketMemberError` when UBI answered an error for one
or more members; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

A square `data.frame` of values between -1 and 1, whose row names and
column names are the member labels, or `NULL` when there are fewer than
three shared candles.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    print(round(basket$correlation_matrix(days = 365), 2))

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    correlation <- banks$correlation_matrix(days = 365)
    lowest_pair <- NULL
    lowest_value <- 2
    for (first in names(correlation)) {
      for (second in names(correlation)) {
        value <- correlation[first, second]
        if (first < second && value < lowest_value) {
          lowest_value <- value
          lowest_pair <- sprintf("%s and %s", first, second)
        }
      }
    }
    cat(lowest_pair, round(lowest_value, 2), "\n")

------------------------------------------------------------------------

### `AssetBasket$risk_contributions()`

Splits the basket's volatility into each member's share of it, at
today's weights.

A member's share is its weight times its covariance with the whole
basket, divided by the basket's variance, so the shares add up to 1. A
member whose share is far above its weight is where the basket's risk
really sits.

#### Usage

    AssetBasket$risk_contributions(
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

Errors: signals `BasketMemberError` when UBI answered an error for one
or more members; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

A `data.frame` whose row names are the member labels, with numeric
`weight` and `risk_contribution` columns, largest contribution first, or
`NULL` when there are fewer than three shared candles or the basket
never moved.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    print(round(basket$risk_contributions(days = 180), 3))

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    contributions <- banks$risk_contributions(days = 365)
    for (label in rownames(contributions)) {
      row <- contributions[label, ]
      if (row$risk_contribution > row$weight * 1.1) {
        cat(sprintf("%s carries more risk than its weight\n", label))
      }
    }
    print(round(contributions, 3))

------------------------------------------------------------------------

### `AssetBasket$diversification_ratio()`

Divides the weighted average of the members' volatilities by the
basket's own volatility, at today's weights.

It is 1 when every member moves in lockstep, and the further above 1 it
is, the more the members' moves cancel out.

#### Usage

    AssetBasket$diversification_ratio(
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

Errors: signals `BasketMemberError` when UBI answered an error for one
or more members; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

The numeric diversification ratio, or `NULL` when there are fewer than
three shared candles or the basket never moved.

#### Examples

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    ratio <- banks$diversification_ratio(days = 365)
    cat(sprintf("Diversification ratio: %.2f\n", ratio))

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    short_ratio <- basket$diversification_ratio(days = 90)
    long_ratio <- basket$diversification_ratio(days = 730)
    cat(sprintf("90 days: %.2f, 730 days: %.2f\n", short_ratio, long_ratio))

------------------------------------------------------------------------

### `AssetBasket$return_contributions()`

Splits the basket's return over the range into what each member added.

Each member's contribution is its share of the basket's value at the
first candle times its own return, so the contributions add up to the
basket's `cumulative_return()` over the same range.

#### Usage

    AssetBasket$return_contributions(
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

Errors: signals `BasketMemberError` when UBI answered an error for one
or more members; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

A `data.frame` whose row names are the member labels, with numeric
`starting_weight`, `member_return` and `contribution` columns, largest
contribution first, or `NULL` when there are fewer than two shared
candles.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    print(round(basket$return_contributions(days = 90), 4))

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    contributions <- banks$return_contributions(days = 180)
    print(round(sum(contributions$contribution), 6))
    print(round(banks$cumulative_return(days = 180), 6))

------------------------------------------------------------------------

### `AssetBasket$top_gainers()`

Finds the members that have risen most since the previous close.

#### Usage

    AssetBasket$top_gainers(count = 5)

#### Arguments

- `count`:

  The integer most members to return.

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI
refused the request or could not be reached.

#### Returns

A `data.frame` of `ohlc` rows, biggest rise first, leaving out members
with no quote.

#### Examples

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    print(banks$top_gainers(count = 2)[, c("label", "change_percent")])

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    best <- basket$top_gainers(count = 1)
    if (nrow(best) == 0) {
      cat("No member has a quote.\n")
    } else {
      cat(best$label[[1]], best$change_percent[[1]], "\n")
    }

------------------------------------------------------------------------

### `AssetBasket$top_losers()`

Finds the members that have fallen most since the previous close.

#### Usage

    AssetBasket$top_losers(count = 5)

#### Arguments

- `count`:

  The integer most members to return.

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI
refused the request or could not be reached.

#### Returns

A `data.frame` of `ohlc` rows, biggest fall first, leaving out members
with no quote.

#### Examples

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    print(banks$top_losers(count = 2)[, c("label", "change_percent")])

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    losers <- basket$top_losers(count = basket$size)
    print(losers[losers$change_percent < -0.5, c("label", "change_percent")])

------------------------------------------------------------------------

### `AssetBasket$overlap_with()`

Measures how much of this basket's weight another basket also holds.

The overlap is the sum, over the instruments both hold, of the smaller
of the two weights. It is 1 for two identical baskets and 0 for two with
nothing in common, and it is the usual way to tell whether two funds are
really different.

#### Usage

    AssetBasket$overlap_with(other)

#### Arguments

- `other`:

  The `AssetBasket` to compare with.

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when a basket
whose weights come from live prices, such as a `Portfolio`, could not
read them.

#### Returns

The numeric overlap between 0 and 1.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    broad_weights <- c(
      INFY = 0.3,
      RELIANCE = 0.4,
      HDFCBANK = 0.3
    )
    broad_members <- list()
    for (symbol in names(broad_weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      broad_members[[length(broad_members) + 1]] <- BasketMember$new(
        share,
        weight = broad_weights[[symbol]]
      )
    }
    broad <- AssetBasket$new(name = "broad", members = broad_members)
    cat(sprintf("Overlap: %.0f%%\n", basket$overlap_with(broad) * 100))

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    print(banks$overlap_with(banks))

------------------------------------------------------------------------

### `AssetBasket$add_member()`

Adds a member to the basket in memory, which `BasketStore$save()` then
stores.

#### Usage

    AssetBasket$add_member(member)

#### Arguments

- `member`:

  The `BasketMember` to add, weighted if and only if the other members
  are.

#### Details

Errors: signals `BasketMemberError` when the instrument is already in
the basket, or the member's weight does not match the others'.

#### Returns

`NULL`, invisibly.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    wipro <- Equity$new(exchange = "nse", symbol = "WIPRO")
    basket$add_member(BasketMember$new(wipro, weight = 0.1))
    print(round(basket$weights, 3))

    tryCatch(
      basket$add_member(BasketMember$new(wipro)),
      BasketMemberError = function(error) print(conditionMessage(error))
    )

------------------------------------------------------------------------

### `AssetBasket$remove_member()`

Removes an instrument from the basket in memory, which
`BasketStore$save()` then stores.

#### Usage

    AssetBasket$remove_member(instrument)

#### Arguments

- `instrument`:

  The `Instrument` to remove.

#### Details

Errors: signals `BasketMemberError` when the instrument is not in the
basket, or it is the only member.

#### Returns

`NULL`, invisibly.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    basket$remove_member(basket$instruments[[1]])
    print(basket$weights)

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    tryCatch(
      basket$remove_member(infosys),
      BasketMemberError = function(error) print(conditionMessage(error))
    )

------------------------------------------------------------------------

### `AssetBasket$document()`

Describes the basket as a named list for storing in MongoDB.

Subclasses add their own settings to the named list.

#### Usage

    AssetBasket$document(effective_date = NULL)

#### Arguments

- `effective_date`:

  The first day the basket is in effect as a `Date` or a `"YYYY-MM-DD"`
  character value, or `NULL` for today.

#### Returns

A named list with `name`, `kind`, `effective_date` as `"YYYY-MM-DD"`
text, `linked_instrument_id`, `unmapped_weight`, `base_value` and a
`members` list of named lists.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    document <- basket$document(effective_date = "2026-10-01")
    cat(document$name, document$kind, document$effective_date, "\n")
    print(length(document$members))

    for (member_document in basket$document()$members) {
      cat(member_document$symbol, member_document$instrument_id, "\n")
    }

------------------------------------------------------------------------

### `AssetBasket$prices()`

Builds candles for the basket as a whole from its members' candles.

Each candle is the sum over members of a fixed quantity times the
member's candle. A weighted basket takes its quantities from its weights
at the first candle of the range, so the first close equals
`base_value`; a `Portfolio` uses the quantities it holds. The open and
close are exact; the high and low are an approximation, because the
members do not all reach their highs and lows at the same moment.
`volume` and `oi` are empty.

#### Usage

    AssetBasket$prices(
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

Errors: signals `BasketMemberError` when UBI answered an error for one
or more members; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

A `data.frame` sorted by time with `exchange` set to `NA`, `segment` set
to the basket's `KIND`, `interval`, `datetime`, `open`, `high`, `low`,
`close`, `volume` and `oi` columns, the last two all `NA`, or `NULL`
when any member has no candles in the range or no candle is shared by
all.

#### Examples

    weights <- c(
      INFY = 0.5,
      TCS = 0.3,
      HCLTECH = 0.2
    )
    members <- list()
    for (symbol in names(weights)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        weight = weights[[symbol]]
      )
    }
    basket <- AssetBasket$new(name = "IT shares", members = members)
    frame <- basket$prices(days = 30)
    print(tail(frame[, c("datetime", "open", "high", "low", "close")]))

    bank_symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "AXISBANK",
      "KOTAKBANK",
      "SBIN"
    )
    bank_members <- list()
    for (symbol in bank_symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    }
    banks <- AssetBasket$new(name = "banks", members = bank_members)
    frame <- banks$prices(from_date = "2026-06-01", to_date = "2026-09-25")
    first_close <- frame$close[[1]]
    last_close <- frame$close[[nrow(frame)]]
    cat(sprintf("Return: %.2f%%\n", (last_close / first_close - 1) * 100))

    print(basket$sharpe_ratio(risk_free_rate = 0.065, days = 365))

------------------------------------------------------------------------

### `AssetBasket$clone()`

The objects of this class are cloneable with this method.

#### Usage

    AssetBasket$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)

for (instrument in basket$instruments) {
  cat(instrument$symbol, instrument$segment, "\n")
}
first_instrument <- basket$instruments[[1]]
cat(first_instrument$symbol, first_instrument$last_price, "\n")

cat(sprintf("%s holds %d shares\n", banks$name, banks$size))
banks$add_member(
  BasketMember$new(Equity$new(exchange = "nse", symbol = "INDUSINDBK"))
)
print(banks$size)

print(basket$labels)
for (label in basket$labels) {
  cat(sprintf("%s: %.0f%%\n", label, basket$weights[[label]] * 100))
}

print(basket$weights)
print(banks$weights)
cat(sprintf("Total: %s\n", sum(banks$weights)))

print(basket$last_prices[, c("label", "last_price")])
frame <- banks$last_prices
missing <- frame[!is.na(frame$error), ]
if (nrow(missing) == 0) {
  cat("Every member has a last price.\n")
} else {
  print(missing[, c("label", "error")])
}

print(basket$ohlc[, c("label", "open", "high", "low", "last_price")])
frame <- banks$ohlc
frame$range_percent <- (frame$high - frame$low) / frame$previous_close * 100
print(round(frame$range_percent, 2))

print(banks$quotes[, c("label", "last_price", "volume")])
print(basket$quotes[, c("label", "stale", "source")])

change <- basket$day_change_percent
if (is.null(change)) {
  cat("A member has no quote.\n")
} else {
  cat(sprintf("%s: %+.2f%%\n", basket$name, change))
}
equal_members <- list()
for (member in basket$members) {
  equal_members[[length(equal_members) + 1]] <- BasketMember$new(
    member$instrument
  )
}
equal_basket <- AssetBasket$new(
  name = "IT shares, equal",
  members = equal_members
)
print(c(
  basket$day_change_percent,
  equal_basket$day_change_percent
))

cat(sprintf("%d of %d banks are up\n", banks$advancers, banks$size))
if (banks$advancers > banks$size / 2) {
  cat("Most banks are up.\n")
} else {
  cat("Most banks are not up.\n")
}
cat(sprintf("%d of %d banks are down\n", banks$decliners, banks$size))
cat(sprintf("up %d, down %d\n", basket$advancers, basket$decliners))

str(banks$breadth)
ratio <- banks$breadth$advance_decline_ratio
if (is.null(ratio)) {
  cat("No member declined.\n")
} else {
  cat(sprintf("Advance-decline ratio: %.2f\n", ratio))
}

mixed <- AssetBasket$new(
  name = "shares and gold",
  members = list(
    BasketMember$new(
      Equity$new(exchange = "nse", symbol = "INFY"),
      weight = 60
    ),
    BasketMember$new(
      ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES"),
      weight = 40
    )
  )
)
print(mixed$exposure_by_segment)
print(basket$exposure_by_segment)

two_exchanges <- AssetBasket$new(
  name = "two exchanges",
  members = list(
    BasketMember$new(
      Equity$new(exchange = "nse", symbol = "INFY"),
      weight = 0.7
    ),
    BasketMember$new(
      Equity$new(exchange = "bse", symbol = "TCS"),
      weight = 0.3
    )
  )
)
print(two_exchanges$exposure_by_exchange)
exposure <- basket$exposure_by_exchange
cat(names(exposure)[[1]], exposure[[1]], "\n")

cat(sprintf("Concentration: %.3f\n", basket$concentration))
print(c(
  banks$concentration,
  1 / banks$size
))

effective <- basket$effective_number_of_members
cat(sprintf("%d members act like %.1f equal ones\n", basket$size, effective))
if (basket$effective_number_of_members < basket$size * 0.9) {
  cat("The weights are lopsided.\n")
} else {
  cat("The weights are close to equal.\n")
}

cat(sprintf("Largest weight: %.0f%%\n", basket$largest_weight * 100))
if (basket$largest_weight > 0.4) {
  cat("One member is above the 40% limit.\n")
} else {
  cat("Every member is within the limit.\n")
}

basket$sharpe_ratio(risk_free_rate = 0.065, days = 365)
} # }

## ------------------------------------------------
## Method `AssetBasket$member_prices()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
frame <- basket$member_prices(days = 10)
print(tail(frame[, c("label", "datetime", "close")], 6))

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
frame <- banks$member_prices(
  interval = "day",
  from_date = "2026-06-01",
  to_date = "2026-09-25"
)
print(table(frame$label))
} # }

## ------------------------------------------------
## Method `AssetBasket$member_closes()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
closes <- basket$member_closes(days = 30)
print(tail(closes))

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
closes <- banks$member_closes(days = 90)
for (label in banks$labels) {
  normalised <- closes[[label]] / closes[[label]][[1]] * 100
  cat(label, round(normalised[[length(normalised)]], 1), "\n")
}
} # }

## ------------------------------------------------
## Method `AssetBasket$member_returns()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
returns <- basket$member_returns(days = 14)
print(returns)

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
returns <- banks$member_returns(days = 365)
volatilities <- c()
for (label in banks$labels) {
  volatilities[[label]] <- sd(returns[[label]])
}
print(sort(volatilities))
} # }

## ------------------------------------------------
## Method `AssetBasket$covariance_matrix()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
print(basket$covariance_matrix(days = 180))

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
covariance <- banks$covariance_matrix(days = 365)
print(round(covariance * 252, 4))
} # }

## ------------------------------------------------
## Method `AssetBasket$correlation_matrix()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
print(round(basket$correlation_matrix(days = 365), 2))

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
correlation <- banks$correlation_matrix(days = 365)
lowest_pair <- NULL
lowest_value <- 2
for (first in names(correlation)) {
  for (second in names(correlation)) {
    value <- correlation[first, second]
    if (first < second && value < lowest_value) {
      lowest_value <- value
      lowest_pair <- sprintf("%s and %s", first, second)
    }
  }
}
cat(lowest_pair, round(lowest_value, 2), "\n")
} # }

## ------------------------------------------------
## Method `AssetBasket$risk_contributions()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
print(round(basket$risk_contributions(days = 180), 3))

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
contributions <- banks$risk_contributions(days = 365)
for (label in rownames(contributions)) {
  row <- contributions[label, ]
  if (row$risk_contribution > row$weight * 1.1) {
    cat(sprintf("%s carries more risk than its weight\n", label))
  }
}
print(round(contributions, 3))
} # }

## ------------------------------------------------
## Method `AssetBasket$diversification_ratio()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
ratio <- banks$diversification_ratio(days = 365)
cat(sprintf("Diversification ratio: %.2f\n", ratio))

weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
short_ratio <- basket$diversification_ratio(days = 90)
long_ratio <- basket$diversification_ratio(days = 730)
cat(sprintf("90 days: %.2f, 730 days: %.2f\n", short_ratio, long_ratio))
} # }

## ------------------------------------------------
## Method `AssetBasket$return_contributions()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
print(round(basket$return_contributions(days = 90), 4))

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
contributions <- banks$return_contributions(days = 180)
print(round(sum(contributions$contribution), 6))
print(round(banks$cumulative_return(days = 180), 6))
} # }

## ------------------------------------------------
## Method `AssetBasket$top_gainers()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
print(banks$top_gainers(count = 2)[, c("label", "change_percent")])

weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
best <- basket$top_gainers(count = 1)
if (nrow(best) == 0) {
  cat("No member has a quote.\n")
} else {
  cat(best$label[[1]], best$change_percent[[1]], "\n")
}
} # }

## ------------------------------------------------
## Method `AssetBasket$top_losers()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
print(banks$top_losers(count = 2)[, c("label", "change_percent")])

weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
losers <- basket$top_losers(count = basket$size)
print(losers[losers$change_percent < -0.5, c("label", "change_percent")])
} # }

## ------------------------------------------------
## Method `AssetBasket$overlap_with()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
broad_weights <- c(
  INFY = 0.3,
  RELIANCE = 0.4,
  HDFCBANK = 0.3
)
broad_members <- list()
for (symbol in names(broad_weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  broad_members[[length(broad_members) + 1]] <- BasketMember$new(
    share,
    weight = broad_weights[[symbol]]
  )
}
broad <- AssetBasket$new(name = "broad", members = broad_members)
cat(sprintf("Overlap: %.0f%%\n", basket$overlap_with(broad) * 100))

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
print(banks$overlap_with(banks))
} # }

## ------------------------------------------------
## Method `AssetBasket$add_member()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
wipro <- Equity$new(exchange = "nse", symbol = "WIPRO")
basket$add_member(BasketMember$new(wipro, weight = 0.1))
print(round(basket$weights, 3))

tryCatch(
  basket$add_member(BasketMember$new(wipro)),
  BasketMemberError = function(error) print(conditionMessage(error))
)
} # }

## ------------------------------------------------
## Method `AssetBasket$remove_member()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
basket$remove_member(basket$instruments[[1]])
print(basket$weights)

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
tryCatch(
  basket$remove_member(infosys),
  BasketMemberError = function(error) print(conditionMessage(error))
)
} # }

## ------------------------------------------------
## Method `AssetBasket$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
document <- basket$document(effective_date = "2026-10-01")
cat(document$name, document$kind, document$effective_date, "\n")
print(length(document$members))

for (member_document in basket$document()$members) {
  cat(member_document$symbol, member_document$instrument_id, "\n")
}
} # }

## ------------------------------------------------
## Method `AssetBasket$prices()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
weights <- c(
  INFY = 0.5,
  TCS = 0.3,
  HCLTECH = 0.2
)
members <- list()
for (symbol in names(weights)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    weight = weights[[symbol]]
  )
}
basket <- AssetBasket$new(name = "IT shares", members = members)
frame <- basket$prices(days = 30)
print(tail(frame[, c("datetime", "open", "high", "low", "close")]))

bank_symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)
bank_members <- list()
for (symbol in bank_symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
}
banks <- AssetBasket$new(name = "banks", members = bank_members)
frame <- banks$prices(from_date = "2026-06-01", to_date = "2026-09-25")
first_close <- frame$close[[1]]
last_close <- frame$close[[nrow(frame)]]
cat(sprintf("Return: %.2f%%\n", (last_close / first_close - 1) * 100))

print(basket$sharpe_ratio(risk_free_rate = 0.065, days = 365))
} # }
```
