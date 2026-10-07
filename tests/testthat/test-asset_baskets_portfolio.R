test_that("a portfolio needs a quantity on every member", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  expect_error(
    Portfolio$new(
      name = "no quantity",
      members = list(
        BasketMember$new(share)
      ),
      unified_broker_interface = fake
    ),
    class = "BasketMemberError"
  )
})

test_that("values, weights and profit follow the last prices", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  infosys <- TradeableInstrument$new(
    details = details$equity("INFY", "infy-id"),
    unified_broker_interface = fake
  )
  tcs <- TradeableInstrument$new(
    details = details$equity("TCS", "tcs-id"),
    unified_broker_interface = fake
  )
  held <- Portfolio$new(
    name = "pair",
    members = list(
      BasketMember$new(infosys, quantity = 5, average_price = 1400),
      BasketMember$new(tcs, quantity = -2, average_price = 3100)
    ),
    unified_broker_interface = fake
  )
  fake$answers[["POST /api/instruments/ltp"]] <- list(
    results = list(
      list(request_index = 1, status = 200, data = list(last_price = 3000)),
      list(request_index = 0, status = 200, data = list(last_price = 1500))
    )
  )

  expect_equal(unname(held$values), c(7500, -6000))
  expect_equal(held$value, 1500)
  expect_equal(unname(held$weights), c(7500, -6000) / 13500)
  expect_equal(held$invested_value, 5 * 1400 - 2 * 3100)
  expect_equal(held$unrealized_pnl, 1500 - 800)
})

test_that("place_orders sends UBI's list form with market bodies", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  infosys <- TradeableInstrument$new(
    details = details$equity("INFY", "infy-id"),
    unified_broker_interface = fake
  )
  tcs <- TradeableInstrument$new(
    details = details$equity("TCS", "tcs-id"),
    unified_broker_interface = fake
  )
  held <- Portfolio$new(
    name = "pair",
    members = list(
      BasketMember$new(infosys, quantity = 5),
      BasketMember$new(tcs, quantity = -2)
    ),
    unified_broker_interface = fake
  )
  fake$answers[["POST /api/orders/place"]] <- list(
    results = list(
      list(
        request_index = 1,
        status = 409,
        intent_id = "intent-2",
        response = list(error = "no book")
      ),
      list(
        request_index = 0,
        status = 200,
        intent_id = "intent-1",
        response = list(
          broker = "zerodha",
          outcome = "accepted",
          order_id = "order-1"
        )
      )
    )
  )

  results <- held$place_orders(
    product = "cnc",
    tag = "basket",
    dry_run = TRUE,
    as_marketable_limit = FALSE
  )

  request <- fake$last_request()
  expect_equal(request$path, "/api/orders/place")
  expect_true(request$body$dry_run)
  expect_length(request$body$orders, 2)
  first_order <- request$body$orders[[1]]
  expect_equal(first_order$transaction_type, "buy")
  expect_identical(first_order$quantity, 5L)
  expect_equal(first_order$order_type, "market")
  expect_false(first_order$after_market)
  expect_equal(first_order$tag, "basket")
  expect_equal(first_order$synthetic, list(type = "simple"))
  expect_equal(request$body$orders[[2]]$transaction_type, "sell")
  expect_identical(request$body$orders[[2]]$quantity, 2L)
  expect_equal(results$outcome, c("accepted", NA))
  expect_equal(results$error, c(NA, "no book"))
  expect_equal(results$intent_id, c("intent-1", "intent-2"))
})

test_that("a marketable limit order carries no synthetic object and no tag", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  held <- Portfolio$new(
    name = "one",
    members = list(
      BasketMember$new(share, quantity = 1)
    ),
    unified_broker_interface = fake
  )
  fake$answers[["POST /api/orders/place"]] <- list(
    results = list(
      list(request_index = 0, status = 200, response = list())
    )
  )

  held$place_orders(product = "mis")

  order <- fake$last_request()$body$orders[[1]]
  expect_null(order$synthetic)
  expect_null(order$tag)
  expect_false(fake$last_request()$body$dry_run)
})

