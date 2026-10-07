test_that("the follow-on order carries only the fields that are set", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- OneTriggersOtherOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    then_transaction_type = "sell",
    then_order_type = "limit",
    price = 13,
    then_price = 13.5
  )

  expect_equal(
    order$synthetic$then,
    list(
      transaction_type = "sell",
      order_type = "limit",
      price = 13.5
    )
  )
})
