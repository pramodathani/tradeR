test_that("a square-off names positions the positions' way and lists chosen instruments", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- SquareOffOrder$new(
    share,
    at_time = "15:10",
    only_instruments = list(
      share
    )
  )

  synthetic <- order$synthetic
  text <- as.character(jsonlite::toJSON(synthetic, auto_unbox = TRUE))

  expect_equal(synthetic$product, "intraday")
  expect_true(synthetic$closes_position)
  expect_match(text, "\"instrument_ids\":[\"infy-id\"]", fixed = TRUE)
  expect_equal(order$transaction_type, "sell")
  expect_equal(order$order_type, "market")
})
