test_that("the synthetic object names only the type when nothing else is set", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- SyntheticOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13
  )

  expect_equal(order$synthetic, list(type = "simple"))
  expect_equal(order$synthetic_fields(), list())
})

test_that("closes_position and reduce_only are sent only when TRUE, and hold_limits whenever set", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- SyntheticOrder$new(
    share,
    transaction_type = "sell",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 14,
    closes_position = TRUE,
    reduce_only = TRUE,
    hold_limits = FALSE
  )

  expect_true(order$synthetic$closes_position)
  expect_true(order$synthetic$reduce_only)
  expect_false(order$synthetic$hold_limits)

  order$reduce_only <- FALSE
  order$hold_limits <- NULL
  expect_null(order$synthetic$reduce_only)
  expect_false("hold_limits" %in% names(order$synthetic))
})

test_that("place sends the template and synthetic object and keeps the parent id", {
  fake <- FakeClient$new()
  fake$answers[["POST /api/orders/place"]] <- list(
    outcome = "armed",
    parent_id = "parent-1"
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- SyntheticOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 2,
    price = 13,
    tag = "test"
  )

  answer <- order$place()

  request <- fake$last_request()
  expect_equal(request$method, "POST")
  expect_equal(request$path, "/api/orders/place")
  expect_equal(request$body$instrument_id, "infy-id")
  expect_equal(request$body$quantity, 2)
  expect_equal(request$body$tag, "test")
  expect_null(request$body$trigger_price)
  expect_equal(request$body$synthetic, list(type = "simple"))
  expect_equal(answer$outcome, "armed")
  expect_equal(order$parent_id, "parent-1")
})

test_that("an answer without a parent id leaves the order unplaced", {
  fake <- FakeClient$new()
  fake$answers[["POST /api/orders/place"]] <- list(
    dry_run = TRUE,
    request = list()
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- SyntheticOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13,
    dry_run = TRUE
  )

  order$place()

  expect_true(fake$last_request()$body$dry_run)
  expect_null(order$parent_id)
  expect_error(order$cancel(), class = "ValueError")
  expect_error(order$parent, class = "ValueError")
  expect_error(order$orders, class = "ValueError")
  expect_error(order$trades, class = "ValueError")
})

test_that("cancel, parent, orders and trades act on the kept parent id", {
  fake <- FakeClient$new()
  fake$answers[["POST /api/orders/place"]] <- list(
    outcome = "accepted",
    order_id = "order-1",
    parent_id = "parent-1"
  )
  fake$answers[["DELETE /api/orders/cancel"]] <- list(
    parent_id = "parent-1",
    state = "cancelled",
    cancelled_legs = list()
  )
  fake$answers[["/api/orders/parents"]] <- list(
    parent_order_id = "parent-1",
    state = "working"
  )
  fake$answers[["/api/orders/details"]] <- list(
    orders = list()
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- SyntheticOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13
  )
  order$place()

  expect_equal(order$parent$state, "working")
  expect_equal(fake$last_request()$params$parent_id, "parent-1")
  expect_null(order$orders)
  expect_equal(fake$last_request()$params$parent_id, "parent-1")

  answer <- order$cancel()
  expect_equal(answer$state, "cancelled")
  expect_equal(fake$last_request()$method, "DELETE")
  expect_equal(fake$last_request()$body$parent_id, "parent-1")
})

test_that("the read-only members refuse assignment", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  order <- SyntheticOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1
  )

  expect_error(order$synthetic <- list(), "read-only")
  expect_error(order$parent <- list(), "read-only")
})
