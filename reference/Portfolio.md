# A basket of instruments held in known quantities

`Portfolio` gives every member a quantity, and optionally the average
price it was bought at. It can be built by hand, or read from the
account with `Portfolio$from_holdings()` or
`Portfolio$from_positions()`, which build every member from one list
request. Its weights are the members' shares of today's value, and its
candles are what the same quantities would have been worth at each
candle, so the inherited `sharpe_ratio()` or `maximum_drawdown()`
describe the portfolio as it is held now.

`place_orders()` sends one market order per member in a single
`POST /api/orders/place` list request, which UBI's order engine places
in parallel at whichever broker each order suits; it does not use UBI's
`basket` synthetic order, which is capped at 25 legs and sends every leg
to one broker. `rebalance_trades()` works out the buys and sells that
would move the portfolio to another basket's weights, and `rebalance()`
sends them. The quantities are floored to whole units and sent as
computed, with no lot size or tick size check, because UBI checks orders
itself. UBI's order engine sends each market order as a
`marketable_limit`, a limit two ticks past the other side's best price
that follows the book and is cancelled after 30 seconds, so a member
with nobody on the other side of the book or no fresh quote gets HTTP
409 in its row and an order that has not filled within the 30 seconds is
left part filled; `as_marketable_limit = FALSE` sends real market orders
instead.

The class generator carries `Portfolio$KIND`, `"portfolio"`, and two
functions that stand in for Python's class methods:

- `Portfolio$from_holdings(name = "holdings", unified_broker_interface = NULL)`
  builds a portfolio of the account's long-term holdings, as UBI reports
  them now, with one member per holding carrying its quantity and
  average price. It signals `BasketMemberError` when the account holds
  nothing or UBI could not find a held instrument, and a
  `UnifiedBrokerInterfaceError` subclass when UBI refused the request or
  could not be reached.

