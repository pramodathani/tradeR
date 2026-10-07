test_that("volatility indicators match the values Python gave on the same candles", {
  candles <- SyntheticCandles$new()

  average_true_range <- candles$average_true_range()
  normalized <- candles$normalized_average_true_range(window = 5)
  true_range <- candles$true_range()

  expect_true(all(is.na(average_true_range$atr_14[1:14])))
  expect_equal(
    average_true_range$atr_14[[120]],
    3.7821725709861687,
    tolerance = 1e-12
  )
  expect_equal(normalized$natr5[[120]], 3.5206395831485513, tolerance = 1e-12)
  expect_true(is.na(true_range$tr[[1]]))
  expect_equal(true_range$tr[[2]], 4.095144628587178, tolerance = 1e-12)
})

test_that("volatility indicators give NULL when there are no candles", {
  expect_null(EmptyCandles$new()$true_range())
})
