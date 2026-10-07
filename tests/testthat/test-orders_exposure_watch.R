test_that("a watch sends exposure_per_unit only when it is set", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )

  expect_equal(
    ExposureWatch$new(share)$document(),
    list(
      instrument_id = "infy-id"
    )
  )
  expect_equal(
    ExposureWatch$new(share, exposure_per_unit = 0.5)$document(),
    list(
      instrument_id = "infy-id",
      exposure_per_unit = 0.5
    )
  )
})
