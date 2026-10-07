test_that("paper is sent only when it is TRUE", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- VirtualLimitOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13
  )

  expect_equal(order$synthetic, list(type = "virtual_limit"))

  order$paper <- TRUE
  expect_true(order$synthetic$paper)
})
