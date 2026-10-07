test_that("a share's label is its exchange and symbol", {
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(symbol = "INFY"),
    unified_broker_interface = FakeClient$new()
  )
  member <- BasketMember$new(share, weight = 0.05)

  expect_equal(member$label, "nse:INFY")
  expect_equal(member$format(), "BasketMember('nse:INFY', weight=0.05)")
})

test_that("an option's label is built like Python's, with a float strike", {
  option <- TradeableInstrument$new(
    details = FakeDetails$new()$option(strike_price = 25000),
    unified_broker_interface = FakeClient$new()
  )
  member <- BasketMember$new(option, quantity = 75L)

  expect_equal(member$label, "nse:NIFTY 2026-10-28 25000.0CE")
  expect_equal(
    member$format(),
    "BasketMember('nse:NIFTY 2026-10-28 25000.0CE', quantity=75)"
  )
})

test_that("a member's document holds the identity and the member fields", {
  option <- TradeableInstrument$new(
    details = FakeDetails$new()$option(),
    unified_broker_interface = FakeClient$new()
  )
  document <- BasketMember$new(
    option,
    quantity = 75,
    average_price = 120.5
  )$document()

  expect_equal(
    names(document),
    c(
      "instrument_id",
      "exchange",
      "segment",
      "symbol",
      "underlying_symbol",
      "expiry_date",
      "strike_price",
      "option_type",
      "weight",
      "quantity",
      "average_price"
    )
  )
  expect_equal(document$expiry_date, "2026-10-28")
  expect_null(document$symbol)
  expect_null(document$weight)
  expect_equal(document$average_price, 120.5)
})
