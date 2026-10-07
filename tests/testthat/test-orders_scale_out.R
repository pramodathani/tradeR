test_that("one target price is still sent as a JSON array", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- ScaleOutOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 3,
    target_prices = 1010,
    stop_price = 990,
    stop_limit_price = 988,
    price = 1000
  )

  text <- as.character(jsonlite::toJSON(order$synthetic, auto_unbox = TRUE))

  expect_match(text, "\"target_prices\":[1010]", fixed = TRUE)
  expect_match(text, "\"stop_price\":990", fixed = TRUE)
})
