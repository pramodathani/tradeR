# A futures or option contract, which expires on a set day and is written on an underlying instrument

This is the shared base of `Futures` and `Option`, and it holds what is
true of every contract: when it expires, what it is written on, how much
of it is open, and what one lot of it is worth. It is rarely built
directly; the family classes such as `EquityFutures` inherit it.

The underlying is found in this order, and the first that applies wins.
An underlying given as an object when the contract is built is kept and
used as it is. Otherwise UBI's `underlying_instrument_id`, resolved from
the brokers' own records, is used when UBI supplies one. Otherwise the
family's default applies, from
`INSTRUMENTS_UNDERLYING_SEGMENT_FOR_DERIVATIVE_SEGMENT`: an equity
contract's share or index found by its symbol, the nearest future for an
option on a commodity, a currency pair or a bond, and nothing for a
future outside equities, whose cash underlying has no price in UBI.
Nothing but the given object is stored, so the other ways look the
underlying up again on every read, and `UnderlyingError` says when none
of them finds one.

The examples below show its properties, in this order:

- For `days_to_expiry`, print how many days the nearest Nifty future has
  left.

- For `days_to_expiry`, print the days left on every listed Reliance
  future.

- For `expired`, show that a listed Nifty future has not expired.

- For `expired`, build the oldest Nifty future UBI still knows, which
  has expired, and check it.

- For `expiry_kind`, say whether each of the next four Nifty option
  expiries is a weekly or a monthly one.

- For `expiry_kind`, show that a stock future is always monthly, since
  stocks have no weekly expiries.

- For `next_expiry`, find the expiry a position in the nearest Nifty
  future would roll to.

- For `next_expiry`, build the next Reliance future from the nearest one
  and compare their prices, which is the roll's cost.

- For `underlying`, print what the nearest Reliance future is written
  on, which is looked up in UBI.

- For `underlying`, give the underlying when building the contract, so
  the contract keeps that very object and makes no lookup.

- For `underlying`, print the index a Nifty future is written on.

- For `underlying_price`, print the Nifty index level beside the price
  of its nearest future.

- For `underlying_price`, print the share price under a Reliance future,
  read once for a report.

- For `open_interest_day_high`, print the highest open interest the
  nearest Nifty future reached today.

- For `open_interest_day_high`, say how far today's open interest is
  below its high for the day, which shows positions being closed.

- For `open_interest_day_low`, print the lowest open interest the
  nearest Nifty future reached today.

- For `open_interest_day_low`, print today's open interest range of the
  nearest Reliance future.

- For `contract_value`, print what one lot of the nearest Nifty future
  is worth.

- For `contract_value`, compare the exposure of one lot of the nearest
  Nifty and Reliance futures.

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
-\> `Derivative`

## Public fields

- `underlying_segment`:

  The character exchange-prefixed segment of the underlying, such as
  `"nse_equities"`, `"nse_equity_indices"` or `"mcx_commodity_futures"`:
  the given underlying's own segment, or else the one the family's
  default searches, or `NULL` when the family has no default.

## Active bindings

- `days_to_expiry`:

  The integer number of calendar days from today until the contract
  expires, counted in India time.

- `expired`:

  A logical that is `TRUE` when the contract's expiry date has passed,
  counted in India time. A contract expiring today is not expired,
  because it can still be traded until the market closes, which matches
  the rule the discovery functions use.

- `expiry_kind`:

  The character `"monthly"` when the contract is the month's last expiry
  for its underlying, or `"weekly"` when it is one of the weekly
  expiries before it. A contract is monthly when no later contract on
  the same underlying in the same segment expires in the same calendar
  month, so quarterly and half-yearly contracts count as monthly. Each
  read downloads the segment's whole instrument list from UBI, which
  takes about two seconds for single-stock options.

- `next_expiry`:

  The `Date` of the first live expiry after this contract's on the same
  underlying in the same segment, which is where a position rolls to, or
  `NULL` when there is none. Each read downloads the segment's whole
  instrument list from UBI.

