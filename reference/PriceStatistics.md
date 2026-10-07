# Summary statistics of the prices, volumes and returns in an instrument's candles

Summaries of an instrument's prices, volumes and returns over a range.
Each method fetches the instrument's candles through `prices()` and
reduces one column to a number, a summary or a histogram. The class is
the first link after `PriceAnalysis` in the chain of analysis classes,
and `Instrument` inherits it through that chain and supplies `prices()`.

The methods form three families, each built on the one before: the
`price_` methods read `prices()`, the `volume_` methods read
`volumes()`, and the `returns_` methods read `returns()`, the fractional
change of one column from each candle to the next, whose first row is
always `NA`. Every statistic leaves out missing values, as pandas does,
and the skewness, kurtosis, quantile, summary and histogram follow
pandas' and NumPy's definitions exactly, so the figures match the Python
library's.

## Super class

[`PriceAnalysis`](https://pramodathani.github.io/tradeR/reference/PriceAnalysis.md)
-\> `PriceStatistics`

## Methods

### Public methods

- [`PriceStatistics$price_high()`](#method-PriceStatistics-price_high)

- [`PriceStatistics$price_low()`](#method-PriceStatistics-price_low)

- [`PriceStatistics$price_mean()`](#method-PriceStatistics-price_mean)

- [`PriceStatistics$price_median()`](#method-PriceStatistics-price_median)

- [`PriceStatistics$price_standard_deviation()`](#method-PriceStatistics-price_standard_deviation)

- [`PriceStatistics$price_variance()`](#method-PriceStatistics-price_variance)

- [`PriceStatistics$price_mean_absolute_deviation()`](#method-PriceStatistics-price_mean_absolute_deviation)

- [`PriceStatistics$price_skewness()`](#method-PriceStatistics-price_skewness)

- [`PriceStatistics$price_kurtosis()`](#method-PriceStatistics-price_kurtosis)

- [`PriceStatistics$price_quantile()`](#method-PriceStatistics-price_quantile)

- [`PriceStatistics$price_summary()`](#method-PriceStatistics-price_summary)

- [`PriceStatistics$price_histogram()`](#method-PriceStatistics-price_histogram)

- [`PriceStatistics$volumes()`](#method-PriceStatistics-volumes)

- [`PriceStatistics$volume_total()`](#method-PriceStatistics-volume_total)

- [`PriceStatistics$volume_high()`](#method-PriceStatistics-volume_high)

- [`PriceStatistics$volume_low()`](#method-PriceStatistics-volume_low)

- [`PriceStatistics$volume_mean()`](#method-PriceStatistics-volume_mean)

- [`PriceStatistics$volume_median()`](#method-PriceStatistics-volume_median)

- [`PriceStatistics$volume_standard_deviation()`](#method-PriceStatistics-volume_standard_deviation)

- [`PriceStatistics$volume_variance()`](#method-PriceStatistics-volume_variance)

- [`PriceStatistics$volume_mean_absolute_deviation()`](#method-PriceStatistics-volume_mean_absolute_deviation)

- [`PriceStatistics$volume_kurtosis()`](#method-PriceStatistics-volume_kurtosis)

- [`PriceStatistics$volume_skewness()`](#method-PriceStatistics-volume_skewness)

- [`PriceStatistics$volume_quantile()`](#method-PriceStatistics-volume_quantile)

- [`PriceStatistics$volume_summary()`](#method-PriceStatistics-volume_summary)

- [`PriceStatistics$volume_histogram()`](#method-PriceStatistics-volume_histogram)

- [`PriceStatistics$returns()`](#method-PriceStatistics-returns)

- [`PriceStatistics$returns_high()`](#method-PriceStatistics-returns_high)

- [`PriceStatistics$returns_low()`](#method-PriceStatistics-returns_low)

- [`PriceStatistics$returns_mean()`](#method-PriceStatistics-returns_mean)

- [`PriceStatistics$returns_median()`](#method-PriceStatistics-returns_median)

- [`PriceStatistics$returns_standard_deviation()`](#method-PriceStatistics-returns_standard_deviation)

- [`PriceStatistics$returns_variance()`](#method-PriceStatistics-returns_variance)

- [`PriceStatistics$returns_mean_absolute_deviation()`](#method-PriceStatistics-returns_mean_absolute_deviation)

- [`PriceStatistics$returns_skewness()`](#method-PriceStatistics-returns_skewness)

- [`PriceStatistics$returns_kurtosis()`](#method-PriceStatistics-returns_kurtosis)

- [`PriceStatistics$returns_quantile()`](#method-PriceStatistics-returns_quantile)

- [`PriceStatistics$returns_histogram()`](#method-PriceStatistics-returns_histogram)

- [`PriceStatistics$returns_summary()`](#method-PriceStatistics-returns_summary)

- [`PriceStatistics$clone()`](#method-PriceStatistics-clone)

Inherited methods

- [`PriceAnalysis$prices()`](https://pramodathani.github.io/tradeR/reference/PriceAnalysis.html#method-prices)

------------------------------------------------------------------------

### `PriceStatistics$price_high()`

Finds the highest high in the range.

#### Usage

    PriceStatistics$price_high(
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

The highest high as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_high(days = 365))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    year_high <- nifty$price_high(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    print(year_high)

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      year_high <- share$price_high(days = 365)
      closes <- share$prices(days = 10)$close
      last_close <- closes[[length(closes)]]
      distance <- (year_high - last_close) / year_high * 100
      cat(sprintf("%s: %.1f%% below %s\n", symbol, distance, year_high))
    }

------------------------------------------------------------------------

### `PriceStatistics$price_low()`

Finds the lowest low in the range.

#### Usage

    PriceStatistics$price_low(
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

The lowest low as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_low(days = 365))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    year_low <- nifty$price_low(days = 365)
    year_high <- nifty$price_high(days = 365)
    cat(sprintf("Range: %.1f%%\n", (year_high - year_low) / year_low * 100))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      year_low <- share$price_low(days = 365)
      closes <- share$prices(days = 10)$close
      last_close <- closes[[length(closes)]]
      distance <- (last_close - year_low) / year_low * 100
      cat(sprintf("%s: %.1f%% above %s\n", symbol, distance, year_low))
    }

------------------------------------------------------------------------

### `PriceStatistics$price_mean()`

Finds the mean of one candle column in the range.

#### Usage

    PriceStatistics$price_mean(
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

The mean as a numeric, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_mean(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      average <- share$price_mean(
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
      cat(sprintf("%s: %.2f\n", symbol, average))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    print(nifty$price_mean(column = "high", days = 90))

------------------------------------------------------------------------

### `PriceStatistics$price_median()`

Finds the median of one candle column in the range.

#### Usage

    PriceStatistics$price_median(
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

The median as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_median(days = 365))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      mean <- share$price_mean(days = 365)
      median <- share$price_median(days = 365)
      if (mean > median) {
        cat(sprintf("%s: mean %.2f > median %.2f\n", symbol, mean, median))
      } else {
        cat(sprintf("%s: mean %.2f < median %.2f\n", symbol, mean, median))
      }
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    print(
      nifty$price_median(
        column = "open",
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
    )

------------------------------------------------------------------------

### `PriceStatistics$price_standard_deviation()`

Finds the standard deviation of one candle column in the range.

#### Usage

    PriceStatistics$price_standard_deviation(
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

The standard deviation as a numeric, or `NULL` when UBI has no candles
for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_standard_deviation(days = 365))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      spread <- share$price_standard_deviation(days = 365)
      mean <- share$price_mean(days = 365)
      cat(sprintf("%s: %.1f%% of the mean\n", symbol, spread / mean * 100))
    }

    information_technology <- Watchlist$new(
      name = "information technology",
      instruments = list(
        Equity$new(exchange = "nse", symbol = "INFY"),
        Equity$new(exchange = "nse", symbol = "TCS"),
        Equity$new(exchange = "nse", symbol = "WIPRO")
      )
    )
    print(information_technology$price_standard_deviation(days = 365))

------------------------------------------------------------------------

### `PriceStatistics$price_variance()`

Finds the variance of one candle column in the range.

#### Usage

    PriceStatistics$price_variance(
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

The variance as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_variance(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      cat(sprintf("%s: %.2f\n", symbol, share$price_variance(days = 182)))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    years <- c(
      "2024",
      "2025"
    )
    for (year in years) {
      variance <- nifty$price_variance(
        from_date = paste0(year, "-01-01"),
        to_date = paste0(year, "-12-31")
      )
      cat(sprintf("%s: %.0f\n", year, variance))
    }

------------------------------------------------------------------------

### `PriceStatistics$price_mean_absolute_deviation()`

Finds the mean absolute deviation of one candle column from its mean in
the range.

#### Usage

    PriceStatistics$price_mean_absolute_deviation(
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

The mean absolute deviation as a numeric, or `NULL` when UBI has no
candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_mean_absolute_deviation(days = 365))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      absolute <- share$price_mean_absolute_deviation(days = 365)
      standard <- share$price_standard_deviation(days = 365)
      cat(sprintf("%s: %.2f against %.2f\n", symbol, absolute, standard))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    print(nifty$price_mean_absolute_deviation(column = "low", days = 90))

------------------------------------------------------------------------

### `PriceStatistics$price_skewness()`

Finds the skewness of one candle column in the range.

#### Usage

    PriceStatistics$price_skewness(
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

The skewness as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_skewness(days = 365))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      skewness <- share$price_skewness(days = 365)
      if (skewness > 0) {
        cat(sprintf("%s: %.2f, a tail of high prices\n", symbol, skewness))
      } else {
        cat(sprintf("%s: %.2f, a tail of low prices\n", symbol, skewness))
      }
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    skewness <- nifty$price_skewness(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    print(skewness)

------------------------------------------------------------------------

### `PriceStatistics$price_kurtosis()`

Finds the kurtosis of one candle column in the range.

#### Usage

    PriceStatistics$price_kurtosis(
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

The kurtosis as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_kurtosis(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      cat(sprintf("%s: %.2f\n", symbol, share$price_kurtosis(days = 365)))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    print(nifty$price_kurtosis(column = "high", days = 730))

------------------------------------------------------------------------

### `PriceStatistics$price_quantile()`

Finds a quantile of one candle column in the range.

#### Usage

    PriceStatistics$price_quantile(
      quantile = 0.5,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `quantile`:

  The numeric quantile to find, between 0 and 1, where 0.5 is the
  median.

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

The quantile as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_quantile(quantile = 0.9, days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      lower <- share$price_quantile(quantile = 0.25, days = 365)
      upper <- share$price_quantile(quantile = 0.75, days = 365)
      cat(sprintf("%s: %.2f to %.2f\n", symbol, lower, upper))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    print(
      nifty$price_quantile(
        quantile = 0.1,
        column = "low",
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
    )

------------------------------------------------------------------------

### `PriceStatistics$price_summary()`

Summarises one candle column in the range with count, mean, spread and
quartiles.

#### Usage

    PriceStatistics$price_summary(
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

A named numeric vector of summary statistics, `count`, `mean`, `std`,
`min`, `25%`, `50%`, `75%` and `max`, the same names and figures as
pandas' `describe()`, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$price_summary(days = 365))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      summary <- share$price_summary(days = 365)
      cat(
        sprintf(
          "%s: mean %.2f, from %s to %s\n",
          symbol,
          summary[["mean"]],
          summary[["min"]],
          summary[["max"]]
        )
      )
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    print(
      nifty$price_summary(
        column = "high",
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
    )

------------------------------------------------------------------------

### `PriceStatistics$price_histogram()`

Draws a histogram of one candle column in the range on the current
graphics device.

#### Usage

    PriceStatistics$price_histogram(
      bins = 50,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `bins`:

  The integer number of histogram bins.

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

The `histogram` object from
[`graphics::hist()`](https://rdrr.io/r/graphics/hist.html), whose
`breaks` are the bin edges and whose `counts` are the bar heights, after
drawing the histogram on the current graphics device, or `NULL` when UBI
has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    path <- file.path(tempdir(), "infosys_closes.png")
    grDevices::png(path)
    histogram <- infosys$price_histogram(bins = 30, days = 365)
    grDevices::dev.off()
    cat(sprintf("Saved %d bars to %s\n", length(histogram$counts), path))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    histogram <- nifty$price_histogram(bins = 20, days = 365)
    tallest_bar <- which.max(histogram$counts)
    lower <- histogram$breaks[[tallest_bar]]
    upper <- histogram$breaks[[tallest_bar + 1]]
    count <- histogram$counts[[tallest_bar]]
    cat(sprintf("%.0f closes from %.0f to %.0f\n", count, lower, upper))

------------------------------------------------------------------------

### `PriceStatistics$volumes()`

Fetches the traded volume of each candle in the range.

#### Usage

    PriceStatistics$volumes(
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

A `data.frame` with `exchange`, `segment`, `datetime`, `interval` and
`volume` columns, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volumes(days = 10))

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    volumes <- reliance$volumes(days = 365)
    busiest_row <- volumes[which.max(volumes$volume), ]
    busiest_date <- format(busiest_row$datetime, "%Y-%m-%d")
    cat(sprintf("%s: %s\n", busiest_date, busiest_row$volume))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      volumes <- share$volumes(days = 45)$volume
      last <- length(volumes)
      average <- mean(volumes[(last - 20):(last - 1)])
      ratio <- volumes[[last]] / average
      cat(sprintf("%s: %.2f times the average\n", symbol, ratio))
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_total()`

Finds the total volume traded in the range.

#### Usage

    PriceStatistics$volume_total(
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

The total volume as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_total(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      total <- share$volume_total(
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
      cat(sprintf("%s: %s\n", symbol, format(total, big.mark = ",")))
    }

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    totals <- numeric(0)
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      totals[[symbol]] <- share$volume_total(days = 30)
    }
    combined <- sum(totals)
    share_of_total <- totals[["INFY"]] / combined * 100
    cat(
      sprintf(
        "INFY: %.1f%% of %s\n",
        share_of_total,
        format(combined, big.mark = ",")
      )
    )

------------------------------------------------------------------------

### `PriceStatistics$volume_high()`

Finds the highest volume of any candle in the range.

#### Usage

    PriceStatistics$volume_high(
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

The highest volume as a numeric, or `NULL` when UBI has no candles for
the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_high(days = 365))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      busiest <- share$volume_high(days = 365)
      average <- share$volume_mean(days = 365)
      cat(sprintf("%s: %.1f times the average\n", symbol, busiest / average))
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_low()`

Finds the lowest volume of any candle in the range.

#### Usage

    PriceStatistics$volume_low(
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

The lowest volume as a numeric, or `NULL` when UBI has no candles for
the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_low(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      quietest <- share$volume_low(days = 90)
      busiest <- share$volume_high(days = 90)
      cat(
        sprintf(
          "%s: from %s to %s\n",
          symbol,
          format(quietest, big.mark = ","),
          format(busiest, big.mark = ",")
        )
      )
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_mean()`

Finds the mean volume per candle in the range.

#### Usage

    PriceStatistics$volume_mean(
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

The mean volume as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_mean(days = 365))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      month <- share$volume_mean(days = 30)
      year <- share$volume_mean(days = 365)
      ratio <- month / year
      cat(sprintf("%s: %.2f times the yearly average\n", symbol, ratio))
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_median()`

Finds the median volume per candle in the range.

#### Usage

    PriceStatistics$volume_median(
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

The median volume as a numeric, or `NULL` when UBI has no candles for
the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_median(days = 365))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      mean <- share$volume_mean(days = 365)
      median <- share$volume_median(days = 365)
      cat(sprintf("%s: mean %.2f times the median\n", symbol, mean / median))
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_standard_deviation()`

Finds the standard deviation of volume per candle in the range.

#### Usage

    PriceStatistics$volume_standard_deviation(
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

The standard deviation as a numeric, or `NULL` when UBI has no candles
for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_standard_deviation(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      spread <- share$volume_standard_deviation(days = 365)
      mean <- share$volume_mean(days = 365)
      cat(sprintf("%s: %.2f\n", symbol, spread / mean))
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    mean <- infosys$volume_mean(days = 365)
    spread <- infosys$volume_standard_deviation(days = 365)
    volumes <- infosys$volumes(days = 10)$volume
    last_volume <- volumes[[length(volumes)]]
    volume_text <- format(last_volume, big.mark = ",")
    if (last_volume > mean + 2 * spread) {
      cat(sprintf("Unusually busy: %s\n", volume_text))
    } else {
      cat(sprintf("Ordinary: %s\n", volume_text))
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_variance()`

Finds the variance of volume per candle in the range.

#### Usage

    PriceStatistics$volume_variance(
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

The variance as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_variance(days = 365))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      variance <- share$volume_variance(
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
      cat(sprintf("%s: %.3e\n", symbol, variance))
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_mean_absolute_deviation()`

Finds the mean absolute deviation of volume per candle from its mean in
the range.

#### Usage

    PriceStatistics$volume_mean_absolute_deviation(
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

The mean absolute deviation as a numeric, or `NULL` when UBI has no
candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_mean_absolute_deviation(days = 365))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      deviation <- share$volume_mean_absolute_deviation(days = 365)
      mean <- share$volume_mean(days = 365)
      cat(sprintf("%s: %.0f%%\n", symbol, deviation / mean * 100))
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_kurtosis()`

Finds the kurtosis of volume per candle in the range.

#### Usage

    PriceStatistics$volume_kurtosis(
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

The kurtosis as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_kurtosis(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      cat(sprintf("%s: %.2f\n", symbol, share$volume_kurtosis(days = 365)))
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_skewness()`

Finds the skewness of volume per candle in the range.

#### Usage

    PriceStatistics$volume_skewness(
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

The skewness as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_skewness(days = 365))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      cat(sprintf("%s: %.2f\n", symbol, share$volume_skewness(days = 365)))
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_quantile()`

Finds a quantile of volume per candle in the range.

#### Usage

    PriceStatistics$volume_quantile(
      quantile = 0.5,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `quantile`:

  The numeric quantile to find, between 0 and 1, where 0.5 is the
  median.

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

The quantile as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_quantile(quantile = 0.9, days = 365))

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    threshold <- reliance$volume_quantile(quantile = 0.9, days = 365)
    volumes <- reliance$volumes(days = 365)$volume
    busy_days <- 0
    for (volume in volumes) {
      if (volume > threshold) {
        busy_days <- busy_days + 1
      }
    }
    threshold_text <- formatC(threshold, format = "f", digits = 0, big.mark = ",")
    cat(sprintf("%d days above %s\n", busy_days, threshold_text))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      lower <- share$volume_quantile(quantile = 0.25, days = 365)
      median <- share$volume_quantile(quantile = 0.5, days = 365)
      cat(
        sprintf(
          "%s: %s and %s\n",
          symbol,
          formatC(lower, format = "f", digits = 0, big.mark = ","),
          formatC(median, format = "f", digits = 0, big.mark = ",")
        )
      )
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_summary()`

Summarises volume per candle in the range with count, mean, spread and
quartiles.

#### Usage

    PriceStatistics$volume_summary(
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

A named numeric vector of summary statistics, `count`, `mean`, `std`,
`min`, `25%`, `50%`, `75%` and `max`, the same names and figures as
pandas' `describe()`, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$volume_summary(days = 365))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      summary <- share$volume_summary(days = 365)
      average <- summary[["mean"]]
      busiest <- summary[["max"]]
      cat(
        sprintf(
          "%s: %s, at most %s\n",
          symbol,
          formatC(average, format = "f", digits = 0, big.mark = ","),
          formatC(busiest, format = "f", digits = 0, big.mark = ",")
        )
      )
    }

------------------------------------------------------------------------

### `PriceStatistics$volume_histogram()`

Draws a histogram of volume per candle in the range on the current
graphics device.

#### Usage

    PriceStatistics$volume_histogram(
      bins = 50,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `bins`:

  The integer number of histogram bins.

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

The `histogram` object from
[`graphics::hist()`](https://rdrr.io/r/graphics/hist.html), whose
`breaks` are the bin edges and whose `counts` are the bar heights, after
drawing the histogram on the current graphics device, or `NULL` when UBI
has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    path <- file.path(tempdir(), "infosys_volumes.png")
    grDevices::png(path)
    histogram <- infosys$volume_histogram(bins = 40, days = 365)
    grDevices::dev.off()
    cat(sprintf("Saved %d bars to %s\n", length(histogram$counts), path))

    reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    histogram <- reliance$volume_histogram(bins = 20, days = 365)
    tallest_bar <- which.max(histogram$counts)
    lower <- histogram$breaks[[tallest_bar]]
    upper <- histogram$breaks[[tallest_bar + 1]]
    count <- histogram$counts[[tallest_bar]]
    cat(
      sprintf(
        "%.0f days from %s to %s\n",
        count,
        formatC(lower, format = "f", digits = 0, big.mark = ","),
        formatC(upper, format = "f", digits = 0, big.mark = ",")
      )
    )

------------------------------------------------------------------------

### `PriceStatistics$returns()`

Calculates the fractional change of one candle column from each candle
to the next.

#### Usage

    PriceStatistics$returns(
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

A `data.frame` with `exchange`, `segment`, `datetime`, `interval` and
`returns` columns, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns(days = 10))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    returns <- nifty$returns(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    growth <- 1
    for (daily_return in returns$returns[!is.na(returns$returns)]) {
      growth <- growth * (1 + daily_return)
    }
    cat(sprintf("%.2f%%\n", (growth - 1) * 100))

    information_technology <- Watchlist$new(
      name = "information technology",
      instruments = list(
        Equity$new(exchange = "nse", symbol = "INFY"),
        Equity$new(exchange = "nse", symbol = "TCS"),
        Equity$new(exchange = "nse", symbol = "WIPRO")
      )
    )
    print(information_technology$returns(days = 10))

------------------------------------------------------------------------

### `PriceStatistics$returns_high()`

Finds the highest return of one candle column in the range.

#### Usage

    PriceStatistics$returns_high(
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

The highest return as a numeric, or `NULL` when UBI has no candles for
the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_high(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      best <- share$returns_high(days = 365) * 100
      cat(sprintf("%s: %.2f%%\n", symbol, best))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    best <- nifty$returns_high(
      column = "high",
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    cat(sprintf("%.2f%%\n", best * 100))

------------------------------------------------------------------------

### `PriceStatistics$returns_low()`

Finds the lowest return of one candle column in the range.

#### Usage

    PriceStatistics$returns_low(
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

The lowest return as a numeric, or `NULL` when UBI has no candles for
the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_low(days = 365))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      worst <- share$returns_low(days = 365) * 100
      best <- share$returns_high(days = 365) * 100
      cat(sprintf("%s: from %.2f%% to %.2f%%\n", symbol, worst, best))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    worst <- nifty$returns_low(
      from_date = "2025-01-01",
      to_date = "2025-12-31"
    )
    cat(sprintf("%.2f%%\n", worst * 100))

------------------------------------------------------------------------

### `PriceStatistics$returns_mean()`

Finds the mean return of one candle column in the range.

#### Usage

    PriceStatistics$returns_mean(
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

The mean return as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_mean(days = 365))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      annual <- share$returns_mean(days = 365) * 252
      cat(sprintf("%s: %.1f%% a year\n", symbol, annual * 100))
    }

    information_technology <- Watchlist$new(
      name = "information technology",
      instruments = list(
        Equity$new(exchange = "nse", symbol = "INFY"),
        Equity$new(exchange = "nse", symbol = "TCS"),
        Equity$new(exchange = "nse", symbol = "WIPRO")
      )
    )
    print(information_technology$returns_mean(days = 365))

------------------------------------------------------------------------

### `PriceStatistics$returns_median()`

Finds the median return of one candle column in the range.

#### Usage

    PriceStatistics$returns_median(
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

The median return as a numeric, or `NULL` when UBI has no candles for
the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_median(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      median <- share$returns_median(days = 365)
      mean <- share$returns_mean(days = 365)
      cat(sprintf("%s: median %.5f, mean %.5f\n", symbol, median, mean))
    }

------------------------------------------------------------------------

### `PriceStatistics$returns_standard_deviation()`

Finds the standard deviation of returns of one candle column in the
range.

#### Usage

    PriceStatistics$returns_standard_deviation(
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

The standard deviation as a numeric, or `NULL` when UBI has no candles
for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_standard_deviation(days = 365))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      daily <- share$returns_standard_deviation(days = 365)
      annual <- daily * sqrt(252)
      cat(sprintf("%s: %.1f%% a year\n", symbol, annual * 100))
    }

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    information_technology <- Watchlist$new(
      name = "information technology",
      instruments = list(
        infosys,
        Equity$new(exchange = "nse", symbol = "TCS"),
        Equity$new(exchange = "nse", symbol = "WIPRO")
      )
    )
    basket <- information_technology$returns_standard_deviation(days = 365)
    single <- infosys$returns_standard_deviation(days = 365)
    cat(sprintf("Basket %.4f against Infosys %.4f\n", basket, single))

------------------------------------------------------------------------

### `PriceStatistics$returns_variance()`

Finds the variance of returns of one candle column in the range.

#### Usage

    PriceStatistics$returns_variance(
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

The variance as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_variance(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      annual <- share$returns_variance(days = 365) * 252
      cat(sprintf("%s: %.4f\n", symbol, annual))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    years <- c(
      "2024",
      "2025"
    )
    for (year in years) {
      variance <- nifty$returns_variance(
        from_date = paste0(year, "-01-01"),
        to_date = paste0(year, "-12-31")
      )
      cat(sprintf("%s: %.6f\n", year, variance))
    }

------------------------------------------------------------------------

### `PriceStatistics$returns_mean_absolute_deviation()`

Finds the mean absolute deviation of returns of one candle column from
their mean in the range.

#### Usage

    PriceStatistics$returns_mean_absolute_deviation(
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

The mean absolute deviation as a numeric, or `NULL` when UBI has no
candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_mean_absolute_deviation(days = 365))

    symbols <- c(
      "INFY",
      "TCS",
      "WIPRO"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      deviation <- share$returns_mean_absolute_deviation(days = 365)
      cat(sprintf("%s: %.2f%%\n", symbol, deviation * 100))
    }

------------------------------------------------------------------------

### `PriceStatistics$returns_skewness()`

Finds the skewness of returns of one candle column in the range.

#### Usage

    PriceStatistics$returns_skewness(
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

The skewness as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_skewness(days = 365))

    symbols <- c(
      "RELIANCE",
      "INFY",
      "HDFCBANK"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      skewness <- share$returns_skewness(days = 365)
      if (skewness > 0) {
        cat(sprintf("%s: %.2f, more large rises\n", symbol, skewness))
      } else {
        cat(sprintf("%s: %.2f, more large falls\n", symbol, skewness))
      }
    }

------------------------------------------------------------------------

### `PriceStatistics$returns_kurtosis()`

Finds the kurtosis of returns of one candle column in the range.

#### Usage

    PriceStatistics$returns_kurtosis(
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

The kurtosis as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_kurtosis(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      cat(sprintf("%s: %.2f\n", symbol, share$returns_kurtosis(days = 365)))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    print(nifty$returns_kurtosis(days = 730))

------------------------------------------------------------------------

### `PriceStatistics$returns_quantile()`

Finds a quantile of returns of one candle column in the range.

#### Usage

    PriceStatistics$returns_quantile(
      quantile = 0.5,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `quantile`:

  The numeric quantile to find, between 0 and 1, where 0.5 is the
  median.

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

The quantile as a numeric, or `NULL` when UBI has no candles for the
range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_quantile(quantile = 0.05, days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      fifth_percentile <- share$returns_quantile(
        quantile = 0.05,
        days = 365
      )
      loss <- -fifth_percentile * 100000
      loss_text <- formatC(loss, format = "f", digits = 0, big.mark = ",")
      cat(sprintf("%s: Rs %s\n", symbol, loss_text))
    }

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    print(
      nifty$returns_quantile(
        quantile = 0.95,
        from_date = "2025-01-01",
        to_date = "2025-12-31"
      )
    )

------------------------------------------------------------------------

### `PriceStatistics$returns_histogram()`

Draws a histogram of returns of one candle column in the range on the
current graphics device.

#### Usage

    PriceStatistics$returns_histogram(
      bins = 50,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    )

#### Arguments

- `bins`:

  The integer number of histogram bins.

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

The `histogram` object from
[`graphics::hist()`](https://rdrr.io/r/graphics/hist.html), whose
`breaks` are the bin edges and whose `counts` are the bar heights, after
drawing the histogram on the current graphics device, or `NULL` when UBI
has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    path <- file.path(tempdir(), "infosys_returns.png")
    grDevices::png(path)
    histogram <- infosys$returns_histogram(bins = 40, days = 365)
    grDevices::dev.off()
    cat(sprintf("Saved %d bars to %s\n", length(histogram$counts), path))

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    histogram <- nifty$returns_histogram(bins = 30, days = 365)
    falling_days <- 0
    for (bar in seq_along(histogram$counts)) {
      if (histogram$breaks[[bar + 1]] <= 0) {
        falling_days <- falling_days + histogram$counts[[bar]]
      }
    }
    cat(sprintf("%.0f days in bars wholly below zero\n", falling_days))

------------------------------------------------------------------------

### `PriceStatistics$returns_summary()`

Summarises returns of one candle column in the range with count, mean,
spread and quartiles.

#### Usage

    PriceStatistics$returns_summary(
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

A named numeric vector of summary statistics, `count`, `mean`, `std`,
`min`, `25%`, `50%`, `75%` and `max`, the same names and figures as
pandas' `describe()`, or `NULL` when UBI has no candles for the range.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    print(infosys$returns_summary(days = 365))

    symbols <- c(
      "HDFCBANK",
      "ICICIBANK",
      "SBIN"
    )
    for (symbol in symbols) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      summary <- share$returns_summary(days = 365)
      cat(
        sprintf(
          "%s: mean %.4f, deviation %.4f, worst %.4f\n",
          symbol,
          summary[["mean"]],
          summary[["std"]],
          summary[["min"]]
        )
      )
    }

    information_technology <- Watchlist$new(
      name = "information technology",
      instruments = list(
        Equity$new(exchange = "nse", symbol = "INFY"),
        Equity$new(exchange = "nse", symbol = "TCS"),
        Equity$new(exchange = "nse", symbol = "WIPRO")
      )
    )
    print(information_technology$returns_summary(days = 365))

------------------------------------------------------------------------

### `PriceStatistics$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PriceStatistics$clone(deep = FALSE)

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
infosys$price_mean(column = "close", days = 365)
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_high()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_high(days = 365))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
year_high <- nifty$price_high(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
print(year_high)

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  year_high <- share$price_high(days = 365)
  closes <- share$prices(days = 10)$close
  last_close <- closes[[length(closes)]]
  distance <- (year_high - last_close) / year_high * 100
  cat(sprintf("%s: %.1f%% below %s\n", symbol, distance, year_high))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_low()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_low(days = 365))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
year_low <- nifty$price_low(days = 365)
year_high <- nifty$price_high(days = 365)
cat(sprintf("Range: %.1f%%\n", (year_high - year_low) / year_low * 100))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  year_low <- share$price_low(days = 365)
  closes <- share$prices(days = 10)$close
  last_close <- closes[[length(closes)]]
  distance <- (last_close - year_low) / year_low * 100
  cat(sprintf("%s: %.1f%% above %s\n", symbol, distance, year_low))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_mean()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_mean(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  average <- share$price_mean(
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
  cat(sprintf("%s: %.2f\n", symbol, average))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
print(nifty$price_mean(column = "high", days = 90))
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_median()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_median(days = 365))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  mean <- share$price_mean(days = 365)
  median <- share$price_median(days = 365)
  if (mean > median) {
    cat(sprintf("%s: mean %.2f > median %.2f\n", symbol, mean, median))
  } else {
    cat(sprintf("%s: mean %.2f < median %.2f\n", symbol, mean, median))
  }
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
print(
  nifty$price_median(
    column = "open",
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
)
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_standard_deviation()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_standard_deviation(days = 365))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  spread <- share$price_standard_deviation(days = 365)
  mean <- share$price_mean(days = 365)
  cat(sprintf("%s: %.1f%% of the mean\n", symbol, spread / mean * 100))
}

information_technology <- Watchlist$new(
  name = "information technology",
  instruments = list(
    Equity$new(exchange = "nse", symbol = "INFY"),
    Equity$new(exchange = "nse", symbol = "TCS"),
    Equity$new(exchange = "nse", symbol = "WIPRO")
  )
)
print(information_technology$price_standard_deviation(days = 365))
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_variance()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_variance(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  cat(sprintf("%s: %.2f\n", symbol, share$price_variance(days = 182)))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
years <- c(
  "2024",
  "2025"
)
for (year in years) {
  variance <- nifty$price_variance(
    from_date = paste0(year, "-01-01"),
    to_date = paste0(year, "-12-31")
  )
  cat(sprintf("%s: %.0f\n", year, variance))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_mean_absolute_deviation()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_mean_absolute_deviation(days = 365))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  absolute <- share$price_mean_absolute_deviation(days = 365)
  standard <- share$price_standard_deviation(days = 365)
  cat(sprintf("%s: %.2f against %.2f\n", symbol, absolute, standard))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
print(nifty$price_mean_absolute_deviation(column = "low", days = 90))
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_skewness()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_skewness(days = 365))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  skewness <- share$price_skewness(days = 365)
  if (skewness > 0) {
    cat(sprintf("%s: %.2f, a tail of high prices\n", symbol, skewness))
  } else {
    cat(sprintf("%s: %.2f, a tail of low prices\n", symbol, skewness))
  }
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
skewness <- nifty$price_skewness(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
print(skewness)
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_kurtosis()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_kurtosis(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  cat(sprintf("%s: %.2f\n", symbol, share$price_kurtosis(days = 365)))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
print(nifty$price_kurtosis(column = "high", days = 730))
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_quantile()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_quantile(quantile = 0.9, days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  lower <- share$price_quantile(quantile = 0.25, days = 365)
  upper <- share$price_quantile(quantile = 0.75, days = 365)
  cat(sprintf("%s: %.2f to %.2f\n", symbol, lower, upper))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
print(
  nifty$price_quantile(
    quantile = 0.1,
    column = "low",
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
)
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_summary()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$price_summary(days = 365))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  summary <- share$price_summary(days = 365)
  cat(
    sprintf(
      "%s: mean %.2f, from %s to %s\n",
      symbol,
      summary[["mean"]],
      summary[["min"]],
      summary[["max"]]
    )
  )
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
print(
  nifty$price_summary(
    column = "high",
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
)
} # }

## ------------------------------------------------
## Method `PriceStatistics$price_histogram()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
path <- file.path(tempdir(), "infosys_closes.png")
grDevices::png(path)
histogram <- infosys$price_histogram(bins = 30, days = 365)
grDevices::dev.off()
cat(sprintf("Saved %d bars to %s\n", length(histogram$counts), path))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
histogram <- nifty$price_histogram(bins = 20, days = 365)
tallest_bar <- which.max(histogram$counts)
lower <- histogram$breaks[[tallest_bar]]
upper <- histogram$breaks[[tallest_bar + 1]]
count <- histogram$counts[[tallest_bar]]
cat(sprintf("%.0f closes from %.0f to %.0f\n", count, lower, upper))
} # }

## ------------------------------------------------
## Method `PriceStatistics$volumes()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volumes(days = 10))

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
volumes <- reliance$volumes(days = 365)
busiest_row <- volumes[which.max(volumes$volume), ]
busiest_date <- format(busiest_row$datetime, "%Y-%m-%d")
cat(sprintf("%s: %s\n", busiest_date, busiest_row$volume))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  volumes <- share$volumes(days = 45)$volume
  last <- length(volumes)
  average <- mean(volumes[(last - 20):(last - 1)])
  ratio <- volumes[[last]] / average
  cat(sprintf("%s: %.2f times the average\n", symbol, ratio))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_total()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_total(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  total <- share$volume_total(
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
  cat(sprintf("%s: %s\n", symbol, format(total, big.mark = ",")))
}

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
totals <- numeric(0)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  totals[[symbol]] <- share$volume_total(days = 30)
}
combined <- sum(totals)
share_of_total <- totals[["INFY"]] / combined * 100
cat(
  sprintf(
    "INFY: %.1f%% of %s\n",
    share_of_total,
    format(combined, big.mark = ",")
  )
)
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_high()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_high(days = 365))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  busiest <- share$volume_high(days = 365)
  average <- share$volume_mean(days = 365)
  cat(sprintf("%s: %.1f times the average\n", symbol, busiest / average))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_low()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_low(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  quietest <- share$volume_low(days = 90)
  busiest <- share$volume_high(days = 90)
  cat(
    sprintf(
      "%s: from %s to %s\n",
      symbol,
      format(quietest, big.mark = ","),
      format(busiest, big.mark = ",")
    )
  )
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_mean()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_mean(days = 365))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  month <- share$volume_mean(days = 30)
  year <- share$volume_mean(days = 365)
  ratio <- month / year
  cat(sprintf("%s: %.2f times the yearly average\n", symbol, ratio))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_median()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_median(days = 365))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  mean <- share$volume_mean(days = 365)
  median <- share$volume_median(days = 365)
  cat(sprintf("%s: mean %.2f times the median\n", symbol, mean / median))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_standard_deviation()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_standard_deviation(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  spread <- share$volume_standard_deviation(days = 365)
  mean <- share$volume_mean(days = 365)
  cat(sprintf("%s: %.2f\n", symbol, spread / mean))
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
mean <- infosys$volume_mean(days = 365)
spread <- infosys$volume_standard_deviation(days = 365)
volumes <- infosys$volumes(days = 10)$volume
last_volume <- volumes[[length(volumes)]]
volume_text <- format(last_volume, big.mark = ",")
if (last_volume > mean + 2 * spread) {
  cat(sprintf("Unusually busy: %s\n", volume_text))
} else {
  cat(sprintf("Ordinary: %s\n", volume_text))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_variance()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_variance(days = 365))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  variance <- share$volume_variance(
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
  cat(sprintf("%s: %.3e\n", symbol, variance))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_mean_absolute_deviation()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_mean_absolute_deviation(days = 365))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  deviation <- share$volume_mean_absolute_deviation(days = 365)
  mean <- share$volume_mean(days = 365)
  cat(sprintf("%s: %.0f%%\n", symbol, deviation / mean * 100))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_kurtosis()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_kurtosis(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  cat(sprintf("%s: %.2f\n", symbol, share$volume_kurtosis(days = 365)))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_skewness()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_skewness(days = 365))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  cat(sprintf("%s: %.2f\n", symbol, share$volume_skewness(days = 365)))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_quantile()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_quantile(quantile = 0.9, days = 365))

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
threshold <- reliance$volume_quantile(quantile = 0.9, days = 365)
volumes <- reliance$volumes(days = 365)$volume
busy_days <- 0
for (volume in volumes) {
  if (volume > threshold) {
    busy_days <- busy_days + 1
  }
}
threshold_text <- formatC(threshold, format = "f", digits = 0, big.mark = ",")
cat(sprintf("%d days above %s\n", busy_days, threshold_text))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  lower <- share$volume_quantile(quantile = 0.25, days = 365)
  median <- share$volume_quantile(quantile = 0.5, days = 365)
  cat(
    sprintf(
      "%s: %s and %s\n",
      symbol,
      formatC(lower, format = "f", digits = 0, big.mark = ","),
      formatC(median, format = "f", digits = 0, big.mark = ",")
    )
  )
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_summary()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$volume_summary(days = 365))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  summary <- share$volume_summary(days = 365)
  average <- summary[["mean"]]
  busiest <- summary[["max"]]
  cat(
    sprintf(
      "%s: %s, at most %s\n",
      symbol,
      formatC(average, format = "f", digits = 0, big.mark = ","),
      formatC(busiest, format = "f", digits = 0, big.mark = ",")
    )
  )
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$volume_histogram()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
path <- file.path(tempdir(), "infosys_volumes.png")
grDevices::png(path)
histogram <- infosys$volume_histogram(bins = 40, days = 365)
grDevices::dev.off()
cat(sprintf("Saved %d bars to %s\n", length(histogram$counts), path))

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
histogram <- reliance$volume_histogram(bins = 20, days = 365)
tallest_bar <- which.max(histogram$counts)
lower <- histogram$breaks[[tallest_bar]]
upper <- histogram$breaks[[tallest_bar + 1]]
count <- histogram$counts[[tallest_bar]]
cat(
  sprintf(
    "%.0f days from %s to %s\n",
    count,
    formatC(lower, format = "f", digits = 0, big.mark = ","),
    formatC(upper, format = "f", digits = 0, big.mark = ",")
  )
)
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns(days = 10))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
returns <- nifty$returns(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
growth <- 1
for (daily_return in returns$returns[!is.na(returns$returns)]) {
  growth <- growth * (1 + daily_return)
}
cat(sprintf("%.2f%%\n", (growth - 1) * 100))

information_technology <- Watchlist$new(
  name = "information technology",
  instruments = list(
    Equity$new(exchange = "nse", symbol = "INFY"),
    Equity$new(exchange = "nse", symbol = "TCS"),
    Equity$new(exchange = "nse", symbol = "WIPRO")
  )
)
print(information_technology$returns(days = 10))
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_high()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_high(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  best <- share$returns_high(days = 365) * 100
  cat(sprintf("%s: %.2f%%\n", symbol, best))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
best <- nifty$returns_high(
  column = "high",
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
cat(sprintf("%.2f%%\n", best * 100))
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_low()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_low(days = 365))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  worst <- share$returns_low(days = 365) * 100
  best <- share$returns_high(days = 365) * 100
  cat(sprintf("%s: from %.2f%% to %.2f%%\n", symbol, worst, best))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
worst <- nifty$returns_low(
  from_date = "2025-01-01",
  to_date = "2025-12-31"
)
cat(sprintf("%.2f%%\n", worst * 100))
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_mean()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_mean(days = 365))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  annual <- share$returns_mean(days = 365) * 252
  cat(sprintf("%s: %.1f%% a year\n", symbol, annual * 100))
}

information_technology <- Watchlist$new(
  name = "information technology",
  instruments = list(
    Equity$new(exchange = "nse", symbol = "INFY"),
    Equity$new(exchange = "nse", symbol = "TCS"),
    Equity$new(exchange = "nse", symbol = "WIPRO")
  )
)
print(information_technology$returns_mean(days = 365))
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_median()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_median(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  median <- share$returns_median(days = 365)
  mean <- share$returns_mean(days = 365)
  cat(sprintf("%s: median %.5f, mean %.5f\n", symbol, median, mean))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_standard_deviation()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_standard_deviation(days = 365))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  daily <- share$returns_standard_deviation(days = 365)
  annual <- daily * sqrt(252)
  cat(sprintf("%s: %.1f%% a year\n", symbol, annual * 100))
}

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
information_technology <- Watchlist$new(
  name = "information technology",
  instruments = list(
    infosys,
    Equity$new(exchange = "nse", symbol = "TCS"),
    Equity$new(exchange = "nse", symbol = "WIPRO")
  )
)
basket <- information_technology$returns_standard_deviation(days = 365)
single <- infosys$returns_standard_deviation(days = 365)
cat(sprintf("Basket %.4f against Infosys %.4f\n", basket, single))
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_variance()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_variance(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  annual <- share$returns_variance(days = 365) * 252
  cat(sprintf("%s: %.4f\n", symbol, annual))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
years <- c(
  "2024",
  "2025"
)
for (year in years) {
  variance <- nifty$returns_variance(
    from_date = paste0(year, "-01-01"),
    to_date = paste0(year, "-12-31")
  )
  cat(sprintf("%s: %.6f\n", year, variance))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_mean_absolute_deviation()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_mean_absolute_deviation(days = 365))

symbols <- c(
  "INFY",
  "TCS",
  "WIPRO"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  deviation <- share$returns_mean_absolute_deviation(days = 365)
  cat(sprintf("%s: %.2f%%\n", symbol, deviation * 100))
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_skewness()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_skewness(days = 365))

symbols <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  skewness <- share$returns_skewness(days = 365)
  if (skewness > 0) {
    cat(sprintf("%s: %.2f, more large rises\n", symbol, skewness))
  } else {
    cat(sprintf("%s: %.2f, more large falls\n", symbol, skewness))
  }
}
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_kurtosis()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_kurtosis(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  cat(sprintf("%s: %.2f\n", symbol, share$returns_kurtosis(days = 365)))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
print(nifty$returns_kurtosis(days = 730))
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_quantile()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_quantile(quantile = 0.05, days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  fifth_percentile <- share$returns_quantile(
    quantile = 0.05,
    days = 365
  )
  loss <- -fifth_percentile * 100000
  loss_text <- formatC(loss, format = "f", digits = 0, big.mark = ",")
  cat(sprintf("%s: Rs %s\n", symbol, loss_text))
}

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
print(
  nifty$returns_quantile(
    quantile = 0.95,
    from_date = "2025-01-01",
    to_date = "2025-12-31"
  )
)
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_histogram()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
path <- file.path(tempdir(), "infosys_returns.png")
grDevices::png(path)
histogram <- infosys$returns_histogram(bins = 40, days = 365)
grDevices::dev.off()
cat(sprintf("Saved %d bars to %s\n", length(histogram$counts), path))

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
histogram <- nifty$returns_histogram(bins = 30, days = 365)
falling_days <- 0
for (bar in seq_along(histogram$counts)) {
  if (histogram$breaks[[bar + 1]] <= 0) {
    falling_days <- falling_days + histogram$counts[[bar]]
  }
}
cat(sprintf("%.0f days in bars wholly below zero\n", falling_days))
} # }

## ------------------------------------------------
## Method `PriceStatistics$returns_summary()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
print(infosys$returns_summary(days = 365))

symbols <- c(
  "HDFCBANK",
  "ICICIBANK",
  "SBIN"
)
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  summary <- share$returns_summary(days = 365)
  cat(
    sprintf(
      "%s: mean %.4f, deviation %.4f, worst %.4f\n",
      symbol,
      summary[["mean"]],
      summary[["std"]],
      summary[["min"]]
    )
  )
}

information_technology <- Watchlist$new(
  name = "information technology",
  instruments = list(
    Equity$new(exchange = "nse", symbol = "INFY"),
    Equity$new(exchange = "nse", symbol = "TCS"),
    Equity$new(exchange = "nse", symbol = "WIPRO")
  )
)
print(information_technology$returns_summary(days = 365))
} # }
```
