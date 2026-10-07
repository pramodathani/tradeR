TransformFixtureCandles <- R6::R6Class(
  "TransformFixtureCandles",
  inherit = MathTransforms,
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
      frame$centred <- (frame$close - 1060) / 100
      frame
    }
  )
)

test_that("the transforms of the close match the Python values", {
  candles <- TransformFixtureCandles$new()
  expect_equal(candles$arc_tangent()$atan[20], 1.569747845380744)
  expect_equal(candles$ceiling()$ceil[200], 1049)
  expect_equal(candles$cosine()$cos[400], -0.7689885151865166)
  expect_equal(candles$floor()$floor[400], 1051)
  expect_equal(candles$natural_logarithm()$ln[20], 6.860412067471616)
  expect_equal(candles$logarithm_base_10()$log10[200], 3.020419295211332)
  expect_equal(candles$sine()$sin[20], -0.959202194404984)
  expect_equal(candles$square_root()$sqrt[400], 32.43054116107223)
  expect_equal(candles$tangent()$tan[200], -2.24621203679184)
  expect_equal(candles$hyperbolic_tangent()$tanh[400], 1)
})

test_that("functions defined only between -1 and 1 give NaN for prices", {
  candles <- TransformFixtureCandles$new()
  expect_true(all(is.nan(candles$arc_cosine()$acos)))
  expect_true(all(is.nan(candles$arc_sine()$asin)))
})

test_that("large prices overflow to infinity, as in Python", {
  candles <- TransformFixtureCandles$new()
  expect_true(all(candles$exponential()$exp == Inf))
  expect_true(all(candles$hyperbolic_cosine()$cosh == Inf))
  expect_true(all(candles$hyperbolic_sine()$sinh == Inf))
})

test_that("the transforms of a small column match the Python values", {
  candles <- TransformFixtureCandles$new()
  acos_frame <- candles$arc_cosine(column = "centred")
  expect_equal(sum(is.na(acos_frame$acos)), 39)
  expect_equal(acos_frame$acos[200], 1.689676138701607)
  expect_equal(
    candles$arc_sine(column = "centred")$asin[400],
    -0.082694216216866
  )
  expect_equal(
    candles$hyperbolic_cosine(column = "centred")$cosh[20],
    1.6194659562125424
  )
  expect_equal(
    candles$exponential(column = "centred")$exp[200],
    0.8881629949163506
  )
  expect_equal(
    candles$hyperbolic_sine(column = "centred")$sinh[20],
    -1.2738406428322988
  )
  expect_equal(candles$floor(column = "centred")$floor[20], -2)
})

test_that("negative values have no logarithm or square root", {
  candles <- TransformFixtureCandles$new()
  expect_equal(
    sum(is.nan(candles$natural_logarithm(column = "centred")$ln)),
    184
  )
  expect_equal(
    sum(is.nan(candles$logarithm_base_10(column = "centred")$log10)),
    184
  )
  expect_equal(sum(is.nan(candles$square_root(column = "centred")$sqrt)), 184)
})

test_that("the transforms give NULL when there are no candles", {
  empty <- TransformFixtureCandles$new(empty = TRUE)
  expect_null(empty$arc_cosine())
  expect_null(empty$natural_logarithm())
  expect_null(empty$hyperbolic_tangent())
})