- `underlying`:

  The `Instrument` the contract is written on, found in the order the
  class description gives. A given underlying is returned as it is, with
  no request, whatever its class. Any other is looked up again on every
  read, so bind it to a local variable to use it more than once: UBI's
  link or an equity's share or index comes back as a
  `TradeableInstrument` or `NonTradeableInstrument`, never a family
  class such as `Equity`, and an option's default future comes back as a
  `Futures`.

- `underlying_price`:

  The underlying's numeric last traded price, or `NULL` when UBI has
  none, read from UBI on every access as cheaply as the way `underlying`
  finds it allows: a given underlying's own `last_price`, one request by
  instrument id for UBI's link, one request by exchange, segment and
  symbol for an equity's share or index, and the future's lookup and
  last price for an option priced off a future.

- `open_interest_day_high`:

  The highest integer open interest reached today, or `NULL` when UBI
  has none.

- `open_interest_day_low`:

  The lowest integer open interest reached today, or `NULL` when UBI has
  none.

- `contract_value`:

  The numeric worth of one lot of the contract at its last price, which
  is the last price times the lot size, or `NULL` when either is
  unknown. For a future this is the exposure one lot carries, and for an
  option it is the premium one lot costs. For currency contracts the lot
  size is the plurality of the brokers' figures rather than the lot an
  order is measured against, so there it is approximate.

## Methods

### Public methods

- [`Derivative$new()`](#method-Derivative-initialize)

- [`Derivative$clone()`](#method-Derivative-clone)

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

### `Derivative$new()`

Looks the contract up in UBI and checks that it is a future or an
option.

#### Usage

    Derivative$new(
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

  The character UUID of the contract, or `NULL` to look it up by
  exchange, segment and identity fields.

- `exchange`:

  The character exchange, such as `"nse"`, or `NULL` when
  `instrument_id` is given.

- `segment`:

  The character segment, such as `"equity_futures"`, or `NULL` when
  `instrument_id` is given.

- `symbol`:

  The character symbol, or `NULL`, since a contract is named by its
  underlying.

- `underlying_symbol`:

  The character symbol of the contract's underlying, or `NULL`.

- `expiry_date`:

  The expiry as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.

- `strike_price`:

  The numeric strike price of an option, or `NULL`.

- `option_type`:

  The character option type of an option, `"CE"` or `"PE"`, or `NULL`.

- `underlying`:

  The `Instrument` the contract is written on, such as an `Equity`, an
  `EquityIndex` or a future, which the contract keeps and uses for
  `underlying` and `underlying_price`, or `NULL` to use UBI's link to
  the underlying or else the family's default, looked up on every read.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to send requests through, or `NULL` to
  share one client among all instruments.

#### Details

Errors: signals `TypeError` when `underlying` is given and is not an
`Instrument`; `DerivativeError` when the instrument is neither a future
nor an option, has no expiry date, or is in a segment with no known
underlying segment and no underlying was given;
`TradeableInstrumentError` when the instrument is an index;
`InstrumentError` when UBI has no instrument matching the lookup;
`BadRequestError` when the lookup is incomplete or malformed; and
another `UnifiedBrokerInterfaceError` subclass for any other failure
reported by, or on the way to, UBI.

#### Returns

A new `Derivative` object.

------------------------------------------------------------------------

### `Derivative$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Derivative$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

cat(format(nifty_future), nifty_future$days_to_expiry, "\n")

expiries <- EquityFutures$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
for (expiry_date in as.list(expiries)) {
  future <- EquityFutures$new(
    exchange = "nse",
    underlying_symbol = "RELIANCE",
    expiry_date = expiry_date
  )
  cat(format(expiry_date), future$days_to_expiry, "\n")
}

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

cat(format(nifty_future), "expired:", nifty_future$expired, "\n")

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  include_expired = TRUE
)
oldest_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)
cat(format(oldest_future), "expired:", oldest_future$expired, "\n")
cat("Days since expiry:", -oldest_future$days_to_expiry, "\n")

expiries <- EquityIndexOption$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
for (expiry_date in as.list(head(expiries, 4))) {
  chain <- EquityIndexOption$chain(
    exchange = "nse",
    underlying_symbol = "NIFTY",
    expiry_date = expiry_date
  )
  first_row <- chain[1, ]
  option <- IndexOption$new(
    instrument_id = first_row[["instrument_id"]]
  )
  cat(format(expiry_date), option$expiry_kind, "\n")
}

expiries <- EquityFutures$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
reliance_future <- EquityFutures$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]]
)

