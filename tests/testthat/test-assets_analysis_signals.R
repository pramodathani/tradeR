SignalFixtureCandles <- R6::R6Class(
  "SignalFixtureCandles",
  inherit = Signals,
  public = list(
    prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      frame <- utils::read.csv(
        testthat::test_path("fixtures", "performance_candles.csv"),
        stringsAsFactors = FALSE
      )
      frame$datetime <- TimeConverter$new()$moments(frame$datetime)
      frame
    }
  )
)

test_that("is_cross_over and is_cross_under count as Python did", {
  candles <- SignalFixtureCandles$new()
  frame <- candles$prices()
  over <- candles$is_cross_over(frame, "close", "open")
  under <- candles$is_cross_under(frame, "close", "open")
  expect_type(over$cross_over, "logical")
  expect_equal(sum(over$cross_over), 105)
  expect_equal(sum(under$cross_under), 105)
  expect_true(over$cross_over[20])
  expect_false(under$cross_under[20])
})

test_that("missing values are never marked", {
  candles <- SignalFixtureCandles$new()
  frame <- candles$linear_regression()
  over <- candles$is_cross_over(frame, "close", "lin_regr_14")
  under <- candles$is_cross_under(frame, "close", "lin_regr_14")
  expect_false(anyNA(over$cross_over))
  expect_equal(sum(over$cross_over), 50)
  expect_equal(sum(under$cross_under), 51)
  expect_false(any(over$cross_over[1:14]))
})

test_that("a crossing compares both columns on the previous row", {
  frame <- data.frame(
    first = c(
      1,
      3,
      2,
      2,
      4
    ),
    second = c(
      2,
      2,
      2,
      3,
      3
    )
  )
  candles <- SignalFixtureCandles$new()
  expect_equal(
    candles$is_cross_over(frame, "first", "second")$cross_over,
    c(
      FALSE,
      TRUE,
      FALSE,
      FALSE,
      TRUE
    )
  )
  expect_equal(
    candles$is_cross_under(frame, "first", "second")$cross_under,
    c(
      FALSE,
      FALSE,
      FALSE,
      TRUE,
      FALSE
    )
  )
})

test_that("the caller's frame is not changed and row names are fresh", {
  frame <- data.frame(
    first = c(
      1,
      3
    ),
    second = c(
      2,
      2
    ),
    row.names = c(
      "a",
      "b"
    )
  )
  result <- SignalFixtureCandles$new()$is_cross_over(frame, "first", "second")
  expect_equal(
    names(frame),
    c(
      "first",
      "second"
    )
  )
  expect_equal(
    rownames(result),
    c(
      "1",
      "2"
    )
  )
})

test_that("a missing column is reported", {
  frame <- data.frame(first = 1)
  expect_error(
    SignalFixtureCandles$new()$is_cross_over(frame, "first", "second"),
    "data has no column named 'second'",
    class = "KeyError"
  )
})

test_that("an empty frame gives an empty column", {
  frame <- data.frame(first = numeric(0), second = numeric(0))
  result <- SignalFixtureCandles$new()$is_cross_under(frame, "first", "second")
  expect_equal(result$cross_under, logical(0))
})
