PatternFixtureCandles <- R6::R6Class(
  "PatternFixtureCandles",
  inherit = CandlestickPatterns,
  public = list(
    file_name = NULL,
    empty = FALSE,

    initialize = function(
      file_name = "candlestick_candles.csv",
      empty = FALSE
    ) {
      self$file_name <- file_name
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
      frame
    }
  )
)

pattern_method_names <- function() {
  names <- ls(CandlestickPatterns$public_methods)
  sort(names[startsWith(names, "candle_")])
}

test_that("there are 61 pattern methods", {
  expect_length(pattern_method_names(), 61)
})

test_that("every pattern gives the signals Python's talib gave on the same candles", {
  expected <- utils::read.csv(
    testthat::test_path("fixtures", "candlestick_python_signals.csv"),
    stringsAsFactors = FALSE
  )
  candles <- PatternFixtureCandles$new()
  for (method in pattern_method_names()) {
    frame <- candles[[method]]()
    column <- names(frame)[[ncol(frame)]]
    signals <- frame[[column]]
    expected_rows <- expected[expected$method == method, ]
    wanted <- rep(0L, nrow(frame))
    wanted[expected_rows$row] <- as.integer(expected_rows$signal)
    expect_identical(signals, wanted, label = method)
  }
})

test_that("the candles TA-Lib cannot judge get 0, not NA", {
  frame <- PatternFixtureCandles$new()$candle_two_crows()
  expect_false(anyNA(frame$candle_two_crows))
  expect_equal(frame$candle_two_crows[1:12], rep(0L, 12))
})

test_that("the column labels keep Python's names", {
  candles <- PatternFixtureCandles$new()
  expect_true("candle_hangingman" %in% names(candles$candle_hanging_man()))
  expect_true(
    "candle_evening_dojistar" %in% names(candles$candle_evening_doji_star())
  )
  expect_true(
    "candle_up_side_gap_three_methods" %in%
      names(candles$candle_up_side_down_side_gap_three_methods())
  )
})

test_that("the hikkake reports confirmed matches as 200 and -200", {
  frame <- PatternFixtureCandles$new()$candle_hikkake()
  expect_true(all(
    c(
      -200L,
      200L
    ) %in% frame$candle_hikkake
  ))
})

test_that("the talib.normalize option is restored afterwards", {
  previous <- options(talib.normalize = TRUE)
  on.exit(options(previous), add = TRUE)
  PatternFixtureCandles$new()$candle_doji()
  expect_true(getOption("talib.normalize"))
})

test_that("candles with missing prices at the start are skipped", {
  candles <- PatternFixtureCandles$new()
  prices <- candles$prices()
  prices$close[1:3] <- NA
  signals <- candles$.__enclos_env__$private$pattern_signals(
    prices = prices,
    recogniser = talib::CDLDOJI
  )
  expect_false(anyNA(signals))
  expect_equal(signals[1:3], rep(0L, 3))
})

test_that("the patterns give NULL when there are no candles", {
  empty <- PatternFixtureCandles$new(empty = TRUE)
  expect_null(empty$candle_doji())
  expect_null(empty$candle_hikkake())
})
