# One exchange-traded fund, such as NIFTYBEES on the nse

The exchange-traded fund family is two classes, `ExchangeTradedFund` and
`InvestmentTrust`, each fixing one of UBI's segments, so the kind of
instrument is the class rather than a segment name passed by hand. Both
are named by exchange and symbol, because a fund and a trust have no
expiry, strike or option type, and UBI has no futures or options written
on either.

Both trade on the `nse` and the `bse` exactly as a share does. They are
quoted, they can be ordered with the ordinary market and limit wrappers,
and they can be held in the demat account, so both carry the same
holdings members `Equity` does. An order's quantity is a plain count of
units, as for a share, rather than the whole number of lots a commodity
or currency order needs. Selling works on the units free to sell, which
is the holding minus anything pledged as collateral.

Symbols are readable tickers, such as `NIFTYBEES` for a fund and
`EMBASSY` for a trust. A mutual fund is a different thing and is
`MutualFund`, because it is subscribed to at its net asset value rather
than traded.

A fund's candles are adjusted for splits and bonuses and carry a
`price_factor` column, as a share's do, so the analysis methods work on
it. `constituents` holds the stored basket of what the fund itself owns,
which is different from `holdings`, the units of the fund this account
owns.

The class generator carries one discovery function:

- `ExchangeTradedFund$search(exchange, term, limit = 50, unified_broker_interface = NULL)`
  finds exchange traded funds whose symbol contains `term`, matched
  without regard to case, with an exact match first, then symbols
  starting with the term, then symbols containing it, so a partial name
  such as `"NIFTYBEE"` finds NIFTYBEES near the top. It returns a
  `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`,
  `symbol` and the derivative fields left empty, or `NULL` when no fund
  matches, and signals `BadRequestError` when the exchange is not one
  UBI knows.

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
-\> `ExchangeTradedFund`

## Active bindings

- `constituents`:

  The stored basket of what the fund holds, an
  `ExchangeTradedFundConstituents`, or `NULL` when none is stored for
  today, read from MongoDB and UBI on every access. This is the fund's
  own portfolio, which is different from `holdings`, the units of the
  fund this account holds. UBI stores no fund holdings, so a basket
  exists only when one was saved with this fund as its linked
  instrument.

- `holdings`:

  The long-term holding of this fund, merged across every broker, as a
  named list, or `NULL` when it is not held. Reading this sends one
  request to UBI every time, because UBI serves the whole account's
  holdings and has no route for a single instrument.

- `holdings_value`:

  The numeric worth of the units held at the moment, or `NULL` when the
  fund is not held. UBI prices a holding itself, so this reads the
  figure rather than working it out. It counts every unit held,
  including any pledged as collateral, because a pledged unit is still
  owned.

- `holdings_pnl`:

  What the units held have made or lost, as a named list with
  `day_change`, `day_change_percentage` and `unrealized`, or `NULL` when
  the fund is not held. It is not shaped like a position's `pnl`, which
  reports `realized`, `unrealized` and `total`, so only `unrealized`
  means the same thing in both.

## Methods

### Public methods

