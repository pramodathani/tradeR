test_that("a candidate sends its instrument and only the fields it overrides", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )

  candidate <- OrderCandidate$new(share, price = 13)
  expect_equal(
    candidate$document(),
    list(
      instrument_id = "infy-id",
      price = 13
    )
  )

  candidate <- OrderCandidate$new(
    share,
    transaction_type = "sell",
    quantity = 2,
    tag = "pairleg"
  )
  expect_equal(
    names(candidate$document()),
    c(
      "instrument_id",
      "transaction_type",
      "quantity",
      "tag"
    )
  )
})
