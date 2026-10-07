test_that("price statistics match the values Python gave on the same candles", {
  candles <- SyntheticCandles$new()

  expect_equal(candles$price_mean(), 106.27441160400927, tolerance = 1e-12)
  expect_equal(candles$price_skewness(), -0.0326585483883595, tolerance = 1e-12)
  expect_equal(candles$price_kurtosis(), -1.086033831211235, tolerance = 1e-12)
  expect_equal(
    candles$price_quantile(quantile = 0.9, column = "high"),
    118.48664091122473,
    tolerance = 1e-12
  )
})

test_that("price_summary has pandas' describe() names and figures", {
  summary <- SyntheticCandles$new()$price_summary()

  expect_equal(
    names(summary),
    c(
      "count",
      "mean",
      "std",
      "min",
      "25%",
      "50%",
      "75%",
      "max"
    )
  )
  expect_equal(
    unname(summary),
    c(
      120,
      106.27441160400927,
      7.471925439344894,
      91.98834917504223,
      100.21829378636826,
      106.37149757543546,
      112.95703851939102,
      118.60070652461219
    ),
    tolerance = 1e-12
  )
})

test_that("volume and returns statistics match Python", {
  candles <- SyntheticCandles$new()

  expect_equal(candles$volume_total(), 180200)
  expect_equal(
    candles$volume_skewness(),
    -0.0029153969568027718,
    tolerance = 1e-10
  )
  expect_equal(
    candles$returns_standard_deviation(),
    0.013402712850284774,
    tolerance = 1e-12
  )
  returns <- candles$returns()
  expect_equal(
    names(returns),
    c(
      "exchange",
      "segment",
      "datetime",
      "interval",
      "returns"
    )
  )
  expect_true(is.na(returns$returns[[1]]))
  expect_equal(returns$returns[[2]], 0.016247411697146497, tolerance = 1e-12)
})

test_that("price_histogram counts the same bars as matplotlib", {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off())

  histogram <- SyntheticCandles$new()$price_histogram(bins = 5)

  expect_equal(
    histogram$counts,
    c(
      17,
      25,
      26,
      25,
      27
    )
  )
})

test_that("every statistic gives NULL when there are no candles", {
  candles <- EmptyCandles$new()

  expect_null(candles$price_high())
  expect_null(candles$volume_summary())
  expect_null(candles$returns_kurtosis())
})
