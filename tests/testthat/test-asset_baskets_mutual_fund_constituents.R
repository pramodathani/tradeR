test_that("the estimated move scales the holdings' move by the priced share", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  infosys <- TradeableInstrument$new(
    details = details$equity("INFY", "infy-id"),
    unified_broker_interface = fake
  )
  scheme <- TradeableInstrument$new(
    details = details$equity("SCHEME", "scheme-id"),
    unified_broker_interface = fake
  )
  holdings <- MutualFundConstituents$new(
    name = "scheme",
    members = list(
      BasketMember$new(infosys, weight = 9)
    ),
    fund = scheme,
    unmapped_weight = 0.05,
    unified_broker_interface = fake
  )
  fake$answers[["POST /api/instruments/ohlc"]] <- list(
    results = list(
      list(request_index = 0, status = 200, data = list(change_percent = 2))
    )
  )

  expect_identical(holdings$fund, scheme)
  expect_equal(holdings$estimated_day_change_percent, 1.9)
  expect_equal(holdings$estimated_net_asset_value(100), 101.9)
  document <- holdings$document("2026-10-01")
  expect_equal(document$linked_instrument_id, "scheme-id")
  expect_equal(holdings$KIND, "mutual_fund_constituents")
})

test_that("the estimate is NULL when a holding has no quote", {
  fake <- FakeClient$new()
  infosys <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  holdings <- MutualFundConstituents$new(
    name = "scheme",
    members = list(
      BasketMember$new(infosys)
    ),
    unified_broker_interface = fake
  )
  fake$answers[["POST /api/instruments/ohlc"]] <- list(
    results = list(
      list(request_index = 0, status = 404, error = "no quote")
    )
  )

  expect_null(holdings$estimated_net_asset_value(100))
})
