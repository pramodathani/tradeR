test_that("a watchlist weights its instruments equally and refuses repeats", {
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
  followed <- Watchlist$new(
    name = "it",
    instruments = list(
      infosys
    ),
    unified_broker_interface = fake
  )

  followed$add(tcs)

  expect_equal(followed$labels, c("nse:INFY", "nse:TCS"))
  expect_equal(unname(followed$weights), c(0.5, 0.5))
  expect_equal(followed$document("2026-10-01")$kind, "watchlist")
  expect_error(followed$add(tcs), class = "BasketMemberError")
})

test_that("rank_by sorts by a column and puts missing values last", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()
  instruments <- list()
  for (symbol in c(
    "INFY",
    "TCS",
    "IDEA"
  )) {
    instruments[[length(instruments) + 1]] <- TradeableInstrument$new(
      details = details$equity(symbol, paste0(symbol, "-id")),
      unified_broker_interface = fake
    )
  }
  followed <- Watchlist$new(
    name = "three",
    instruments = instruments,
    unified_broker_interface = fake
  )
  fake$answers[["POST /api/instruments/ohlc"]] <- list(
    results = list(
      list(
        request_index = 0,
        status = 200,
        data = list(last_price = 1, change_percent = 1)
      ),
      list(request_index = 1, status = 404, error = "no quote"),
      list(
        request_index = 2,
        status = 200,
        data = list(last_price = 2, change_percent = 5)
      )
    )
  )

  expect_equal(
    followed$rank_by()$label,
    c("nse:IDEA", "nse:INFY", "nse:TCS")
  )
  expect_equal(
    followed$rank_by("last_price", ascending = TRUE)$label,
    c("nse:INFY", "nse:IDEA", "nse:TCS")
  )
  expect_error(followed$rank_by("no_such_column"), class = "KeyError")
})
