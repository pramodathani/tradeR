test_that("an exposure hedge sends its watched instruments and its own instrument", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  hedge <- TradeableInstrument$new(
    details = details$equity(),
    unified_broker_interface = fake
  )
  option <- TradeableInstrument$new(
    details = details$option(),
    unified_broker_interface = fake
  )
  order <- ExposureHedgeOrder$new(
    hedge,
    watched = list(
      ExposureWatch$new(option, exposure_per_unit = 0.5)
    ),
    lower_band = -75,
    upper_band = 75,
    product = "nrml"
  )

  synthetic <- order$synthetic
  text <- as.character(jsonlite::toJSON(synthetic, auto_unbox = TRUE))

  expect_equal(synthetic$hedge_instrument_id, "infy-id")
  expect_null(synthetic$hedge_exposure_per_unit)
  expect_match(text, "\"watched\":[{", fixed = TRUE)
  expect_equal(order$transaction_type, "buy")
  expect_equal(order$quantity, 1)
})
