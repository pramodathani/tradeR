test_that("the single measures match values captured from Python", {
  own <- PerformanceFixtureCandles$new()
  benchmark <- PerformanceFixtureCandles$new("performance_benchmark_candles.csv")
  tolerance <- 1e-12
  expect_equal(own$cumulative_return(), 0.06724710036835213, tolerance = tolerance)
  expect_equal(own$annualised_return(), 0.04196125112658411, tolerance = tolerance)
  expect_equal(own$annualised_volatility(), 0.23501708319979844, tolerance = tolerance)
  expect_equal(own$sharpe_ratio(risk_free_rate = 0.065), 0.015528364093035738, tolerance = tolerance)
  expect_equal(own$sortino_ratio(risk_free_rate = 0.065), 0.02198194936506132, tolerance = tolerance)
  expect_equal(own$maximum_drawdown(), -0.17146870453671337, tolerance = tolerance)
  expect_equal(own$calmar_ratio(), 0.24471667433400207, tolerance = tolerance)
  expect_equal(own$benchmark_beta(benchmark), -0.06161100071842387, tolerance = tolerance)
  expect_equal(own$alpha(benchmark, risk_free_rate = 0.065), 0.03218995498414519, tolerance = tolerance)
  expect_equal(own$tracking_error(benchmark), 0.343989926014443, tolerance = tolerance)
  expect_equal(own$information_ratio(benchmark), -1.3360508702081566, tolerance = tolerance)
  expect_equal(own$up_capture_ratio(benchmark), -0.021602189981344246, tolerance = tolerance)
  expect_equal(own$down_capture_ratio(benchmark), -0.08578690990491133, tolerance = tolerance)
})

test_that("minute intervals annualise by 252 sessions of 375 minutes", {
  own <- PerformanceFixtureCandles$new()
  expect_equal(own$annualised_return(interval = "5minute"), 20.820647871092355, tolerance = 1e-12)
  expect_equal(own$sharpe_ratio(interval = "5minute"), 2.529694873660921, tolerance = 1e-12)
})

test_that("value at risk and expected shortfall match Python", {
  own <- PerformanceFixtureCandles$new()
  tolerance <- 1e-12
  expect_equal(own$value_at_risk(confidence = 0.9), 0.018828755374100184, tolerance = tolerance)
  expect_equal(own$value_at_risk(confidence = 0.99), 0.033335262771566745, tolerance = tolerance)
  expect_equal(own$value_at_risk(confidence = 0.95, method = "parametric"), 0.024079120893445143, tolerance = tolerance)
  expect_equal(own$expected_shortfall(confidence = 0.95), 0.030820360183145573, tolerance = tolerance)
})

test_that("drawdowns returns one row per candle with a running peak", {
  frame <- PerformanceFixtureCandles$new()$drawdowns()
  expect_equal(
    names(frame),
    c(
      "datetime",
      "close",
      "running_peak",
      "drawdown"
    )
  )
  expect_equal(nrow(frame), 400)
  expect_equal(frame$drawdown[[2]], -0.016327234720488693, tolerance = 1e-12)
  expect_equal(min(frame$drawdown), -0.17146870453671337, tolerance = 1e-12)
})

test_that("performance_summary fetches once per object and keeps every name", {
  own <- PerformanceFixtureCandles$new()
  benchmark <- PerformanceFixtureCandles$new("performance_benchmark_candles.csv")
  summary <- own$performance_summary(benchmark = benchmark, risk_free_rate = 0.065)
  expect_equal(
    names(summary),
    c(
      "cumulative_return",
      "annualised_return",
      "annualised_volatility",
      "sharpe_ratio",
      "sortino_ratio",
      "maximum_drawdown",
      "calmar_ratio",
      "value_at_risk",
      "expected_shortfall",
      "benchmark_beta",
      "alpha",
      "tracking_error",
      "information_ratio",
      "up_capture_ratio",
      "down_capture_ratio"
    )
  )
  expect_equal(summary$sharpe_ratio, 0.015528364093035738, tolerance = 1e-12)
  expect_equal(own$calls, 2)
  expect_equal(benchmark$calls, 1)
  without_benchmark <- own$performance_summary()
  expect_equal(length(without_benchmark), 9)
})

test_that("bad arguments signal ValueError before any fetch", {
  own <- PerformanceFixtureCandles$new()
  expect_error(own$sharpe_ratio(interval = "week"), class = "ValueError")
  expect_error(own$value_at_risk(confidence = 1), class = "ValueError")
  expect_error(own$value_at_risk(method = "monte_carlo"), class = "ValueError")
  expect_equal(own$calls, 0)
})

test_that("no candles gives NULL", {
  empty <- R6::R6Class(
    "EmptyPerformanceCandles",
    inherit = PerformanceMeasures,
    public = list(
      prices = function(
        interval = "day",
        from_date = NULL,
        to_date = NULL,
        days = NULL,
        adjusted = TRUE
      ) {
        NULL
      }
    )
  )$new()
  expect_null(empty$sharpe_ratio())
  expect_null(empty$drawdowns())
  expect_null(empty$performance_summary())
})
