test_that("synthetic holds the type and the root part's document", {
  client <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(symbol = "IDEA", instrument_id = "idea-id"),
    unified_broker_interface = client
  )
  order <- PlanOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13.0,
    plan = ThenPart$new(
      first = OrderPart$new(),
      each_fill = OrderPart$new(
        side = "protect",
        pricing = TrailPricing$new(points = 0.3, limit_offset = 0.05)
      )
    )
  )
  actual <- jsonlite::toJSON(
    order$synthetic,
    auto_unbox = TRUE,
    digits = NA
  )
  expected <- r"({"type":"plan","plan":{"then":{"first":{"order":{}},"each_fill":{"order":{"side":"protect","pricing":[{"trail":{"points":0.3,"limit_offset":0.05}}]}}}}})"
  expect_equal(
    as.character(actual),
    expected
  )
})

test_that("place sends the plan with the template and keeps the parent id", {
  client <- FakeClient$new()
  client$answers[["POST /api/orders/place"]] <- list(
    outcome = "armed",
    parent_id = "parent-1"
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(symbol = "IDEA", instrument_id = "idea-id"),
    unified_broker_interface = client
  )
  order <- PlanOrder$new(
    share,
    transaction_type = "sell",
    product = "nrml",
    order_type = "market",
    quantity = NULL,
    plan = OrderPart$new(
      side = "close",
      quantity = PositionQuantity$new(every_instrument = TRUE)
    ),
    closes_position = TRUE,
    hold_limits = FALSE
  )
  order$place()
  request <- client$last_request()
  expect_equal(request$method, "POST")
  expect_equal(request$path, "/api/orders/place")
  actual <- jsonlite::toJSON(
    request$body$synthetic,
    auto_unbox = TRUE,
    digits = NA
  )
  expected <- r"({"type":"plan","plan":{"order":{"side":"close","quantity":{"position":{"every_instrument":true}}}},"closes_position":true,"hold_limits":false})"
  expect_equal(
    as.character(actual),
    expected
  )
  expect_equal(order$parent_id, "parent-1")
})

test_that("parts lists each part sorted by path, with the record's fields", {
  client <- FakeClient$new()
  client$answers[["POST /api/orders/place"]] <- list(
    outcome = "armed",
    parent_id = "parent-1"
  )
  client$answers[["/api/orders/parents"]] <- list(
    parameters = list(
      parts = list(
        root.first = list(
          state = "done",
          reason = "filled"
        ),
        root.each_fill.children.0 = list(
          state = "waiting"
        ),
        root.Z = list(
          state = "working"
        )
      )
    )
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(symbol = "IDEA", instrument_id = "idea-id"),
    unified_broker_interface = client
  )
  order <- PlanOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13.0,
    plan = OrderPart$new()
  )
  order$place()
  parts <- order$parts
  expect_equal(
    names(parts),
    c(
      "path",
      "state",
      "reason"
    )
  )
  expect_equal(
    parts$path,
    c(
      "root.Z",
      "root.each_fill.children.0",
      "root.first"
    )
  )
  expect_equal(
    parts$reason,
    c(
      NA,
      NA,
      "filled"
    )
  )
  expect_equal(client$last_request()$params$parent_id, "parent-1")
})

test_that("parts is NULL when UBI holds no parts", {
  client <- FakeClient$new()
  client$answers[["POST /api/orders/place"]] <- list(
    outcome = "armed",
    parent_id = "parent-1"
  )
  client$answers[["/api/orders/parents"]] <- list(
    parameters = list(
      parts = structure(list(), names = character(0))
    )
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(symbol = "IDEA", instrument_id = "idea-id"),
    unified_broker_interface = client
  )
  order <- PlanOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13.0,
    plan = OrderPart$new()
  )
  order$place()
  expect_null(order$parts)
})

test_that("cancel_part and modify_part name the parent and the part", {
  client <- FakeClient$new()
  client$answers[["POST /api/orders/place"]] <- list(
    outcome = "armed",
    parent_id = "parent-1"
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(symbol = "IDEA", instrument_id = "idea-id"),
    unified_broker_interface = client
  )
  order <- PlanOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13.0,
    plan = OrderPart$new(
      presets = list(
        Preset$new(
          "bracket",
          stop_price = 12.5,
          stop_limit_price = 12.45,
          target_price = 13.6
        )
      )
    )
  )
  order$place()
  order$cancel_part("root.each_fill.children.1", dry_run = TRUE)
  request <- client$last_request()
  expect_equal(request$method, "DELETE")
  expect_equal(request$path, "/api/orders/cancel")
  expect_equal(
    request$body,
    list(
      parent_id = "parent-1",
      dry_run = TRUE,
      part = "root.each_fill.children.1"
    )
  )
  order$modify_part(
    "root.each_fill.children.0",
    price = 12.35,
    trigger_price = 12.4
  )
  request <- client$last_request()
  expect_equal(request$method, "PUT")
  expect_equal(request$path, "/api/orders/modify")
  expect_equal(request$body$parent_id, "parent-1")
  expect_equal(request$body$part, "root.each_fill.children.0")
  expect_equal(request$body$price, 12.35)
  expect_equal(request$body$trigger_price, 12.4)
  expect_false(request$body$dry_run)
})

test_that("acting on a part before placing signals ValueError", {
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(symbol = "IDEA", instrument_id = "idea-id"),
    unified_broker_interface = FakeClient$new()
  )
  order <- PlanOrder$new(
    share,
    transaction_type = "buy",
    product = "mis",
    order_type = "limit",
    quantity = 1,
    price = 13.0,
    plan = OrderPart$new()
  )
  expect_error(
    order$cancel_part("root.first"),
    "This plan order has no parent_id",
    class = "ValueError"
  )
  expect_error(
    order$modify_part("root.first", price = 12.0),
    class = "ValueError"
  )
  expect_error(order$parts, class = "ValueError")
})
