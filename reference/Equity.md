# One listed share, such as RELIANCE on the nse

The equity family has six classes, each fixing one of UBI's equity
segments, so the kind of contract is the class rather than a segment
name passed by hand, and each constructor asks for exactly the fields
that identify one of its own contracts. `Equity` and `EquityIndex` are
named by exchange and symbol, the futures classes by exchange,
underlying symbol and expiry date, and the option classes by those three
plus a strike price and an option type. All six inherit every analysis
class through `Instrument`.

A share is the only thing in this family that can be held, so `Equity`
alone carries the holdings members. Selling works on the shares free to
sell, which is the holding minus anything pledged as collateral. A
holding's `pnl` reports `day_change`, `day_change_percentage` and
`unrealized`, while a position's reports `realized`, `unrealized` and
`total`.

The class generator carries one discovery function:

- `Equity$search(exchange, term, limit = 50, unified_broker_interface = NULL)`
  finds listed shares whose symbol contains `term`, matched without
  regard to case, with an exact match first, then symbols starting with
  the term, then symbols containing it, so a partial name such as
  `"RELI"` finds RELIANCE near the top. It returns a `data.frame` with
  `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the
  derivative fields left empty, or `NULL` when no share matches, and
  signals `BadRequestError` when the exchange is not one UBI knows.

The examples below start with a short tour of the class, then show its
properties and the functions on its class generator, in this order:

- For `holdings`, print the holding of Vodafone Idea, or say that none
  is held.

- For `holdings`, report how many shares of each of a few companies are
  held and how many are free to sell.

- For `holdings`, compare what was paid for a holding with what it is
  worth now.

- For `holdings_value`, print what the Vodafone Idea shares held are
  worth, which is `NULL` when none are held.

- For `holdings_value`, add up the value of the shares held in a few
  companies, skipping any that are not held.

- For `holdings_pnl`, print the profit and loss of the Vodafone Idea
  shares held, which is `NULL` when none are held.

- For `holdings_pnl`, print today's change and the unrealised profit of
  each of a few holdings.

- For `Equity$search()`, find the nse shares whose symbol contains a
  partial name.

- For `Equity$search()`, search, then build the first match and print
  its last price.

- For `Equity$search()`, check whether a symbol is listed on both the
  nse and the bse.

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
-\> `Equity`

## Active bindings

- `holdings`:

  The long-term holding of this share, merged across every broker, as a
  named list, or `NULL` when it is not held. A derivative is a position
  rather than a holding, and an index cannot be held at all. Reading
  this sends one request to UBI every time, because UBI serves the whole
  account's holdings and has no route for a single instrument.

- `holdings_value`:

  The numeric worth of the shares held at the moment, or `NULL` when the
  share is not held. UBI prices a holding itself, so this reads the
  figure rather than working it out, which is the opposite of
  `positions_value`. It counts every share held, including any pledged
  as collateral, because a pledged share is still owned.

- `holdings_pnl`:

  What the shares held have made or lost, as a named list with
  `day_change`, `day_change_percentage` and `unrealized`, or `NULL` when
  the share is not held. It is not shaped like a position's `pnl`, which
  reports `realized`, `unrealized` and `total`, so only `unrealized`
  means the same thing in both. There is no realised figure, because
  selling a share removes it from the holding rather than booking a
  profit against it.

## Methods

### Public methods

- [`Equity$new()`](#method-Equity-initialize)

- [`Equity$add_to_holdings()`](#method-Equity-add_to_holdings)

- [`Equity$reduce_holdings()`](#method-Equity-reduce_holdings)

- [`Equity$liquidate_holdings()`](#method-Equity-liquidate_holdings)

- [`Equity$clone()`](#method-Equity-clone)

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

### `Equity$new()`

Looks the share up in UBI's equities segment and keeps its details.

#### Usage

    Equity$new(exchange, symbol, unified_broker_interface = NULL)

#### Arguments

- `exchange`:

  The character exchange the share is listed on, such as `"nse"`.

- `symbol`:

  The character symbol of the share, such as `"RELIANCE"`.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to send requests through, or `NULL` to
  share one client among all instruments.

#### Details

Errors: signals `EquityError` when UBI has no share with that symbol on
that exchange, or the instrument it returned is not in the equities
segment; and a `UnifiedBrokerInterfaceError` subclass for any other
failure reported by, or on the way to, UBI.

#### Returns

A new `Equity` object.

------------------------------------------------------------------------

### `Equity$add_to_holdings()`

Buys more of this share to keep.

The order is always sent as `cnc`, which is the product that puts shares
in the demat account. Nothing is read first, because a share can be
bought whether or not it is already held, and UBI checks funds no more
than a broker's order route does.

The examples below, in order:

- Bid for one Vodafone Idea share to keep, three per cent below the last
  price, and cancel the order the engine holds at once.

- Send the same bid as an immediate-or-cancel order, which the exchange
  cancels itself when nothing matches.

#### Usage

    Equity$add_to_holdings(
      quantity,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer number of shares to buy.

- `price`:

  The numeric limit price in rupees, or `NULL` to send a market order.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use
  `"day"`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character label of up to twenty letters and digits for the order, or
  `NULL`.

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure
reported by, or on the way to, UBI.

#### Returns

The named list `place_order()` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(share$last_price * 0.97, 2)
    answer <- share$add_to_holdings(quantity = 1, price = price)
    cat(answer[["outcome"]], answer[["parent_id"]], "\n")
    if (!is.null(answer[["parent_id"]])) {
      cancelled <- share$cancel_parent(answer[["parent_id"]])
      print(cancelled[["state"]])
    }

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(share$last_price * 0.97, 2)
    answer <- share$add_to_holdings(
      quantity = 1,
      price = price,
      validity = "ioc",
      tag = "examplebid"
    )
    cat(answer[["outcome"]], answer[["status_message"]], "\n")
    if (!is.null(answer[["parent_id"]])) {
      tryCatch(
        share$cancel_parent(answer[["parent_id"]]),
        ConflictError = function(error) {
          cat("The order had already finished.", "\n")
        }
      )
    }

------------------------------------------------------------------------

### `Equity$reduce_holdings()`

Sells some of the shares held, without selling more than are free.

Shares pledged as collateral cannot be sold until they are released at
the broker, so the quantity asked for is measured against the free
shares rather than the whole holding.

The examples below, in order:

- Offer one Vodafone Idea share from the holding three per cent above
  the last price, and cancel the order at once.

- Catch the error raised when more shares are asked for than are free to
  sell, which sends no order.

#### Usage

    Equity$reduce_holdings(
      quantity,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer number of shares to sell.

- `price`:

  The numeric limit price in rupees, or `NULL` to send a market order.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use
  `"day"`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character label of up to twenty letters and digits for the order, or
  `NULL`.

#### Details

Errors: signals `HoldingError` when this share is not held, or the
quantity is more than the free shares; and a
`UnifiedBrokerInterfaceError` subclass for any failure reported by, or
on the way to, UBI.

#### Returns

The named list `place_order()` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    if (is.null(share$holdings)) {
      cat("No IDEA shares are held, so there is nothing to offer.", "\n")
    } else {
      price <- round(share$last_price * 1.03, 2)
      answer <- share$reduce_holdings(quantity = 1, price = price)
      cat(answer[["outcome"]], answer[["parent_id"]], "\n")
      if (!is.null(answer[["parent_id"]])) {
        share$cancel_parent(answer[["parent_id"]])
      }
    }

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    tryCatch(
      share$reduce_holdings(quantity = 10000000, price = 100.0),
      HoldingError = function(error) {
        cat(sprintf("Refused: %s", conditionMessage(error)), "\n")
      }
    )

------------------------------------------------------------------------

### `Equity$liquidate_holdings()`

Sells every share held that is free to sell.

Shares pledged as collateral are left alone, because they cannot be sold
until they are released at the broker, so this empties the holding only
when nothing is pledged.

The examples below, in order:

- Offer every free Vodafone Idea share three per cent above the last
  price, and cancel the order at once.

- Catch the error raised for a share that is not held, which sends no
  order.

#### Usage

    Equity$liquidate_holdings(
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `price`:

  The numeric limit price in rupees, or `NULL` to send a market order.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use
  `"day"`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character label of up to twenty letters and digits for the order, or
  `NULL`.

#### Details

Errors: signals `HoldingError` when this share is not held, or every
share held is pledged as collateral; and a `UnifiedBrokerInterfaceError`
subclass for any failure reported by, or on the way to, UBI.

#### Returns

The named list `place_order()` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    if (is.null(share$holdings)) {
      cat("No IDEA shares are held, so there is nothing to sell.", "\n")
    } else {
      price <- round(share$last_price * 1.03, 2)
      answer <- share$liquidate_holdings(price = price)
      cat(answer[["outcome"]], answer[["parent_id"]], "\n")
      if (!is.null(answer[["parent_id"]])) {
        share$cancel_parent(answer[["parent_id"]])
      }
    }

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    tryCatch(
      share$liquidate_holdings(price = 100.0),
      HoldingError = function(error) {
        cat(sprintf("Nothing sold: %s", conditionMessage(error)), "\n")
      }
    )

------------------------------------------------------------------------

### `Equity$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Equity$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "RELIANCE")
frame <- share$relative_strength_index(window = 14, days = 365)
share$holdings
Equity$search(exchange = "nse", term = "RELI")