- `Portfolio$from_positions(name = "positions", day = FALSE, unified_broker_interface = NULL)`
  builds a portfolio of the account's open positions, today's when `day`
  is `TRUE` and the net ones otherwise, with one member per instrument
  with a non-zero position. An instrument held under more than one
  product, such as intraday and carry, becomes one member whose quantity
  is the total; its average price is then left unknown, because the
  products' prices cannot be added. It signals `BasketMemberError` when
  no position is open or UBI could not find a position's instrument, and
  a `UnifiedBrokerInterfaceError` subclass when UBI refused the request
  or could not be reached.

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
[`AssetBasket`](https://pramodathani.github.io/tradeR/reference/AssetBasket.md)
-\> `Portfolio`

## Public fields

- `KIND`:

  The character kind stored with the portfolio, `"portfolio"`.

## Active bindings

- `quantities`:

  A named numeric vector of each member's quantity, named by member
  label.

- `values`:

  A named numeric vector of each member's value in rupees at its last
  price, negative for a short position, named by member label, or `NULL`
  when any member has no last price; read from UBI in one request on
  every access.

- `value`:

  The numeric value in rupees of the whole portfolio at last prices, or
  `NULL` when any member has no last price, read from UBI on every
  access.

- `weights`:

  A named numeric vector of each member's share of the portfolio's gross
  value at last prices, named by member label, where a short position
  has a negative weight and the absolute weights sum to 1, read from UBI
  on every access. Reading it signals `BasketMemberError` when a member
  has no last price.

- `invested_value`:

  The numeric amount in rupees paid for the portfolio, the sum of
  quantity times average price, or `NULL` when any member's average
  price is unknown.

- `unrealized_pnl`:

  The numeric profit in rupees of the portfolio's value over what was
  paid for it, or `NULL` when the value or any average price is unknown,
  read from UBI on every access.

- `day_pnl`:

  The numeric profit in rupees since the previous close, the sum of
  quantity times the change from the previous close to the last price,
  or `NULL` when any member has no quote, read from UBI on every access.

- `day_change_percent`:

  The numeric move of the portfolio's value since the previous close, in
  percent, or `NULL` when any member has no quote or the previous value
  is zero, read from UBI on every access.

## Methods

### Public methods

- [`Portfolio$new()`](#method-Portfolio-initialize)

- [`Portfolio$place_orders()`](#method-Portfolio-place_orders)

- [`Portfolio$rebalance_trades()`](#method-Portfolio-rebalance_trades)

- [`Portfolio$rebalance()`](#method-Portfolio-rebalance)

- [`Portfolio$clone()`](#method-Portfolio-clone)

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
- [`AssetBasket$add_member()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-add_member)
- [`AssetBasket$correlation_matrix()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-correlation_matrix)
- [`AssetBasket$covariance_matrix()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-covariance_matrix)
- [`AssetBasket$diversification_ratio()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-diversification_ratio)
- [`AssetBasket$document()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-document)
- [`AssetBasket$format()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-format)
- [`AssetBasket$member_closes()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-member_closes)
- [`AssetBasket$member_prices()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-member_prices)
- [`AssetBasket$member_returns()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-member_returns)
- [`AssetBasket$overlap_with()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-overlap_with)
- [`AssetBasket$prices()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-prices)
- [`AssetBasket$print()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-print)
- [`AssetBasket$remove_member()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-remove_member)
- [`AssetBasket$return_contributions()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-return_contributions)
- [`AssetBasket$risk_contributions()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-risk_contributions)
- [`AssetBasket$top_gainers()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-top_gainers)
- [`AssetBasket$top_losers()`](https://pramodathani.github.io/tradeR/reference/AssetBasket.html#method-top_losers)

------------------------------------------------------------------------

### `Portfolio$new()`

Initialises the portfolio and checks that every member has a quantity.

#### Usage

    Portfolio$new(name, members, unified_broker_interface = NULL)

#### Arguments

- `name`:

  The character name of the portfolio.

- `members`:

  A list of `BasketMember` objects, each with a quantity, negative for a
  short position, and each a different instrument.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to send requests through, or `NULL` to
  share the one every instrument uses.

#### Details

Errors: signals `BasketMemberError` when `members` is empty, names an
instrument twice, or has a member without a quantity.

#### Returns

A new `Portfolio` object.

------------------------------------------------------------------------

### `Portfolio$place_orders()`

Sends one market order per member for its quantity, all in one list
request.

With `buy`, each member's quantity is bought, and a negative quantity is
sold instead; with `sell`, the other way round. This buys a portfolio
built by hand or by `Index$to_portfolio()`, and sells one to close it.
The orders are placed in parallel and not as one unit, so some can be
accepted while others are refused, and each row of the answer says what
happened to its order.

UBI's order engine sends each order as a `marketable_limit`: a limit two
ticks past the other side's best price, moved after that price until it
fills, with whatever is left cancelled 30 seconds after it was placed. A
member that cannot be priced, because nobody is on the other side of its
book, no live quote has arrived or the quote is marked stale, gets HTTP
409 in its row and nothing is sent for it. Pass
`as_marketable_limit = FALSE` to send real market orders, which a member
with no live quote, such as a mutual fund, needs.

#### Usage

    Portfolio$place_orders(
      product,
      transaction_type = ASSET_BASKETS_BUY,
      validity = "day",
      tag = NULL,
      dry_run = FALSE,
      as_marketable_limit = TRUE
    )

#### Arguments

- `product`:

  The character product every order is sent with, such as `"cnc"` for
  delivery or `"mis"` for intraday.

- `transaction_type`:

  The character side for a positive quantity, `"buy"` or `"sell"`.

- `validity`:

  The character validity of every order, such as `"day"`.

- `tag`:

  A character tag to put on every order, or `NULL`.

- `dry_run`:

  A logical that is `TRUE` to have UBI build every order without sending
  it.

- `as_marketable_limit`:

  A logical that is `TRUE` to let UBI's order engine send each order as
  a limit that follows the other side of the book for up to 30 seconds,
  and `FALSE` to send market orders to the brokers at once.

#### Details

Errors: signals `BadRequestError` when UBI refused the whole list, such
as one longer than its limit of 500 orders; `ServiceUnavailableError`
when UBI's order engine is not running, so nothing was placed; and
another `UnifiedBrokerInterfaceError` subclass for any other failure of
the whole request.

#### Returns

A `data.frame` with one row per order, holding `label`, `instrument_id`,
`transaction_type`, `quantity`, the entry's HTTP `status`, the `broker`
UBI chose, `outcome`, `order_id`, `parent_id`, `intent_id` and `error`.

#### Examples

    quantities <- c(
      IDEA = 100,
      INFY = 5,
      TCS = 2
    )
    average_prices <- c(
      IDEA = 12.5,
      INFY = 1450,
      TCS = 3100
    )
    members <- list()
    for (symbol in names(quantities)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        quantity = quantities[[symbol]],
        average_price = average_prices[[symbol]]
      )
    }
    held <- Portfolio$new(name = "long-term shares", members = members)
    results <- held$place_orders(product = "cnc", dry_run = TRUE)
    print(results[, c("label", "transaction_type", "quantity", "status")])

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    one_share <- Portfolio$new(
      name = "one IDEA share",
      members = list(
        BasketMember$new(idea, quantity = 1)
      )
    )
    bought <- one_share$place_orders(product = "mis", tag = "basketexample")
    print(bought[, c("label", "transaction_type", "outcome", "order_id")])
    order_id <- as.character(bought$order_id[[1]])
    status <- NULL
    for (attempt in seq_len(15)) {
      Sys.sleep(2)
      orders <- idea$orders
      if (is.null(orders)) {
        next
      }
      matching <- orders[as.character(orders$order_id) == order_id, ]
      if (nrow(matching) == 0) {
        next
      }
      status <- matching$status[[1]]
      if (status %in% c(
        "COMPLETE",
        "REJECTED",
        "CANCELLED"
      )) {
        break
      }
    }
    cat(sprintf("The buy order is %s\n", status))
    if (identical(status, "COMPLETE")) {
      sold <- one_share$place_orders(
        product = "mis",
        transaction_type = "sell"
      )
      print(sold[, c("label", "transaction_type", "outcome", "error")])
      if (!identical(sold$outcome[[1]], "accepted")) {
        closed <- idea$reduce_position(quantity = 1, product = "mis")
        cat(sprintf("Closed instead: %s\n", closed$outcome))
      }
    } else if (status %in% c(
      "OPEN",
      "PENDING"
    )) {
      print(idea$cancel_order(order_id)$outcome)
    }

    results <- held$place_orders(
      product = "cnc",
      dry_run = TRUE,
      as_marketable_limit = FALSE
    )
    print(results[, c("label", "transaction_type", "quantity", "status")])

------------------------------------------------------------------------

### `Portfolio$rebalance_trades()`

Works out the buys and sells that would give the portfolio another
basket's weights, without sending anything.

Each target quantity is the capital times the target weight divided by
the last price, floored to a whole unit. An instrument held but not in
the target is sold entirely, and one in the target but not held is
bought.

#### Usage

    Portfolio$rebalance_trades(target, capital = NULL)

#### Arguments

- `target`:

  The `AssetBasket` whose weights to move to, such as an `Index`.

- `capital`:

  The numeric amount in rupees to spread across the target, or `NULL` to
  use the portfolio's value now.

#### Details

Errors: signals `BasketMemberError` when an instrument in either basket
has no last price; and a `UnifiedBrokerInterfaceError` subclass when UBI
refused a request or could not be reached.

#### Returns

A `data.frame` with one row per instrument that needs a trade, sells
first, holding `label`, `instrument_id`, `last_price`,
`current_quantity`, `target_quantity`, `trade_quantity`, which is
negative for a sale, and `transaction_type`.

#### Examples

    quantities <- c(
      IDEA = 100,
      INFY = 5,
      TCS = 2
    )
    average_prices <- c(
      IDEA = 12.5,
      INFY = 1450,
      TCS = 3100
    )
    members <- list()
    for (symbol in names(quantities)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        quantity = quantities[[symbol]],
        average_price = average_prices[[symbol]]
      )
    }
    held <- Portfolio$new(name = "long-term shares", members = members)

    target_members <- list()
    for (symbol in c(
      "INFY",
      "TCS"
    )) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      target_members[[length(target_members) + 1]] <- BasketMember$new(share)
    }
    target <- Index$new(
      name = "IT equal",
      members = target_members,
      weighting = "equal"
    )
    trades <- held$rebalance_trades(target = target)
    print(trades[, c("label", "current_quantity", "target_quantity")])

    trades <- held$rebalance_trades(target = target, capital = 50000)
    print(trades[, c("label", "trade_quantity", "transaction_type")])

------------------------------------------------------------------------

### `Portfolio$rebalance()`

Sends the market orders `rebalance_trades()` works out, all in one list
request.

The sales and purchases are sent together and placed in parallel, so for
a delivery account the purchases must be affordable without the money
the sales will release.

UBI's order engine sends each order as a `marketable_limit`: a limit two
ticks past the other side's best price, moved after that price until it
fills, with whatever is left cancelled 30 seconds after it was placed. A
member that cannot be priced, because nobody is on the other side of its
book, no live quote has arrived or the quote is marked stale, gets HTTP
409 in its row, which leaves the portfolio part rebalanced, and nothing
is sent for it. Pass `as_marketable_limit = FALSE` to send real market
orders, which a member with no live quote, such as a mutual fund, needs.

#### Usage

    Portfolio$rebalance(
      target,
      product,
      capital = NULL,
      validity = "day",
      tag = NULL,
      dry_run = FALSE,
      as_marketable_limit = TRUE
    )

#### Arguments

- `target`:

  The `AssetBasket` whose weights to move to, such as an `Index`.

- `product`:

  The character product every order is sent with, such as `"cnc"`.

- `capital`:

  The numeric amount in rupees to spread across the target, or `NULL` to
  use the portfolio's value now.

- `validity`:

  The character validity of every order, such as `"day"`.

- `tag`:

  A character tag to put on every order, or `NULL`.

- `dry_run`:

  A logical that is `TRUE` to have UBI build every order without sending
  it.

- `as_marketable_limit`:

  A logical that is `TRUE` to let UBI's order engine send each order as
  a limit that follows the other side of the book for up to 30 seconds,
  and `FALSE` to send market orders to the brokers at once.

#### Details

Errors: signals `BasketMemberError` when an instrument in either basket
has no last price; `ServiceUnavailableError` when UBI's order engine is
not running, so nothing was placed; and another
`UnifiedBrokerInterfaceError` subclass for any other failure of a whole
request.

#### Returns

A `data.frame` with one row per order, in the form `place_orders()`
returns, which has no rows when no trade is needed.

#### Examples

    quantities <- c(
      IDEA = 100,
      INFY = 5,
      TCS = 2
    )
    average_prices <- c(
      IDEA = 12.5,
      INFY = 1450,
      TCS = 3100
    )
    members <- list()
    for (symbol in names(quantities)) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(
        share,
        quantity = quantities[[symbol]],
        average_price = average_prices[[symbol]]
      )
    }
    held <- Portfolio$new(name = "long-term shares", members = members)

    target_members <- list()
    for (symbol in c(
      "INFY",
      "TCS"
    )) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      target_members[[length(target_members) + 1]] <- BasketMember$new(share)
    }
    target <- Index$new(
      name = "IT equal",
      members = target_members,
      weighting = "equal"
    )
    results <- held$rebalance(
      target = target,
      product = "cnc",
      dry_run = TRUE
    )
    print(results[, c("label", "transaction_type", "quantity", "status")])

    results <- held$rebalance(
      target = target,
      product = "cnc",
      capital = 50000,
      tag = "rebalance",
      dry_run = TRUE
    )
    print(results[, c("label", "quantity", "status", "error")])

------------------------------------------------------------------------

### `Portfolio$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Portfolio$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
held <- Portfolio$from_holdings()
value <- held$value
profit <- held$unrealized_pnl

held <- tryCatch(
  Portfolio$from_holdings(),
  BasketMemberError = function(error) {
    print(conditionMessage(error))
    NULL
  }
)
if (!is.null(held)) {
  print(held$quantities)
}
held <- Portfolio$from_holdings(name = "demat holdings")
cat(sprintf("%d holdings worth %s\n", held$size, held$value))
cat(sprintf("Unrealised profit: %s\n", held$unrealized_pnl))

positions <- tryCatch(
  Portfolio$from_positions(),
  BasketMemberError = function(error) {
    print(conditionMessage(error))
    NULL
  }
)
if (!is.null(positions)) {
  print(positions$quantities)
}
today <- tryCatch(
  Portfolio$from_positions(name = "today", day = TRUE),
  BasketMemberError = function(error) {
    cat(sprintf("Nothing traded today: %s\n", conditionMessage(error)))
    NULL
  }
)
if (!is.null(today)) {
  print(today$value)
}

quantities <- c(
  IDEA = 100,
  INFY = 5,
  TCS = 2
)
average_prices <- c(
  IDEA = 12.5,
  INFY = 1450,
  TCS = 3100
)
members <- list()
for (symbol in names(quantities)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    quantity = quantities[[symbol]],
    average_price = average_prices[[symbol]]
  )
}
held <- Portfolio$new(name = "long-term shares", members = members)

pair <- Portfolio$new(
  name = "bank pair",
  members = list(
    BasketMember$new(
      Equity$new(exchange = "nse", symbol = "HDFCBANK"),
      quantity = 10
    ),
    BasketMember$new(
      Equity$new(exchange = "nse", symbol = "ICICIBANK"),
      quantity = -8
    )
  )
)

print(held$quantities)
print(pair$quantities)

print(round(held$values, 2))
values <- pair$values
print(round(values, 2))
cat(sprintf("Net: %.2f\n", sum(values)))

cat(sprintf("Portfolio value: Rs %.2f\n", held$value))
print(pair$value)

print(round(held$weights, 3))
weights <- pair$weights
print(round(weights, 3))
cat(sprintf("Absolute weights add up to %s\n", sum(abs(weights))))

cat(sprintf("Invested: Rs %.2f\n", held$invested_value))
print(pair$invested_value)

cat(sprintf("Unrealised profit: Rs %.2f\n", held$unrealized_pnl))
profit <- held$unrealized_pnl
percent <- profit / held$invested_value * 100
cat(sprintf("%+.2f%%\n", percent))

cat(sprintf("Today: Rs %+.2f\n", held$day_pnl))
print(pair$day_pnl)

cat(sprintf("%+.2f%%\n", held$day_change_percent))
print(held$ohlc[, c("label", "change_percent")])
cat(sprintf("Portfolio: %+.2f%%\n", held$day_change_percent))
} # }

