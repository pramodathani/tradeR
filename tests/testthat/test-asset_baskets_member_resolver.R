test_that("every row is looked up in one details request", {
  fake <- FakeDetailsClient$new()
  resolver <- MemberResolver$new(fake)
  members <- resolver$resolve(
    list(
      list(exchange = "nse", segment = "equities", symbol = "INFY", weight = 0.6),
      list(instrument_id = "nifty-id", symbol = "ignored", weight = 0.4)
    )
  )

  expect_length(fake$requests, 1)
  expect_equal(
    fake$requests[[1]]$body,
    list(
      instruments = list(
        list(exchange = "nse", segment = "equities", symbol = "INFY"),
        list(instrument_id = "nifty-id")
      )
    )
  )
  expect_s3_class(members[[1]]$instrument, "TradeableInstrument")
  expect_s3_class(members[[2]]$instrument, "NonTradeableInstrument")
  expect_equal(members[[1]]$weight, 0.6)
  expect_equal(members[[2]]$label, "nse:NIFTY")
})

test_that("every failed row is listed in one error", {
  resolver <- MemberResolver$new(FakeDetailsClient$new())
  expect_error(
    resolver$resolve(
      list(
        list(exchange = "nse", segment = "equities", symbol = "INFY"),
        list(exchange = "nse", segment = "equities", symbol = "NOSUCH")
      )
    ),
    "UBI could not find 1 of 2 instruments: \\{'exchange': 'nse', 'segment': 'equities', 'symbol': 'NOSUCH'\\}: no instrument",
    class = "BasketMemberError"
  )
})

test_that("a row without an exchange and a segment is refused", {
  resolver <- MemberResolver$new(FakeDetailsClient$new())
  expect_error(
    resolver$resolve(list(list(symbol = "INFY", weight = 1))),
    "row=\\{'symbol': 'INFY', 'weight': 1.0\\}",
    class = "BasketMemberError"
  )
  expect_error(resolver$resolve(list()), class = "BasketMemberError")
})

test_that("resolve_one returns the instrument", {
  resolver <- MemberResolver$new(FakeDetailsClient$new())
  instrument <- resolver$resolve_one(list(instrument_id = "tcs-id"))
  expect_equal(instrument$symbol, "TCS")
})
