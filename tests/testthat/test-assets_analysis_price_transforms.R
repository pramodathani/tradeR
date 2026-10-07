test_that("price transforms add the columns Python adds, with the same values", {
  candles <- SyntheticCandles$new()

  average <- candles$average_price()
  typical <- candles$typical_price()

  expect_equal(names(average)[[ncol(average)]], "avg_price")
  expect_equal(average$avg_price[[10]], 109.18659314403993, tolerance = 1e-12)
  expect_equal(typical$typ_price[[10]], 108.8844661026343, tolerance = 1e-12)
  expect_equal(
    candles$median_price()$med_price,
    (average$high + average$low) / 2,
    tolerance = 1e-12
  )
  expect_equal(
    candles$weighted_close()$wght_close,
    (average$high + average$low + 2 * average$close) / 4,
    tolerance = 1e-12
  )
})

test_that("price transforms give NULL when there are no candles", {
  expect_null(EmptyCandles$new()$average_price())
})
