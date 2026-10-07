StatisticFixtureCandles <- R6::R6Class(
  "StatisticFixtureCandles",
  inherit = StatisticFunctions,
  public = list(
    file_name = NULL,
    drop_rows = NULL,
    empty = FALSE,

    initialize = function(
      file_name = "performance_candles.csv",
      drop_rows = NULL,
      empty = FALSE
    ) {
      self$file_name <- file_name
      self$drop_rows <- drop_rows
      self$empty <- empty
    },

    prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      if (self$empty) {
        return(NULL)
      }
      frame <- utils::read.csv(
        testthat::test_path("fixtures", self$file_name),
        stringsAsFactors = FALSE
      )
      frame$datetime <- TimeConverter$new()$moments(frame$datetime)
      if (!is.null(self$drop_rows)) {
        frame <- frame[-self$drop_rows, ]
        rownames(frame) <- NULL
      }
      frame
    }
  )
)

statistic_benchmark <- function(drop_rows = NULL) {
  StatisticFixtureCandles$new(
    file_name = "performance_benchmark_candles.csv",
    drop_rows = drop_rows
  )
}

test_that("beta matches the Python values and keeps the benchmark column", {
  frame <- StatisticFixtureCandles$new()$beta(benchmark = statistic_benchmark())
  expect_equal(nrow(frame), 400)
  expect_equal(
    tail(names(frame), 2),
    c(
      "benchmark_close",
      "beta_14"
    )
  )
  expect_equal(sum(is.na(frame$beta_14)), 14)
  expect_equal(frame$beta_14[20], -0.1153006738689225, tolerance = 1e-9)
  expect_equal(frame$beta_14[200], -0.351876465877102, tolerance = 1e-9)
  expect_equal(frame$beta_14[400], 0.2590465763120322, tolerance = 1e-9)
})

test_that("beta takes the window and column", {
  frame <- StatisticFixtureCandles$new()$beta(
    benchmark = statistic_benchmark(),
    window = 30,
    column = "open"
  )
  expect_true("benchmark_open" %in% names(frame))
  expect_equal(sum(is.na(frame$beta_30)), 30)
  expect_equal(frame$beta_30[200], -0.2976306403482754, tolerance = 1e-9)
})

test_that("beta leaves out candles the benchmark lacks", {
  frame <- StatisticFixtureCandles$new()$beta(
    benchmark = statistic_benchmark(drop_rows = 51:60)
  )
  expect_equal(nrow(frame), 390)
  expect_equal(frame$beta_14[200], 0.0387423297138098, tolerance = 1e-9)
})

test_that("correlation_coefficient matches the Python values", {
  frame <- StatisticFixtureCandles$new()$correlation_coefficient(
    benchmark = statistic_benchmark()
  )
  expect_equal(sum(is.na(frame$corr_14)), 14)
  expect_equal(frame$corr_14[20], -0.102651443225913, tolerance = 1e-12)
  expect_equal(frame$corr_14[200], -0.3120244579184683, tolerance = 1e-12)
  expect_equal(frame$corr_14[400], 0.2726252658674605, tolerance = 1e-12)
  gapped <- StatisticFixtureCandles$new()$correlation_coefficient(
    benchmark = statistic_benchmark(drop_rows = 51:60)
  )
  expect_equal(gapped$corr_14[200], 0.0606619485340915, tolerance = 1e-12)
})

test_that("a missing return inside the data empties every later correlation, as in Python", {
  candles <- StatisticFixtureCandles$new()
  values <- candles$prices()$close
  values[[101]] <- NA
  correlations <- candles$.__enclos_env__$private$rolling_correlation(
    first_values = values,
    second_values = rev(values),
    window = 14
  )
  expect_false(is.na(correlations[[100]]))
  expect_true(all(is.na(correlations[101:400])))
})

test_that("the regression methods match the Python values", {
  candles <- StatisticFixtureCandles$new()
  line <- candles$linear_regression()
  slope <- candles$linear_regression_slope()
  intercept <- candles$linear_regression_intercept()
  angle <- candles$linear_regression_angle()
  expect_equal(sum(is.na(line$lin_regr_14)), 13)
  expect_equal(line$lin_regr_14[20], 947.5839999999996, tolerance = 1e-12)
  expect_equal(line$lin_regr_14[400], 1081.4162857142846, tolerance = 1e-12)
  expect_equal(
    slope$lin_regr_slope_14[200],
    -7.932879120879258,
    tolerance = 1e-12
  )
  expect_equal(
    intercept$lin_regr_int_14[200],
    1146.6980000000008,
    tolerance = 1e-12
  )
  expect_equal(
    angle$lin_regr_angle_14[400],
    79.07928702944689,
    tolerance = 1e-12
  )
  wide <- candles$linear_regression(window = 30, column = "high")
  expect_equal(sum(is.na(wide$lin_regr_30)), 29)
  expect_equal(wide$lin_regr_30[200], 1097.8293118279576, tolerance = 1e-12)
})

test_that("the regression methods skip missing values at the start", {
  candles <- StatisticFixtureCandles$new()
  values <- candles$prices()$close
  values[1:3] <- NA
  lines <- candles$.__enclos_env__$private$regression_lines(
    values = values,
    window = 14,
    function_name = "TA_LINEARREG"
  )
  expect_equal(sum(is.na(lines$end_value)), 16)
})

test_that("the regression methods reject a window below 2 as TA-Lib does", {
  expect_error(
    StatisticFixtureCandles$new()$linear_regression(window = 1),
    "TA_LINEARREG function failed with error code 2"
  )
})

test_that("standard_deviation and variance match the Python values", {
  candles <- StatisticFixtureCandles$new()
  deviation <- candles$standard_deviation()
  variance <- candles$variance()
  expect_equal(sum(is.na(deviation$std_dev_14)), 13)
  expect_equal(deviation$std_dev_14[200], 34.785899999502405, tolerance = 1e-9)
  expect_equal(variance$var_14[200], 1210.0588387753814, tolerance = 1e-9)
  doubled <- candles$standard_deviation(window = 20, standard_deviations = 2)
  expect_equal(doubled$std_dev_20[400], 57.84948348085389, tolerance = 1e-9)
  ignored <- candles$variance(window = 20, standard_deviations = 2)
  expect_equal(ignored$var_20[400], 836.6406847503968, tolerance = 1e-9)
})

test_that("every method gives NULL when there are no candles", {
  empty <- StatisticFixtureCandles$new(empty = TRUE)
  expect_null(empty$linear_regression())
  expect_null(empty$standard_deviation())
  expect_null(empty$beta(benchmark = statistic_benchmark()))
  expect_null(
    StatisticFixtureCandles$new()$correlation_coefficient(
      benchmark = StatisticFixtureCandles$new(empty = TRUE)
    )
  )
})

test_that("beta gives NULL when no candle matches the benchmark", {
  expect_null(
    StatisticFixtureCandles$new()$beta(
      benchmark = statistic_benchmark(drop_rows = 1:400)
    )
  )
})