share <- Equity$new(exchange = "nse", symbol = "IDEA")
holding <- share$holdings
if (is.null(holding)) {
  cat("No IDEA shares are held.", "\n")
} else {
  cat(
    holding[["quantity"]],
    "shares at",
    holding[["average_price"]],
    "\n"
  )
}

symbols <- c(
  "IDEA",
  "ITC",
  "RELIANCE"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  holding <- share$holdings
  if (is.null(holding)) {
    cat(sprintf("%s: not held", symbol), "\n")
    next
  }
  pledged <- holding[["collateral_quantity"]]
  free_quantity <- holding[["quantity"]] - pledged
  cat(
    sprintf(
      "%s: %s held, %s free",
      symbol,
      holding[["quantity"]],
      free_quantity
    ),
    "\n"
  )
}

share <- Equity$new(exchange = "nse", symbol = "ITC")
holding <- share$holdings
if (is.null(holding)) {
  cat("No ITC shares are held.", "\n")
} else {
  invested <- holding[["invested_value"]]
  current <- holding[["current_value"]]
  cat(sprintf("Invested %.2f, worth %.2f now", invested, current), "\n")
}

share <- Equity$new(exchange = "nse", symbol = "IDEA")
print(share$holdings_value)

symbols <- c(
  "IDEA",
  "ITC",
  "TCS"
)
total_value <- 0.0
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  value <- share$holdings_value
  if (!is.null(value)) {
    total_value <- total_value + value
  }
}
cat(sprintf("Held in these shares: %.2f rupees", total_value), "\n")