- [`ExchangeTradedFund$new()`](#method-ExchangeTradedFund-initialize)

- [`ExchangeTradedFund$add_to_holdings()`](#method-ExchangeTradedFund-add_to_holdings)

- [`ExchangeTradedFund$reduce_holdings()`](#method-ExchangeTradedFund-reduce_holdings)

- [`ExchangeTradedFund$liquidate_holdings()`](#method-ExchangeTradedFund-liquidate_holdings)

- [`ExchangeTradedFund$clone()`](#method-ExchangeTradedFund-clone)

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

### `ExchangeTradedFund$new()`

Looks the fund up in UBI's exchange traded funds segment and keeps its
details.

#### Usage

    ExchangeTradedFund$new(exchange, symbol, unified_broker_interface = NULL)

#### Arguments

- `exchange`:

  The character exchange the fund is listed on, `"nse"` or `"bse"`.

- `symbol`:

  The character symbol of the fund, such as `"NIFTYBEES"`.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to send requests through, or `NULL` to
  share one client among all instruments.

#### Details

Errors: signals `ExchangeTradedFundError` when UBI has no fund with that
symbol on that exchange, or the instrument it returned is not in the
exchange traded funds segment; and a `UnifiedBrokerInterfaceError`
subclass for any other failure reported by, or on the way to, UBI.

#### Returns

A new `ExchangeTradedFund` object.

------------------------------------------------------------------------

### `ExchangeTradedFund$add_to_holdings()`

Buys more of this fund to keep.

The order is always sent as `cnc`, which is the product that puts units
in the demat account. Nothing is read first, because a fund can be
bought whether or not it is already held. A `day` limit order is held by
UBI's order engine until the other side of the book reaches its price,
as `buy_at_limit_price()` describes, and a market order is sent as a
marketable limit, as `buy_at_market_price()` describes.

#### Usage

    ExchangeTradedFund$add_to_holdings(
      quantity,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer number of units to buy.

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

    fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
    limit_price <- round(fund$last_price * 0.97, 2)
    answer <- fund$add_to_holdings(quantity = 1, price = limit_price)
    tryCatch(
      print(answer),
      finally = print(fund$cancel_parent(answer[["parent_id"]]))
    )

    fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES")
    limit_price <- round(fund$last_price * 0.97, 2)
    answer <- fund$add_to_holdings(
      quantity = 1,
      price = limit_price,
      tag = "examplebid"
    )
    columns <- c(
      "parent_order_id",
      "synthetic_type",
      "state"
    )
    tryCatch(
      print(fund$parents[columns]),
      finally = print(fund$cancel_parent(answer[["parent_id"]]))
    )

------------------------------------------------------------------------

### `ExchangeTradedFund$reduce_holdings()`

Sells some of the units held, without selling more than are free.

Units pledged as collateral cannot be sold until they are released at
the broker, so the quantity asked for is measured against the free units
rather than the whole holding.

#### Usage

    ExchangeTradedFund$reduce_holdings(
      quantity,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer number of units to sell.

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

Errors: signals `HoldingError` when this fund is not held, or the
quantity is more than the free units; and a
`UnifiedBrokerInterfaceError` subclass for any failure reported by, or
on the way to, UBI.

#### Returns

The named list `place_order()` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
    if (is.null(fund$holdings)) {
      cat("No NIFTYBEES units are held, so there is nothing to reduce.\n")
    } else {
      limit_price <- round(fund$last_price * 1.03, 2)
      answer <- fund$reduce_holdings(quantity = 1, price = limit_price)
      tryCatch(
        print(answer),
        finally = print(fund$cancel_parent(answer[["parent_id"]]))
      )
    }

    limit_price <- round(fund$last_price * 1.03, 2)
    tryCatch(
      fund$reduce_holdings(quantity = 10000000, price = limit_price),
      HoldingError = function(error) {
        cat("Refused:", conditionMessage(error), "\n")
      }
    )

------------------------------------------------------------------------

### `ExchangeTradedFund$liquidate_holdings()`

Sells every unit held that is free to sell.

Units pledged as collateral are left alone, because they cannot be sold
until they are released at the broker, so this empties the holding only
when nothing is pledged.

#### Usage

    ExchangeTradedFund$liquidate_holdings(
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

Errors: signals `HoldingError` when this fund is not held, or every unit
held is pledged as collateral; and a `UnifiedBrokerInterfaceError`
subclass for any failure reported by, or on the way to, UBI.

#### Returns

The named list `place_order()` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
    if (is.null(fund$holdings)) {
      cat("No NIFTYBEES units are held, so there is nothing to sell.\n")
    } else {
      limit_price <- round(fund$last_price * 1.03, 2)
      answer <- fund$liquidate_holdings(price = limit_price)
      tryCatch(
        print(answer),
        finally = print(fund$cancel_parent(answer[["parent_id"]]))
      )
    }

    fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES")
    limit_price <- round(fund$last_price * 1.03, 2)
    answer <- tryCatch(
      fund$liquidate_holdings(price = limit_price),
      HoldingError = function(error) {
        cat("Nothing to sell:", conditionMessage(error), "\n")
        NULL
      }
    )
    if (!is.null(answer)) {
      tryCatch(
        print(answer),
        finally = print(fund$cancel_parent(answer[["parent_id"]]))
      )
    }

------------------------------------------------------------------------

### `ExchangeTradedFund$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ExchangeTradedFund$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
price <- fund$last_price
frame <- fund$relative_strength_index(window = 14, days = 90)
row <- fund$holdings
basket <- fund$constituents

matches <- ExchangeTradedFund$search(exchange = "nse", term = "NIFTYBEE")
columns <- c(
  "symbol",
  "exchange",
  "segment"
)
print(matches[columns])

matches <- ExchangeTradedFund$search(exchange = "bse", term = "GOLD", limit = 10)
if (is.null(matches)) {
  cat("No gold fund was found on the bse.\n")
} else {
  print(matches$symbol)
}

matches <- ExchangeTradedFund$search(exchange = "nse", term = "BANKBEE")
first_symbol <- matches$symbol[[1]]
fund <- ExchangeTradedFund$new(exchange = "nse", symbol = first_symbol)
cat(fund$symbol, ": ", fund$last_price, "\n", sep = "")
} # }

## ------------------------------------------------
## Method `ExchangeTradedFund$add_to_holdings()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
limit_price <- round(fund$last_price * 0.97, 2)
answer <- fund$add_to_holdings(quantity = 1, price = limit_price)
tryCatch(
  print(answer),
  finally = print(fund$cancel_parent(answer[["parent_id"]]))
)

fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES")
limit_price <- round(fund$last_price * 0.97, 2)
answer <- fund$add_to_holdings(
  quantity = 1,
  price = limit_price,
  tag = "examplebid"
)
columns <- c(
  "parent_order_id",
  "synthetic_type",
  "state"
)
tryCatch(
  print(fund$parents[columns]),
  finally = print(fund$cancel_parent(answer[["parent_id"]]))
)
} # }

## ------------------------------------------------
## Method `ExchangeTradedFund$reduce_holdings()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
if (is.null(fund$holdings)) {
  cat("No NIFTYBEES units are held, so there is nothing to reduce.\n")
} else {
  limit_price <- round(fund$last_price * 1.03, 2)
  answer <- fund$reduce_holdings(quantity = 1, price = limit_price)
  tryCatch(
    print(answer),
    finally = print(fund$cancel_parent(answer[["parent_id"]]))
  )
}

limit_price <- round(fund$last_price * 1.03, 2)
tryCatch(
  fund$reduce_holdings(quantity = 10000000, price = limit_price),
  HoldingError = function(error) {
    cat("Refused:", conditionMessage(error), "\n")
  }
)
} # }

## ------------------------------------------------
## Method `ExchangeTradedFund$liquidate_holdings()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
if (is.null(fund$holdings)) {
  cat("No NIFTYBEES units are held, so there is nothing to sell.\n")
} else {
  limit_price <- round(fund$last_price * 1.03, 2)
  answer <- fund$liquidate_holdings(price = limit_price)
  tryCatch(
    print(answer),
    finally = print(fund$cancel_parent(answer[["parent_id"]]))
  )
}

fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES")
limit_price <- round(fund$last_price * 1.03, 2)
answer <- tryCatch(
  fund$liquidate_holdings(price = limit_price),
  HoldingError = function(error) {
    cat("Nothing to sell:", conditionMessage(error), "\n")
    NULL
  }
)
if (!is.null(answer)) {
  tryCatch(
    print(answer),
    finally = print(fund$cancel_parent(answer[["parent_id"]]))
  )
}
} # }
```
