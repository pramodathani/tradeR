test_that("the trigger level is kept apart from the template's trigger price", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- CandleCloseStopOrder$new(
    share,
    transaction_type = "sell",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    trigger_price = 990,
    price = 989,
    bar_minutes = 15
  )

  expect_equal(order$trigger_level, 990)
  expect_equal(order$synthetic$trigger_price, 990)
  expect_equal(order$synthetic$bar_minutes, 15)
})
