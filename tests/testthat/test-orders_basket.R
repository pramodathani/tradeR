test_that("a basket anchors on its first candidate and sends every candidate", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  first_share <- TradeableInstrument$new(
    details = details$equity(),
    unified_broker_interface = fake
  )
  second_share <- TradeableInstrument$new(
    details = details$equity(symbol = "TCS", instrument_id = "tcs-id"),
    unified_broker_interface = fake
  )
  order <- BasketOrder$new(
    candidates = list(
      OrderCandidate$new(second_share, price = 21),
      OrderCandidate$new(first_share, transaction_type = "sell")
    ),
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    hedge_benefit = TRUE
  )

  order$place()

  body <- fake$last_request()$body
  expect_equal(body$instrument_id, "tcs-id")
  expect_length(body$synthetic$candidates, 2)
  expect_equal(body$synthetic$candidates[[2]]$transaction_type, "sell")
  expect_true(body$synthetic$hedge_benefit)
})

test_that("a basket without candidates signals ValueError", {
  expect_error(
    BasketOrder$new(
      candidates = list(),
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1
    ),
    class = "ValueError"
  )
})
