test_that("an equity is looked up in the equities segment", {
  fake <- FakeClient$new()
  fake$answers[["/api/instruments/details"]] <- FakeDetails$new()$equity()

  share <- Equity$new(exchange = "nse", symbol = "INFY", unified_broker_interface = fake)

  expect_s3_class(share, "Equity")
  expect_equal(fake$last_request()$params$segment, "equities")
  expect_equal(fake$last_request()$params$symbol, "INFY")
})

test_that("an index given to Equity becomes EquityError", {
  fake <- FakeClient$new()
  fake$answers[["/api/instruments/details"]] <- FakeDetails$new()$index()

  caught <- tryCatch(
    Equity$new(exchange = "nse", symbol = "NIFTY", unified_broker_interface = fake),
    InstrumentError = function(error) error
  )

  expect_s3_class(caught, "EquityError")
  expect_equal(conditionMessage(caught), "UBI has no nse share for the symbol NIFTY")
  expect_s3_class(caught$parent, "TradeableInstrumentError")
})

test_that("holdings sell only the free shares, always as cnc", {
  fake <- FakeClient$new()
  fake$answers[["/api/instruments/details"]] <- FakeDetails$new()$equity()
  fake$answers[["/api/portfolio/holdings"]] <- list(
    holdings = list(
      list(
        instrument_id = "infy-id",
        symbol = "INFY",
        quantity = 10,
        collateral_quantity = 4,
        current_value = 14500,
        pnl = list(
          unrealized = 120
        )
      )
    )
  )
  share <- Equity$new(exchange = "nse", symbol = "INFY", unified_broker_interface = fake)

  expect_equal(share$holdings_value, 14500)
  expect_equal(share$holdings_pnl$unrealized, 120)
  expect_error(share$reduce_holdings(quantity = 7), class = "HoldingError")

  share$liquidate_holdings(price = 1500)
  body <- fake$last_request()$body

  expect_equal(body$transaction_type, "sell")
  expect_equal(body$product, "cnc")
  expect_equal(body$quantity, 6)
  expect_equal(body$price, 1500)
})

test_that("option discovery narrows the master to one underlying and expiry", {
  fake <- FakeClient$new()
  fake$answers[["/api/instruments/master"]] <- list(
    list(
      instrument_id = "a",
      underlying_symbol = "RELIANCE",
      expiry_date = "2099-01-29",
      strike_price = 1400,
      option_type = "PE"
    ),
    list(
      instrument_id = "b",
      underlying_symbol = "RELIANCE",
      expiry_date = "2099-01-29",
      strike_price = 1300,
      option_type = "CE"
    ),
    list(
      instrument_id = "c",
      underlying_symbol = "TCS",
      expiry_date = "2099-01-29",
      strike_price = 4000,
      option_type = "CE"
    ),
    list(
      instrument_id = "d",
      underlying_symbol = "RELIANCE",
      expiry_date = "2000-01-27",
      strike_price = 1300,
      option_type = "CE"
    )
  )

  chain <- EquityOption$chain(
    "nse",
    "reliance",
    "2099-01-29",
    unified_broker_interface = fake
  )

  expect_equal(
    chain$instrument_id,
    c(
      "b",
      "a"
    )
  )
  expect_equal(
    EquityOption$strikes("nse", "RELIANCE", "2099-01-29", unified_broker_interface = fake),
    c(
      1300,
      1400
    )
  )
  expect_equal(
    EquityOption$expiries("nse", "RELIANCE", unified_broker_interface = fake),
    as.Date("2099-01-29")
  )
  expect_equal(
    length(EquityOption$expiries("nse", "RELIANCE", include_expired = TRUE, unified_broker_interface = fake)),
    2
  )
})
