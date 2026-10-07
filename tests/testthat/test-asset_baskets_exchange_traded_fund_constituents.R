test_that("premium_or_discount compares the fund with its indicative value", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  infosys <- TradeableInstrument$new(
    details = details$equity("INFY", "infy-id"),
    unified_broker_interface = fake
  )
  fund <- TradeableInstrument$new(
    details = details$equity("NIFTYBEES", "fund-id"),
    unified_broker_interface = fake
  )
  value_row <- NonTradeableInstrument$new(
    details = details$index("NIFTYBEES-NAV", "nav-id"),
    unified_broker_interface = fake
  )
  holdings <- ExchangeTradedFundConstituents$new(
    name = "NIFTYBEES",
    members = list(
      BasketMember$new(infosys, weight = 5)
    ),
    fund = fund,
    indicative_net_asset_value = value_row,
    unified_broker_interface = fake
  )
  fake$answers[["POST /api/instruments/ltp"]] <- list(
    results = list(
      list(request_index = 1, status = 200, data = list(last_price = 100)),
      list(request_index = 0, status = 200, data = list(last_price = 102))
    )
  )

  expect_equal(holdings$premium_or_discount, 2)
  expect_equal(
    fake$last_request()$body$instruments,
    list(
      list(instrument_id = "fund-id"),
      list(instrument_id = "nav-id")
    )
  )
  document <- holdings$document("2026-09-01")
  expect_equal(document$kind, "exchange_traded_fund_constituents")
  expect_equal(document$linked_instrument_id, "fund-id")
  expect_equal(document$indicative_net_asset_value_instrument_id, "nav-id")
})

test_that("an unlinked basket has no fund, premium or tracking difference", {
  fake <- FakeClient$new()
  infosys <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  holdings <- ExchangeTradedFundConstituents$new(
    name = "unlinked",
    members = list(
      BasketMember$new(infosys)
    ),
    unified_broker_interface = fake
  )

  expect_null(holdings$fund)
  expect_null(holdings$premium_or_discount)
  expect_null(holdings$tracking_difference(days = 365))
  expect_true(
    "indicative_net_asset_value_instrument_id" %in%
      names(holdings$document("2026-09-01"))
  )
  expect_length(fake$requests, 0)
})

test_that("tracking_difference is the fund's return minus the holdings'", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  infosys <- TradeableInstrument$new(
    details = details$equity("INFY", "infy-id"),
    unified_broker_interface = fake
  )
  fund <- TradeableInstrument$new(
    details = details$equity("NIFTYBEES", "fund-id"),
    unified_broker_interface = fake
  )
  columns <- list(
    "time",
    "open",
    "high",
    "low",
    "close",
    "volume",
    "oi"
  )
  fake$answers[["/api/instruments/prices"]] <- list(
    columns = columns,
    candles = list(
      list("2026-01-02T00:00:00+05:30", 100, 100, 100, 100, 1, NULL),
      list("2026-01-03T00:00:00+05:30", 110, 110, 110, 110, 1, NULL)
    )
  )
  fake$answers[["POST /api/instruments/prices"]] <- list(
    results = list(
      list(
        request_index = 0,
        status = 200,
        data = list(
          columns = columns,
          candles = list(
            list("2026-01-02T00:00:00+05:30", 50, 50, 50, 50, 1, NULL),
            list("2026-01-03T00:00:00+05:30", 52, 52, 52, 52, 1, NULL)
          )
        )
      )
    )
  )
  holdings <- ExchangeTradedFundConstituents$new(
    name = "NIFTYBEES",
    members = list(
      BasketMember$new(infosys, weight = 1)
    ),
    fund = fund,
    unified_broker_interface = fake
  )

  expect_equal(holdings$tracking_difference(days = 5), 0.1 - 0.04)
})
