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

test_that("moving_average_convergence_divergence matches the Python values", {
  frame <- FormulaCandles$new()$moving_average_convergence_divergence()
  expect_true(is.na(frame$macd_12_26_9[33]))
  expect_equal(frame$macd_12_26_9[40], 1.3136923571337462, tolerance = 1e-9)
  expect_equal(
    frame$macd_12_26_9_signal[60],
    0.8778397240142566,
    tolerance = 1e-9
  )
  expect_equal(
    frame$macd_12_26_9_hist[60],
    1.5025396888490776,
    tolerance = 1e-9
  )
})

test_that("relative_strength_index matches the Python values", {
  frame <- FormulaCandles$new()$relative_strength_index()
  expect_true(is.na(frame$rsi_14[14]))
  expect_equal(frame$rsi_14[40], 66.45631255751107, tolerance = 1e-9)
  expect_equal(frame$rsi_14[60], 69.6317886601153, tolerance = 1e-9)
})

test_that("average_directional_movement_index matches the Python values", {
  frame <- FormulaCandles$new()$average_directional_movement_index()
  expect_true(is.na(frame$adx_14[27]))
  expect_equal(frame$adx_14[40], 21.33112720955352, tolerance = 1e-9)
})

test_that("money_flow_index matches the Python values", {
  frame <- FormulaCandles$new()$money_flow_index()
  expect_equal(frame$mfi_14[60], 67.46780954419216, tolerance = 1e-9)
})

test_that("rate_of_change and rate_of_change_percent match the Python values", {
  analysis <- FormulaCandles$new()
  percentage <- analysis$rate_of_change()
  fraction <- analysis$rate_of_change_percent()
  expect_true(all(is.na(percentage$roc_14[seq(1, 14)])))
  expect_equal(percentage$roc_14[40], 2.555422803491547, tolerance = 1e-9)
  expect_equal(percentage$roc_14[60], 7.327860712833267, tolerance = 1e-9)
  expect_true(is.na(fraction$rocp_14[14]))
  expect_equal(fraction$rocp_14[40], 0.025554228034915496, tolerance = 1e-9)
})

test_that("rate_of_change refuses a window below 1", {
  expect_error(
    FormulaCandles$new()$rate_of_change(window = 0),
    "TA_BAD_PARAM"
  )
})

test_that("stochastic_oscillator passes the moving average types", {
  frame <- FormulaCandles$new()$stochastic_oscillator(
    slow_k_moving_average_type = 1,
    slow_d_moving_average_type = 1
  )
  expect_true(is.na(frame$slowk_3[8]))
  expect_equal(frame$slowk_3[40], 88.95985700340303, tolerance = 1e-9)
  expect_equal(frame$slowd_3[60], 87.4709138372965, tolerance = 1e-9)
})

test_that("a method returns NULL when there are no candles", {
  expect_null(FormulaCandles$new(empty = TRUE)$aroon())
  expect_null(FormulaCandles$new(empty = TRUE)$rate_of_change())
})
