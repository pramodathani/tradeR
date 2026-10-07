test_that("assigning sl and tp places contingent orders", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 10000, 0, 1, FALSE, FALSE, FALSE)
  broker$current_bar <- 1
  broker$new_order(5)
  broker$next_bar(2)
  trade <- broker$trades[[1]]
  trade$sl <- 95
  trade$tp <- 120
  expect_equal(trade$sl, 95)
  expect_equal(trade$tp, 120)
  expect_true(trade$sl_order$is_contingent)
  expect_equal(length(broker$orders), 2)
  trade$sl <- NULL
  expect_null(trade$sl)
  expect_equal(length(broker$orders), 1)
  expect_error(trade$close(portion = 2), class = "ValueError")
})

test_that("profit is measured at the latest close while open", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 10000, 0, 1, FALSE, FALSE, FALSE)
  broker$current_bar <- 1
  broker$new_order(5)
  broker$next_bar(2)
  trade <- broker$trades[[1]]
  expect_equal(trade$entry_price, 102)
  expect_equal(trade$pl, 5 * (104 - 102))
  expect_equal(trade$pl_pct, 104 / 102 - 1)
  expect_equal(trade$value, 5 * 104)
  expect_null(trade$exit_time)
})
