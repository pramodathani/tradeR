test_that("a bracket sends its stop and target and drops the ones not given", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- BracketOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13,
    stop_price = 12.5,
    stop_limit_price = 12.45
  )

  expect_equal(order$SYNTHETIC_TYPE, "bracket")
  expect_null(order$synthetic_fields()$target_price)
  expect_true("target_price" %in% names(order$synthetic_fields()))
  expect_equal(
    order$synthetic,
    list(
      type = "bracket",
      stop_price = 12.5,
      stop_limit_price = 12.45
    )
  )

  order$place()
  expect_equal(fake$last_request()$body$synthetic$type, "bracket")
  expect_equal(fake$last_request()$body$price, 13)
})
