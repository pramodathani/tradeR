test_that("an order knows its direction and can be cancelled", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 10000, 0, 1, FALSE, FALSE, FALSE)
  order <- broker$new_order(-4, limit = 120)
  expect_true(order$is_short)
  expect_false(order$is_long)
  expect_false(order$is_contingent)
  expect_equal(order$format(), "<Order size=-4, limit=120, contingent=FALSE>")
  order$cancel()
  expect_equal(length(broker$orders), 0)
})

test_that("a zero size is refused", {
  expect_error(BacktestOrder$new(NULL, 0), class = "ValueError")
})
