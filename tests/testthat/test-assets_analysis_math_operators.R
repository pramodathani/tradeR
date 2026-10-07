OperatorFixtureCandles <- R6::R6Class(
  "OperatorFixtureCandles",
  inherit = MathOperators,
  public = list(
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
      if (self$empty) {
        return(NULL)
      }
      frame <- utils::read.csv(
        testthat::test_path("fixtures", "performance_candles.csv"),
        stringsAsFactors = FALSE
      )
      frame$datetime <- TimeConverter$new()$moments(frame$datetime)
      frame
    }
  )
)

test_that("the arithmetic methods match the Python values", {
  candles <- OperatorFixtureCandles$new()
  expect_equal(candles$add()$sum[200], 2096.6000000000004)
  expect_equal(candles$subtract()$difference[20], 6.600000000000023)
  expect_equal(candles$multiply()$product[400], 1102506.0327)
  expect_equal(candles$divide()$quotient[200], 1.022827481740909)
  closing <- candles$subtract(first_column = "close", second_column = "open")
  expect_equal(closing$difference[400], 3.990000000000009)
})

test_that("the rolling extremes match the Python values", {
  candles <- OperatorFixtureCandles$new()
  highest <- candles$maximum()
  expect_equal(sum(is.na(highest$max)), 9)
  expect_equal(highest$max[200], 1112.32)
  lowest <- candles$minimum(column = "high", window = 20)
  expect_equal(sum(is.na(lowest$min)), 19)
  expect_equal(lowest$min[400], 1003.29)
  both <- candles$minimum_maximum()
  expect_equal(both$min[20], 926.03)
  expect_equal(both$max[20], 954.93)
})

test_that("the index methods give positions counted from 0, with 0 before the first window", {
  candles <- OperatorFixtureCandles$new()
  highest <- candles$maximum_index()
  expect_type(highest$maxindex, "integer")
  expect_equal(highest$maxindex[1:9], rep(0L, 9))
  expect_equal(highest$maxindex[20], 15L)
  expect_equal(highest$maxindex[400], 396L)
  lowest <- candles$minimum_index(column = "high", window = 20)
  expect_equal(lowest$minindex[20], 9L)
  expect_equal(lowest$minindex[400], 385L)
  both <- candles$minimum_maximum_index(column = "high", window = 20)
  expect_equal(both$minindex[200], 199L)
  expect_equal(both$maxindex[200], 189L)
})

test_that("the index scan resolves ties and missing values as TA-Lib does", {
  private_methods <- OperatorFixtureCandles$new()$.__enclos_env__$private
  values <- c(
    1,
    NA,
    3,
    2,
    5,
    4
  )
  expect_equal(
    private_methods$highest_positions(values, 2, "TA_MAXINDEX"),
    c(
      0L,
      0L,
      1L,
      2L,
      4L,
      4L
    )
  )
  expect_equal(
    private_methods$rolling_maximum(values, 2),
    c(
      NA,
      1,
      NA,
      3,
      5,
      5
    )
  )
  leading <- c(
    NA,
    1,
    3,
    2,
    5,
    4
  )
  expect_equal(
    private_methods$highest_positions(leading, 2, "TA_MAXINDEX"),
    c(
      0L,
      0L,
      2L,
      2L,
      4L,
      4L
    )
  )
  expect_equal(
    private_methods$lowest_positions(leading, 2, "TA_MININDEX"),
    c(
      0L,
      0L,
      1L,
      3L,
      3L,
      5L
    )
  )
})

test_that("the rolling methods reject a window below 2 as TA-Lib does", {
  expect_error(
    OperatorFixtureCandles$new()$maximum_index(window = 1),
    "TA_MAXINDEX function failed with error code 2"
  )
  expect_error(
    OperatorFixtureCandles$new()$minimum_maximum(window = 1),
    "TA_MINMAX function failed with error code 2"
  )
})

test_that("the operators give NULL when there are no candles", {
  empty <- OperatorFixtureCandles$new(empty = TRUE)
  expect_null(empty$add())
  expect_null(empty$maximum())
  expect_null(empty$minimum_maximum_index())
})
