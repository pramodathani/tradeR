test_that("cycle indicators match the values Python gave on the same candles", {
  candles <- SyntheticCandles$new()

  period <- candles$hilbert_transform_dominant_cycle_period()
  sine <- candles$hilbert_transform_sine_wave()
  phasor <- candles$hilbert_transform_phasor_components()
  trend_line <- candles$hilbert_transform_trend_line()

  expect_equal(period$ht_dcperiod[[120]], 36.95184600224483, tolerance = 1e-10)
  expect_equal(sine$sine[[120]], -0.9772415690020376, tolerance = 1e-10)
  expect_equal(sine$lead_sine[[120]], -0.8410123333118976, tolerance = 1e-10)
  expect_equal(phasor$inphase[[120]], -7.4976564255131635, tolerance = 1e-10)
  expect_equal(phasor$quadrature[[120]], -0.5102973054319812, tolerance = 1e-10)
  expect_equal(
    trend_line$ht_trendline[[120]],
    109.2472878285666,
    tolerance = 1e-10
  )
})

test_that("the trend mode is 0, not NA, during the warm-up, as in Python", {
  frame <- SyntheticCandles$new()$hilbert_transform_trend_mode()
  trend_mode <- frame$ht_trendmode

  expect_type(trend_mode, "integer")
  expect_false(anyNA(trend_mode))
  expect_equal(trend_mode[[1]], 0L)
  expect_equal(trend_mode[[120]], 1L)
  expect_equal(sum(trend_mode), 51L)
})

test_that("cycle indicators give NULL when there are no candles", {
  expect_null(EmptyCandles$new()$hilbert_transform_trend_line())
})