share <- Equity$new(exchange = "nse", symbol = "IDEA")
print(share$holdings_pnl)

symbols <- c(
  "IDEA",
  "ITC"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  profit_and_loss <- share$holdings_pnl
  if (is.null(profit_and_loss)) {
    cat(sprintf("%s: not held", symbol), "\n")
    next
  }
  day_change <- profit_and_loss[["day_change"]]
  unrealized <- profit_and_loss[["unrealized"]]
  cat(
    sprintf("%s: today %s, unrealised %s", symbol, day_change, unrealized),
    "\n"
  )
}

matches <- Equity$search(exchange = "nse", term = "RELI")
print(matches[, c(
  "symbol",
  "instrument_id"
)])

matches <- Equity$search(exchange = "nse", term = "INFY", limit = 5)
if (is.null(matches)) {
  cat("No share matches.", "\n")
} else {
  symbol <- matches$symbol[[1]]
  share <- Equity$new(exchange = "nse", symbol = symbol)
  cat(symbol, share$last_price, "\n")
}

exchanges <- c(
  "nse",
  "bse"
)
for (exchange in exchanges) {
  matches <- Equity$search(
    exchange = exchange,
    term = "TCS",
    limit = 1
  )
  found <- !is.null(matches) && matches$symbol[[1]] == "TCS"
  cat(sprintf("TCS listed on %s: %s", exchange, found), "\n")
}
} # }

## ------------------------------------------------
## Method `Equity$add_to_holdings()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(share$last_price * 0.97, 2)
answer <- share$add_to_holdings(quantity = 1, price = price)
cat(answer[["outcome"]], answer[["parent_id"]], "\n")
if (!is.null(answer[["parent_id"]])) {
  cancelled <- share$cancel_parent(answer[["parent_id"]])
  print(cancelled[["state"]])
}

share <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(share$last_price * 0.97, 2)
answer <- share$add_to_holdings(
  quantity = 1,
  price = price,
  validity = "ioc",
  tag = "examplebid"
)
cat(answer[["outcome"]], answer[["status_message"]], "\n")
if (!is.null(answer[["parent_id"]])) {
  tryCatch(
    share$cancel_parent(answer[["parent_id"]]),
    ConflictError = function(error) {
      cat("The order had already finished.", "\n")
    }
  )
}
} # }

## ------------------------------------------------
## Method `Equity$reduce_holdings()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
if (is.null(share$holdings)) {
  cat("No IDEA shares are held, so there is nothing to offer.", "\n")
} else {
  price <- round(share$last_price * 1.03, 2)
  answer <- share$reduce_holdings(quantity = 1, price = price)
  cat(answer[["outcome"]], answer[["parent_id"]], "\n")
  if (!is.null(answer[["parent_id"]])) {
    share$cancel_parent(answer[["parent_id"]])
  }
}

share <- Equity$new(exchange = "nse", symbol = "IDEA")
tryCatch(
  share$reduce_holdings(quantity = 10000000, price = 100.0),
  HoldingError = function(error) {
    cat(sprintf("Refused: %s", conditionMessage(error)), "\n")
  }
)
} # }

## ------------------------------------------------
## Method `Equity$liquidate_holdings()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
if (is.null(share$holdings)) {
  cat("No IDEA shares are held, so there is nothing to sell.", "\n")
} else {
  price <- round(share$last_price * 1.03, 2)
  answer <- share$liquidate_holdings(price = price)
  cat(answer[["outcome"]], answer[["parent_id"]], "\n")
  if (!is.null(answer[["parent_id"]])) {
    share$cancel_parent(answer[["parent_id"]])
  }
}

share <- Equity$new(exchange = "nse", symbol = "IDEA")
tryCatch(
  share$liquidate_holdings(price = 100.0),
  HoldingError = function(error) {
    cat(sprintf("Nothing sold: %s", conditionMessage(error)), "\n")
  }
)
} # }
```
