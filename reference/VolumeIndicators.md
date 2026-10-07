# Indicators an instrument calculates from its candles' prices and volumes

Measures that combine price with traded volume. Each method fetches the
instrument's candles through `prices()`, adds one TA-Lib column,
computed by the `talib` package, and returns the candles. The class is a
link in the chain of analysis classes, inheriting `MomentumIndicators`,
and `Instrument` inherits it through that chain and supplies `prices()`.

## Super classes

[`PriceAnalysis`](https://pramodathani.github.io/tradeR/reference/PriceAnalysis.md)
-\>
[`PriceStatistics`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.md)
-\>
[`OverlapStudies`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.md)
-\>
[`MomentumIndicators`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.md)
-\> `VolumeIndicators`

## Methods

### Public methods

- [`VolumeIndicators$chaikin_accumulation_distribution_line()`](#method-VolumeIndicators-chaikin_accumulation_distribution_line)

- [`VolumeIndicators$chaikin_accumulation_distribution_oscillator()`](#method-VolumeIndicators-chaikin_accumulation_distribution_oscillator)

- [`VolumeIndicators$on_balance_volume()`](#method-VolumeIndicators-on_balance_volume)

- [`VolumeIndicators$clone()`](#method-VolumeIndicators-clone)

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

------------------------------------------------------------------------

### `VolumeIndicators$chaikin_accumulation_distribution_line()`

Adds the Chaikin accumulation distribution line.

#### Usage

    VolumeIndicators$chaikin_accumulation_distribution_line(
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

A `data.frame` of the candles with a `chaikin_ad` column added, or
`NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$chaikin_accumulation_distribution_line(days = 90)
    print(tail(candles[, c("datetime", "close", "chaikin_ad")], 5))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$chaikin_accumulation_distribution_line(days = 45)
      line <- candles$chaikin_ad
      change <- line[[length(line)]] - line[[length(line) - 20]]
      if (change > 0) {
        amount <- formatC(change, format = "f", digits = 0, big.mark = ",")
        cat(sprintf("%s: accumulation of %s\n", symbol, amount))
      } else {
        amount <- formatC(-change, format = "f", digits = 0, big.mark = ",")
        cat(sprintf("%s: distribution of %s\n", symbol, amount))
      }
    }

------------------------------------------------------------------------

### `VolumeIndicators$chaikin_accumulation_distribution_oscillator()`

Adds the Chaikin accumulation distribution oscillator.

#### Usage

    VolumeIndicators$chaikin_accumulation_distribution_oscillator(
      fast_period = 3,
      slow_period = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `fast_period`:

  The integer number of candles in the fast exponential moving average.

- `slow_period`:

  The integer number of candles in the slow exponential moving average.

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

A `data.frame` of the candles with a `chaikin_adosc<fast>_<slow>` column
added, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$chaikin_accumulation_distribution_oscillator(
      days = 90
    )
    print(tail(candles[, c("datetime", "close", "chaikin_adosc3_10")], 5))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$chaikin_accumulation_distribution_oscillator(
        fast_period = 5,
        slow_period = 20,
        days = 120
      )
      value <- candles$chaikin_adosc5_20[[nrow(candles)]]
      amount <- formatC(value, format = "f", digits = 0, big.mark = ",")
      if (value > 0) {
        cat(sprintf("%s: buying pressure %s\n", symbol, amount))
      } else {
        cat(sprintf("%s: selling pressure %s\n", symbol, amount))
      }
    }

------------------------------------------------------------------------

### `VolumeIndicators$on_balance_volume()`

Adds the on balance volume, measured against one candle column.

#### Usage

    VolumeIndicators$on_balance_volume(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

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
request or could not be reached.

#### Returns

A `data.frame` of the candles with an `obv` column added, or `NULL` when
UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    candles <- infosys$on_balance_volume(days = 90)
    print(tail(candles[, c("datetime", "close", "volume", "obv")], 5))

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    candles <- reliance$on_balance_volume(days = 45)
    closes <- candles$close
    volume_line <- candles$obv
    last <- nrow(candles)
    price_change <- closes[[last]] - closes[[last - 20]]
    volume_change <- volume_line[[last]] - volume_line[[last - 20]]
    if ((price_change > 0) == (volume_change > 0)) {
      cat("Volume confirms the price move\n")
    } else {
      cat("Volume diverges from the price move\n")
    }

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      candles <- share$on_balance_volume(column = "open", days = 60)
      latest <- candles$obv[[nrow(candles)]]
      amount <- formatC(latest, format = "f", digits = 0, big.mark = ",")
      cat(sprintf("%s: %s\n", symbol, amount))
    }

------------------------------------------------------------------------

### `VolumeIndicators$clone()`

The objects of this class are cloneable with this method.

#### Usage

    VolumeIndicators$clone(deep = FALSE)

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
frame <- infosys$on_balance_volume(days = 365)
} # }

## ------------------------------------------------
## Method `VolumeIndicators$chaikin_accumulation_distribution_line()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$chaikin_accumulation_distribution_line(days = 90)
print(tail(candles[, c("datetime", "close", "chaikin_ad")], 5))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$chaikin_accumulation_distribution_line(days = 45)
  line <- candles$chaikin_ad
  change <- line[[length(line)]] - line[[length(line) - 20]]
  if (change > 0) {
    amount <- formatC(change, format = "f", digits = 0, big.mark = ",")
    cat(sprintf("%s: accumulation of %s\n", symbol, amount))
  } else {
    amount <- formatC(-change, format = "f", digits = 0, big.mark = ",")
    cat(sprintf("%s: distribution of %s\n", symbol, amount))
  }
}
} # }

## ------------------------------------------------
## Method `VolumeIndicators$chaikin_accumulation_distribution_oscillator()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$chaikin_accumulation_distribution_oscillator(
  days = 90
)
print(tail(candles[, c("datetime", "close", "chaikin_adosc3_10")], 5))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$chaikin_accumulation_distribution_oscillator(
    fast_period = 5,
    slow_period = 20,
    days = 120
  )
  value <- candles$chaikin_adosc5_20[[nrow(candles)]]
  amount <- formatC(value, format = "f", digits = 0, big.mark = ",")
  if (value > 0) {
    cat(sprintf("%s: buying pressure %s\n", symbol, amount))
  } else {
    cat(sprintf("%s: selling pressure %s\n", symbol, amount))
  }
}
} # }

## ------------------------------------------------
## Method `VolumeIndicators$on_balance_volume()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
candles <- infosys$on_balance_volume(days = 90)
print(tail(candles[, c("datetime", "close", "volume", "obv")], 5))

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
candles <- reliance$on_balance_volume(days = 45)
closes <- candles$close
volume_line <- candles$obv
last <- nrow(candles)
price_change <- closes[[last]] - closes[[last - 20]]
volume_change <- volume_line[[last]] - volume_line[[last - 20]]
if ((price_change > 0) == (volume_change > 0)) {
  cat("Volume confirms the price move\n")
} else {
  cat("Volume diverges from the price move\n")
}

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  candles <- share$on_balance_volume(column = "open", days = 60)
  latest <- candles$obv[[nrow(candles)]]
  amount <- formatC(latest, format = "f", digits = 0, big.mark = ",")
  cat(sprintf("%s: %s\n", symbol, amount))
}
} # }
```