test_that("a portfolio with nothing to trade sends nothing", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  held <- Portfolio$new(
    name = "empty",
    members = list(
      BasketMember$new(share, quantity = 0)
    ),
    unified_broker_interface = fake
  )

  results <- held$place_orders(product = "cnc")

  expect_equal(nrow(results), 0)
  expect_equal(
    names(results),
    c(
      "label",
      "instrument_id",
      "transaction_type",
      "quantity",
      "status",
      "broker",
      "outcome",
      "order_id",
      "parent_id",
      "intent_id",
      "error"
    )
  )
  expect_length(fake$requests, 0)
})

test_that("rebalance_trades floors towards zero and lists sells first", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  infosys <- TradeableInstrument$new(
    details = details$equity("INFY", "infy-id"),
    unified_broker_interface = fake
  )
  tcs <- TradeableInstrument$new(
    details = details$equity("TCS", "tcs-id"),
    unified_broker_interface = fake
  )
  idea <- TradeableInstrument$new(
    details = details$equity("IDEA", "idea-id"),
    unified_broker_interface = fake
  )
  held <- Portfolio$new(
    name = "held",
    members = list(
      BasketMember$new(infosys, quantity = 5),
      BasketMember$new(tcs, quantity = 2)
    ),
    unified_broker_interface = fake
  )
  target <- Index$new(
    name = "target",
    members = list(
      BasketMember$new(infosys),
      BasketMember$new(idea)
    ),
    weighting = "equal",
    unified_broker_interface = fake
  )
  fake$answers[["POST /api/instruments/ltp"]] <- list(
    results = list(
      list(request_index = 0, status = 200, data = list(last_price = 1500)),
      list(request_index = 1, status = 200, data = list(last_price = 3000)),
      list(request_index = 2, status = 200, data = list(last_price = 10))
    )
  )

  trades <- held$rebalance_trades(target = target, capital = 10000)

  expect_equal(trades$label, c("nse:INFY", "nse:TCS", "nse:IDEA"))
  expect_equal(trades$trade_quantity, c(-2, -2, 500))
  expect_equal(trades$target_quantity, c(3, 0, 500))
  expect_equal(trades$transaction_type, c("sell", "sell", "buy"))
})

test_that("from_positions merges products into one member", {
  fake <- FakeClient$new()
  fake$answers[["/api/portfolio/positions"]] <- list(
    net = list(
      list(instrument_id = "infy-id", quantity = 3, average_price = 1400),
      list(instrument_id = "infy-id", quantity = 2, average_price = 1500),
      list(instrument_id = "tcs-id", quantity = 0, average_price = 3000)
    ),
    day = list()
  )
  fake$answers[["POST /api/instruments/details"]] <- list(
    results = list(
      list(
        request_index = 0,
        status = 200,
        data = FakeDetails$new()$equity("INFY", "infy-id")
      )
    )
  )

  positions <- Portfolio$from_positions(unified_broker_interface = fake)

  expect_equal(positions$size, 1)
  expect_equal(positions$members[[1]]$quantity, 5)
  expect_null(positions$members[[1]]$average_price)
  expect_equal(
    fake$last_request()$body,
    list(
      instruments = list(
        list(instrument_id = "infy-id")
      )
    )
  )
  expect_error(
    Portfolio$from_positions(day = TRUE, unified_broker_interface = fake),
    class = "BasketMemberError"
  )
})

test_that("from_holdings keeps quantity and average price", {
  fake <- FakeClient$new()
  fake$answers[["/api/portfolio/holdings"]] <- list(
    holdings = list(
      list(
        instrument_id = "infy-id",
        exchange = "nse",
        segment = "nse_equities",
        symbol = "INFY",
        quantity = 10,
        average_price = 1450
      ),
      list(instrument_id = "tcs-id", quantity = 0)
    )
  )
  fake$answers[["POST /api/instruments/details"]] <- list(
    results = list(
      list(
        request_index = 0,
        status = 200,
        data = FakeDetails$new()$equity("INFY", "infy-id")
      )
    )
  )

  held <- Portfolio$from_holdings(unified_broker_interface = fake)

  expect_equal(held$name, "holdings")
  expect_equal(held$KIND, "portfolio")
  expect_equal(held$members[[1]]$quantity, 10)
  expect_equal(held$members[[1]]$average_price, 1450)
})