cat(format(reliance_future), reliance_future$expiry_kind, "\n")

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

cat(
  format(nifty_future$expiry_date),
  "rolls to",
  format(nifty_future$next_expiry),
  "\n"
)

expiries <- EquityFutures$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
reliance_future <- EquityFutures$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]]
)

next_expiry <- reliance_future$next_expiry
if (is.null(next_expiry)) {
  cat("There is no later expiry listed.", "\n")
} else {
  next_future <- EquityFutures$new(
    exchange = "nse",
    underlying_symbol = "RELIANCE",
    expiry_date = next_expiry
  )
  near_price <- reliance_future$last_price
  far_price <- next_future$last_price
  cat(sprintf("Near %s, next %s", near_price, far_price), "\n")
  cat(
    sprintf("Rolling costs %.2f per share", far_price - near_price),
    "\n"
  )
}

expiries <- EquityFutures$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
reliance_future <- EquityFutures$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]]
)

underlying <- reliance_future$underlying
cat(format(underlying), underlying$last_price, "\n")

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
expiries <- EquityFutures$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
reliance_future <- EquityFutures$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]],
  underlying = reliance
)
print(identical(reliance_future$underlying, reliance))
print(class(reliance_future$underlying)[[1]])

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

index <- nifty_future$underlying
cat(class(index)[[1]], index$symbol, index$last_price, "\n")

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

cat("Index:", nifty_future$underlying_price, "\n")
cat("Future:", nifty_future$last_price, "\n")

expiries <- EquityFutures$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
reliance_future <- EquityFutures$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]]
)

share_price <- reliance_future$underlying_price
if (is.null(share_price)) {
  cat("UBI has no price for the share.", "\n")
} else {
  cat(sprintf("Reliance shares at %s", share_price), "\n")
}

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

print(nifty_future$open_interest_day_high)

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

day_high <- nifty_future$open_interest_day_high
now <- nifty_future$open_interest
if (is.null(day_high) || is.null(now)) {
  cat("The broker does not report the open interest range.", "\n")
} else {
  cat(
    sprintf("Open interest is %s below today's high", day_high - now),
    "\n"
  )
}

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

print(nifty_future$open_interest_day_low)

expiries <- EquityFutures$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
reliance_future <- EquityFutures$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = expiries[[1]]
)

day_low <- reliance_future$open_interest_day_low
day_high <- reliance_future$open_interest_day_high
cat(
  sprintf("Open interest ranged from %s to %s", day_low, day_high),
  "\n"
)

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

cat(
  nifty_future$lot_size,
  "units worth Rs",
  nifty_future$contract_value,
  "\n"
)

nifty_expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = nifty_expiries[[1]]
)
reliance_expiries <- EquityFutures$expiries(
  exchange = "nse",
  underlying_symbol = "RELIANCE"
)
reliance_future <- EquityFutures$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = reliance_expiries[[1]]
)
for (future in list(
  nifty_future,
  reliance_future
)) {
  cat(
    sprintf(
      "%s: Rs %s",
      future$underlying_symbol,
      formatC(future$contract_value, format = "f", digits = 0, big.mark = ",")
    ),
    "\n"
  )
}
} # }
```