## ------------------------------------------------
## Method `Portfolio$place_orders()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
quantities <- c(
  IDEA = 100,
  INFY = 5,
  TCS = 2
)
average_prices <- c(
  IDEA = 12.5,
  INFY = 1450,
  TCS = 3100
)
members <- list()
for (symbol in names(quantities)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    quantity = quantities[[symbol]],
    average_price = average_prices[[symbol]]
  )
}
held <- Portfolio$new(name = "long-term shares", members = members)
results <- held$place_orders(product = "cnc", dry_run = TRUE)
print(results[, c("label", "transaction_type", "quantity", "status")])

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
one_share <- Portfolio$new(
  name = "one IDEA share",
  members = list(
    BasketMember$new(idea, quantity = 1)
  )
)
bought <- one_share$place_orders(product = "mis", tag = "basketexample")
print(bought[, c("label", "transaction_type", "outcome", "order_id")])
order_id <- as.character(bought$order_id[[1]])
status <- NULL
for (attempt in seq_len(15)) {
  Sys.sleep(2)
  orders <- idea$orders
  if (is.null(orders)) {
    next
  }
  matching <- orders[as.character(orders$order_id) == order_id, ]
  if (nrow(matching) == 0) {
    next
  }
  status <- matching$status[[1]]
  if (status %in% c(
    "COMPLETE",
    "REJECTED",
    "CANCELLED"
  )) {
    break
  }
}
cat(sprintf("The buy order is %s\n", status))
if (identical(status, "COMPLETE")) {
  sold <- one_share$place_orders(
    product = "mis",
    transaction_type = "sell"
  )
  print(sold[, c("label", "transaction_type", "outcome", "error")])
  if (!identical(sold$outcome[[1]], "accepted")) {
    closed <- idea$reduce_position(quantity = 1, product = "mis")
    cat(sprintf("Closed instead: %s\n", closed$outcome))
  }
} else if (status %in% c(
  "OPEN",
  "PENDING"
)) {
  print(idea$cancel_order(order_id)$outcome)
}

