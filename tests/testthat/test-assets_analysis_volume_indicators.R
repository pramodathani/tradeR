test_that("volume indicators match the values Python gave on the same candles", {
  candles <- SyntheticCandles$new()

  line <- candles$chaikin_accumulation_distribution_line()
  oscillator <- candles$chaikin_accumulation_distribution_oscillator()
  on_balance <- candles$on_balance_volume(column = "open")

  expect_equal(line$chaikin_ad[[120]], 415.6610552056062, tolerance = 1e-10)
  expect_equal(
    oscillator$chaikin_adosc3_10[[120]],
    203.92688815492522,
    tolerance = 1e-10
  )
  expect_equal(on_balance$obv[[120]], 680)
})

test_that("the oscillator column is named after both periods", {
  frame <- SyntheticCandles$new()$chaikin_accumulation_distribution_oscillator(
    fast_period = 5,
    slow_period = 20
  )

  expect_true("chaikin_adosc5_20" %in% names(frame))
})

test_that("volume indicators give NULL when there are no candles", {
  expect_null(EmptyCandles$new()$on_balance_volume())
})
