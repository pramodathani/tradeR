FormulaCandles <- R6::R6Class(
  "FormulaCandles",
  inherit = MomentumIndicators,
  public = list(
    requested = NULL,
    empty = FALSE,

    initialize = function(empty = FALSE) {
      self$empty <- empty
    },

    prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      self$requested <- list(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (self$empty) {
        return(NULL)
      }
      index <- seq(1, 60)
      close <- 100 + 10 * sin(index / 3) + index / 5
      data.frame(
        datetime = as.POSIXct("2026-01-01", tz = "Asia/Kolkata") +
          (index - 1) * 86400,
        open = 100 + 10 * sin((index - 1) / 3) + (index - 1) / 5,
        high = close + 1 + (index %% 3) / 2,
        low = close - 1 - (index %% 4) / 3,
        close = close,
        volume = 1000 + 37 * index
      )
    }
  )
)

test_that("simple_moving_average matches the Python values", {
  frame <- FormulaCandles$new()$simple_moving_average()
  expect_true(all(is.na(frame$sma_10[seq(1, 9)])))
  expect_equal(frame$sma_10[40], 103.08509515418454, tolerance = 1e-9)
  expect_equal(frame$sma_10[60], 109.04505195832132, tolerance = 1e-9)
})

test_that("bollinger_bands adds three bands that match the Python values", {
  frame <- FormulaCandles$new()$bollinger_bands(window = 20)
  expect_true(is.na(frame$bb_upper_20[19]))
  expect_equal(frame$bb_upper_20[40], 119.5586275878212, tolerance = 1e-9)
  expect_equal(frame$bb_middle_20[40], 106.48808390805823, tolerance = 1e-9)
  expect_equal(frame$bb_lower_20[60], 96.75410987712756, tolerance = 1e-9)
})

test_that("parabolic_sar matches the Python values", {
  frame <- FormulaCandles$new()$parabolic_sar()
  expect_true(is.na(frame$psar[1]))
  expect_equal(frame$psar[40], 97.11181042715639, tolerance = 1e-9)
  expect_equal(frame$psar[60], 102.18655471359938, tolerance = 1e-9)
})

test_that("the price arguments reach prices and the candles are kept", {
  analysis <- FormulaCandles$new()
  frame <- analysis$mid_point(
    window = 5,
    interval = "5minute",
    days = 30,
    adjusted = FALSE
  )
  expect_equal(analysis$requested$interval, "5minute")
  expect_equal(analysis$requested$days, 30)
  expect_false(analysis$requested$adjusted)
  expect_equal(
    names(frame),
    c(
      "datetime",
      "open",
      "high",
      "low",
      "close",
      "volume",
      "mid_point_5"
    )
  )
})

test_that("a method returns NULL when there are no candles", {
  expect_null(FormulaCandles$new(empty = TRUE)$exponential_moving_average())
  expect_null(FormulaCandles$new(empty = TRUE)$middle_price())
})