results <- held$place_orders(
  product = "cnc",
  dry_run = TRUE,
  as_marketable_limit = FALSE
)
print(results[, c("label", "transaction_type", "quantity", "status")])
} # }

## ------------------------------------------------
## Method `Portfolio$rebalance_trades()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
quantities <- c(
  IDEA = 100,
  INFY = 5,
  TCS = 2
)
average_prices <- c(
  IDEA = 12.5,
  INFY = 1450,
  TCS = 3100
)
members <- list()
for (symbol in names(quantities)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    quantity = quantities[[symbol]],
    average_price = average_prices[[symbol]]
  )
}
held <- Portfolio$new(name = "long-term shares", members = members)

target_members <- list()
for (symbol in c(
  "INFY",
  "TCS"
)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  target_members[[length(target_members) + 1]] <- BasketMember$new(share)
}
target <- Index$new(
  name = "IT equal",
  members = target_members,
  weighting = "equal"
)
trades <- held$rebalance_trades(target = target)
print(trades[, c("label", "current_quantity", "target_quantity")])

trades <- held$rebalance_trades(target = target, capital = 50000)
print(trades[, c("label", "trade_quantity", "transaction_type")])
} # }

## ------------------------------------------------
## Method `Portfolio$rebalance()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
quantities <- c(
  IDEA = 100,
  INFY = 5,
  TCS = 2
)
average_prices <- c(
  IDEA = 12.5,
  INFY = 1450,
  TCS = 3100
)
members <- list()
for (symbol in names(quantities)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(
    share,
    quantity = quantities[[symbol]],
    average_price = average_prices[[symbol]]
  )
}
held <- Portfolio$new(name = "long-term shares", members = members)

target_members <- list()
for (symbol in c(
  "INFY",
  "TCS"
)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  target_members[[length(target_members) + 1]] <- BasketMember$new(share)
}
target <- Index$new(
  name = "IT equal",
  members = target_members,
  weighting = "equal"
)
results <- held$rebalance(
  target = target,
  product = "cnc",
  dry_run = TRUE
)
print(results[, c("label", "transaction_type", "quantity", "status")])

results <- held$rebalance(
  target = target,
  product = "cnc",
  capital = 50000,
  tag = "rebalance",
  dry_run = TRUE
)
print(results[, c("label", "quantity", "status", "error")])
} # }
```
