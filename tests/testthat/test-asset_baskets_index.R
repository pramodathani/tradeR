test_that("an index checks its weighting and base value", {
  fake <- FakeClient$new()
  infosys <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )
  members <- list(
    BasketMember$new(infosys)
  )

  expect_error(
    Index$new(
      name = "x",
      members = members,
      weighting = "cap",
      unified_broker_interface = fake
    ),
    class = "ValueError"
  )
  expect_error(
    Index$new(
      name = "x",
      members = members,
      weighting = "equal",
      base_value = 0,
      unified_broker_interface = fake
    ),
    class = "ValueError"
  )
  expect_error(
    Index$new(name = "x", members = members, unified_broker_interface = fake),
    class = "BasketMemberError"
  )
})

test_that("a price weighting follows the last prices", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  infosys <- TradeableInstrument$new(
    details = details$equity("INFY", "infy-id"),
    unified_broker_interface = fake
  )
  idea <- TradeableInstrument$new(
    details = details$equity("IDEA", "idea-id"),
    unified_broker_interface = fake
  )
  price_index <- Index$new(
    name = "price",
    members = list(
      BasketMember$new(infosys),
      BasketMember$new(idea)
    ),
    weighting = "price",
    unified_broker_interface = fake
  )
  fake$answers[["POST /api/instruments/ltp"]] <- list(
    results = list(
      list(request_index = 0, status = 200, data = list(last_price = 90)),
      list(request_index = 1, status = 200, data = list(last_price = 10))
    )
  )

  expect_equal(unname(price_index$weights), c(0.9, 0.1))
  document <- price_index$document("2026-10-01")
  expect_equal(document$weighting, "price")
  expect_true("base_date" %in% names(document))
  expect_null(document$base_date)
})

test_that("to_portfolio floors units and leaves out members it cannot buy", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  infosys <- TradeableInstrument$new(
    details = details$equity("INFY", "infy-id"),
    unified_broker_interface = fake
  )
  idea <- TradeableInstrument$new(
    details = details$equity("IDEA", "idea-id"),
    unified_broker_interface = fake
  )
  equal_index <- Index$new(
    name = "two",
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
      list(request_index = 1, status = 200, data = list(last_price = 10))
    )
  )

  holdings <- equal_index$to_portfolio(capital = 2000)

  expect_s3_class(holdings, "Portfolio")
  expect_equal(holdings$name, "two portfolio")
  expect_equal(holdings$labels, "nse:IDEA")
  expect_equal(unname(holdings$quantities), 100)
  expect_error(
    equal_index$to_portfolio(capital = 5),
    class = "BasketMemberError"
  )
})

test_that("level needs a base date and values the base quantities now", {
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
  members <- list(
    BasketMember$new(infosys),
    BasketMember$new(tcs)
  )
  unbased <- Index$new(
    name = "unbased",
    members = members,
    weighting = "equal",
    unified_broker_interface = fake
  )
  expect_error(unbased$level, class = "AssetBasketError")

  based <- Index$new(
    name = "based",
    members = members,
    weighting = "equal",
    base_value = 1000,
    base_date = "2026-01-01",
    unified_broker_interface = fake
  )
  columns <- list(
    "time",
    "open",
    "high",
    "low",
    "close"
  )
  fake$answers[["POST /api/instruments/prices"]] <- list(
    results = list(
      list(
        request_index = 0,
        status = 200,
        data = list(
          columns = columns,
          candles = list(
            list("2026-01-02T00:00:00+05:30", 100, 100, 100, 100)
          )
        )
      ),
      list(
        request_index = 1,
        status = 200,
        data = list(
          columns = columns,
          candles = list(
            list("2026-01-02T00:00:00+05:30", 50, 50, 50, 50)
          )
        )
      )
    )
  )
  fake$answers[["POST /api/instruments/ltp"]] <- list(
    results = list(
      list(request_index = 0, status = 200, data = list(last_price = 110)),
      list(request_index = 1, status = 200, data = list(last_price = 50))
    )
  )

  expect_equal(based$level, 500 * 110 / 100 + 500)
  prices_request <- fake$requests[[length(fake$requests) - 1]]
  expect_equal(prices_request$body$from, "2026-01-01")
  expect_equal(prices_request$body$to, "2026-01-11")
})

test_that("price-weighted candles hold the same quantity of each member", {
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
  price_index <- Index$new(
    name = "price",
    members = list(
      BasketMember$new(infosys),
      BasketMember$new(tcs)
    ),
    weighting = "price",
    unified_broker_interface = fake
  )
  columns <- list(
    "time",
    "open",
    "high",
    "low",
    "close"
  )
  fake$answers[["POST /api/instruments/prices"]] <- list(
    results = list(
      list(
        request_index = 0,
        status = 200,
        data = list(
          columns = columns,
          candles = list(
            list("2026-01-02T00:00:00+05:30", 30, 30, 30, 30),
            list("2026-01-03T00:00:00+05:30", 40, 40, 40, 40)
          )
        )
      ),
      list(
        request_index = 1,
        status = 200,
        data = list(
          columns = columns,
          candles = list(
            list("2026-01-02T00:00:00+05:30", 70, 70, 70, 70),
            list("2026-01-03T00:00:00+05:30", 70, 70, 70, 70)
          )
        )
      )
    )
  )

  candles <- price_index$prices(days = 5)

  expect_equal(candles$close, c(100, 110))
  expect_equal(candles$segment, c("index", "index"))
})
