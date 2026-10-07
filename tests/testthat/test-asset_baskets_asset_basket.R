BasketFixture <- R6::R6Class(
  "BasketFixture",
  public = list(
    client = NULL,

    initialize = function() {
      self$client <- FakeClient$new()
    },

    member = function(symbol, weight = NULL) {
      share <- TradeableInstrument$new(
        details = FakeDetails$new()$equity(
          symbol = symbol,
          instrument_id = paste0(symbol, "-id")
        ),
        unified_broker_interface = self$client
      )
      BasketMember$new(share, weight = weight)
    },

    weighted_basket = function() {
      AssetBasket$new(
        name = "IT",
        members = list(
          self$member("INFY", weight = 50),
          self$member("TCS", weight = 30)
        ),
        unified_broker_interface = self$client
      )
    },

    candles = function(first_day, closes) {
      candles <- list()
      for (index in seq_along(closes)) {
        close <- closes[[index]]
        candles[[index]] <- list(
          sprintf("2026-10-%02dT00:00:00+05:30", first_day + index - 1),
          close - 1,
          close + 2,
          close - 2,
          close,
          1000,
          NULL
        )
      }
      list(
        columns = list(
          "time",
          "open",
          "high",
          "low",
          "close",
          "volume",
          "oi"
        ),
        candles = candles
      )
    }
  )
)

test_that("members need distinct instruments and all or no weights", {
  fixture <- BasketFixture$new()

  expect_error(
    AssetBasket$new("empty", list(), unified_broker_interface = fixture$client),
    class = "BasketMemberError"
  )
  expect_error(
    AssetBasket$new(
      "twice",
      list(
        fixture$member("INFY"),
        fixture$member("INFY")
      ),
      unified_broker_interface = fixture$client
    ),
    class = "BasketMemberError"
  )
  expect_error(
    AssetBasket$new(
      "some weights",
      list(
        fixture$member("INFY", weight = 1),
        fixture$member("TCS")
      ),
      unified_broker_interface = fixture$client
    ),
    "Only 1 of 2 members have a weight",
    class = "BasketMemberError"
  )
  expect_error(
    AssetBasket$new(
      "bad share",
      list(
        fixture$member("INFY")
      ),
      unmapped_weight = 1,
      unified_broker_interface = fixture$client
    ),
    class = "ValueError"
  )
})

test_that("weights are normalised and named by label", {
  fixture <- BasketFixture$new()
  basket <- fixture$weighted_basket()

  expect_equal(
    basket$weights,
    c(
      "nse:INFY" = 0.625,
      "nse:TCS" = 0.375
    )
  )
  expect_equal(basket$format(), "AssetBasket(name='IT', size=2)")
  expect_equal(basket$concentration, 0.625^2 + 0.375^2)
  expect_equal(basket$largest_weight, 0.625)
  expect_equal(basket$exposure_by_exchange, c(nse = 1))
  expect_equal(basket$overlap_with(basket), 1)
})

test_that("prices sends one list request and builds candles from base value", {
  fixture <- BasketFixture$new()
  basket <- fixture$weighted_basket()
  fixture$client$answers[["POST /api/instruments/prices"]] <- list(
    results = list(
      list(
        request_index = 1,
        status = 200,
        data = fixture$candles(2, c(200, 210, 220))
      ),
      list(
        request_index = 0,
        status = 200,
        data = fixture$candles(1, c(100, 110, 120, 130))
      )
    )
  )

  frame <- basket$prices(days = 5)
  request <- fixture$client$last_request()

  expect_equal(request$path, "/api/instruments/prices")
  expect_equal(request$body$instruments[[1]]$instrument_id, "INFY-id")
  expect_equal(request$body$days, 5)
  expect_true(request$body$adjusted)
  expect_equal(
    names(frame),
    c(
      "exchange",
      "segment",
      "interval",
      "datetime",
      "open",
      "high",
      "low",
      "close",
      "volume",
      "oi"
    )
  )
  expect_equal(nrow(frame), 3)
  expect_equal(frame$close[[1]], 100)
  expect_equal(frame$segment[[1]], "basket")
  infy_quantity <- 100 * 0.625 / 110
  tcs_quantity <- 100 * 0.375 / 200
  expect_equal(frame$close[[3]], infy_quantity * 130 + tcs_quantity * 220)
  expect_true(all(is.na(frame$volume)))
})

test_that("a member answering an error makes the history fail", {
  fixture <- BasketFixture$new()
  basket <- fixture$weighted_basket()
  fixture$client$answers[["POST /api/instruments/prices"]] <- list(
    results = list(
      list(
        request_index = 0,
        status = 200,
        data = fixture$candles(1, c(100, 110))
      ),
      list(
        request_index = 1,
        status = 404,
        error = "no such instrument"
      )
    )
  )

  expect_error(
    basket$member_closes(days = 5),
    "nse:TCS: no such instrument",
    class = "BasketMemberError"
  )
})

test_that("ohlc keeps a row for a member UBI has no quote for", {
  fixture <- BasketFixture$new()
  basket <- fixture$weighted_basket()
  fixture$client$answers[["POST /api/instruments/ohlc"]] <- list(
    results = list(
      list(
        request_index = 0,
        status = 200,
        data = list(
          ohlc = list(
            open = 100,
            high = 102,
            low = 99
          ),
          last_price = 101,
          previous_close = 100,
          change_percent = 1
        )
      ),
      list(
        request_index = 1,
        status = 503
      )
    )
  )

  frame <- basket$ohlc

  expect_equal(frame$error, c(NA, "HTTP 503"))
  expect_null(basket$day_change_percent)
  expect_equal(basket$breadth$advancers, 1L)
  expect_equal(basket$breadth$unavailable, 1L)
  expect_null(basket$breadth$advance_decline_ratio)
  expect_equal(nrow(basket$top_gainers()), 1)
})

test_that("the document has Python's fields and dates as text", {
  fixture <- BasketFixture$new()
  document <- fixture$weighted_basket()$document(as.Date("2026-10-01"))

  expect_equal(
    names(document),
    c(
      "name",
      "kind",
      "effective_date",
      "linked_instrument_id",
      "unmapped_weight",
      "base_value",
      "members"
    )
  )
  expect_equal(document$effective_date, "2026-10-01")
  expect_length(document$members, 2)
})

test_that("members can be added and removed in memory", {
  fixture <- BasketFixture$new()
  basket <- fixture$weighted_basket()
  basket$add_member(fixture$member("WIPRO", weight = 20))

  expect_equal(basket$size, 3)
  expect_error(
    basket$add_member(fixture$member("HCLTECH")),
    class = "BasketMemberError"
  )

  basket$remove_member(basket$instruments[[1]])

  expect_equal(basket$labels, c("nse:TCS", "nse:WIPRO"))
  expect_error(
    basket$remove_member(fixture$member("SBIN")$instrument),
    class = "BasketMemberError"
  )
})
