test_that("an instrument keeps UBI's details and describes itself like Python", {
  fake <- FakeClient$new()
  option <- Instrument$new(
    details = FakeDetails$new()$option(),
    unified_broker_interface = fake
  )

  expect_equal(option$expiry_date, as.Date("2026-10-28"))
  expect_equal(option$tick_size, 0.05)
  expect_equal(
    option$format(),
    "Instrument(exchange='nse', segment='nse_equity_index_options', underlying_symbol='NIFTY', expiry_date='2026-10-28', strike_price=24000, option_type='CE')"
  )
  expect_length(fake$requests, 0)
})

test_that("an unknown instrument becomes InstrumentError", {
  NotFoundClient <- R6::R6Class(
    "NotFoundClient",
    inherit = FakeClient,
    public = list(
      get = function(path, params = NULL) {
        ErrorCatalogue$raise("NotFoundError", "no match", status_code = 404L)
      }
    )
  )

  expect_error(
    TradeableInstrument$new(
      exchange = "nse",
      segment = "equities",
      symbol = "NOSUCH",
      unified_broker_interface = NotFoundClient$new()
    ),
    class = "InstrumentError"
  )
})

test_that("prices are sorted by time with exchange, segment and interval in front", {
  fake <- FakeClient$new()
  fake$answers[["/api/instruments/prices"]] <- list(
    columns = list(
      "time",
      "open",
      "high",
      "low",
      "close",
      "volume",
      "oi"
    ),
    candles = list(
      list("2026-10-06T00:00:00+05:30", 10, 11, 9, 10.5, 100, NULL),
      list("2026-10-05T00:00:00+05:30", 9, 10, 8, 9.5, 120, NULL)
    )
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )

  candles <- share$prices(days = 2)

  expect_equal(
    names(candles),
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
  expect_equal(
    candles$close,
    c(
      9.5,
      10.5
    )
  )
  expect_equal(fake$last_request()$params$adjusted, "true")
  expect_equal(fake$last_request()$params$days, 2)
})

test_that("no candles give NULL", {
  fake <- FakeClient$new()
  fake$answers[["/api/instruments/prices"]] <- list(
    columns = list(),
    candles = list()
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )

  expect_null(share$prices(days = 2))
})

test_that("an index is refused as tradeable and accepted as non-tradeable", {
  fake <- FakeClient$new()

  expect_error(
    TradeableInstrument$new(
      details = FakeDetails$new()$index(),
      unified_broker_interface = fake
    ),
    class = "TradeableInstrumentError"
  )
  expect_error(
    NonTradeableInstrument$new(
      details = FakeDetails$new()$equity(),
      unified_broker_interface = fake
    ),
    class = "NonTradeableInstrumentError"
  )
})

test_that("order-book values come from one quote", {
  fake <- FakeClient$new()
  fake$answers[["/api/instruments/quote"]] <- list(
    depth = list(
      buy = list(
        list(
          price = 99.9,
          quantity = 5,
          orders = 1
        )
      ),
      sell = list(
        list(
          price = 100.1,
          quantity = 3,
          orders = 2
        )
      )
    ),
    last_trade_time = 1791281700
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )

  expect_equal(share$bid_offer_spread, 0.2, tolerance = 1e-12)
  expect_equal(share$mid_price, 100)
  expect_equal(share$best_offer$orders, 2)
  expect_equal(format(share$last_trade_time, "%H:%M"), "15:45")
  expect_error(share$mid_price <- 1, "read-only")
})

test_that("a price wrapper sends a price reference in Python's field order", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )

  share$sell_at_third_best_offer_price(quantity = 2, product = "mis")
  body <- fake$last_request()$body

  expect_equal(fake$last_request()$path, "/api/orders/place")
  expect_equal(
    names(body),
    c(
      "instrument_id",
      "transaction_type",
      "order_type",
      "product",
      "after_market",
      "dry_run",
      "quantity",
      "price_reference"
    )
  )
  expect_equal(
    body$price_reference,
    list(
      kind = "offer_level",
      level = 3
    )
  )
})

test_that("an unheld limit order is sent at once as a simple synthetic", {
  fake <- FakeClient$new()
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(),
    unified_broker_interface = fake
  )

  share$buy_at_limit_price(price = 99, quantity = 1, product = "cnc", hold = FALSE)

  expect_equal(fake$last_request()$body$synthetic, list(type = "simple"))
  expect_equal(fake$last_request()$body$price, 99)
})

test_that("cancel_open_orders cancels parents first and reports each failure", {
  fake <- FakeClient$new()
  fake$answers[["/api/orders/parents"]] <- list(
    parents = list(
      list(
        instrument_id = "infy-id",
        parent_order_id = "parent-1"
      )
    )
  )
  fake$answers[["/api/orders/details"]] <- list(
    orders = list(
      list(
        instrument_id = "infy-id",
        order_id = "a",
        broker = "zerodha",
        status = "OPEN"
      ),
      list(
        instrument_id = "infy-id",
        order_id = "b",
        broker = "dhan",
        status = "PENDING",
        engine_parent_id = "parent-1"
      ),
      list(
        instrument_id = "other-id",
        order_id = "c",
        broker = "dhan",
        status = "OPEN"
      ),
      list(
        instrument_id = "infy-id",
        order_id = "d",
        broker = "fyers",
        status = "COMPLETE"
      )
    )
  )
  CancellingClient <- R6::R6Class(
    "CancellingClient",
    inherit = FakeClient,
    public = list(
      delete = function(path, body = NULL, params = NULL) {
        self$record("DELETE", path, body, params)
        if (!is.null(body$parent_id)) {
          return(list(state = "cancelled"))
        }
        list(
          results = list(
            list(
              request_index = 0,
              status = 409,
              response = list(
                error = "already complete"
              )
            )
          )
        )
      }
    )
  )
  client <- CancellingClient$new()
  client$answers <- fake$answers
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(instrument_id = "infy-id"),
    unified_broker_interface = client
  )

  outcomes <- share$cancel_open_orders()

  expect_equal(
    outcomes$parent_id,
    c(
      "parent-1",
      NA
    )
  )
  expect_equal(
    outcomes$order_id,
    c(
      NA,
      "a"
    )
  )
  expect_equal(
    outcomes$cancelled,
    c(
      TRUE,
      FALSE
    )
  )
  expect_equal(outcomes$error[[2]], "HTTP 409: already complete")
  expect_length(client$last_request()$body$orders, 1)
})

test_that("positions are valued with their sign and closed by a quantity reference", {
  fake <- FakeClient$new()
  fake$answers[["/api/portfolio/positions"]] <- list(
    net = list(
      list(
        instrument_id = "infy-id",
        product = "intraday",
        quantity = -5,
        last_price = 10,
        pnl = list(
          realized = 1.234,
          unrealized = 2.5
        )
      )
    ),
    day = list()
  )
  share <- TradeableInstrument$new(
    details = FakeDetails$new()$equity(instrument_id = "infy-id"),
    unified_broker_interface = fake
  )

  expect_equal(share$positions_value, -50)
  expect_equal(share$positions_pnl$total, 3.73)

  share$liquidate_position()
  body <- fake$last_request()$body

  expect_equal(body$order_type, "market")
  expect_equal(body$product, "mis")
  expect_equal(
    body$quantity_reference,
    list(
      kind = "liquidate_position",
      product = "intraday"
    )
  )
  expect_equal(
    body$synthetic,
    list(
      type = "simple",
      closes_position = TRUE
    )
  )
  expect_error(
    share$add_to_position(quantity = 1, transaction_type = "buy"),
    class = "PositionError"
  )
})

test_that("an index option is priced with Black-Scholes off its index", {
  fake <- FakeClient$new()
  fake$answers[["/api/instruments/details"]] <- FakeDetails$new()$option(
    expiry_date = "2099-12-30"
  )
  fake$answers[["/api/instruments/ltp"]] <- list(
    last_price = 150
  )
  option <- IndexOption$new(
    instrument_id = "option-id",
    unified_broker_interface = fake
  )

  greeks <- option$greeks(volatility = 0.2, underlying_price = 24000)

  expect_equal(option$underlying_segment, "nse_equity_indices")
  expect_true(option$is_call)
  expect_equal(option$notional_value, 24000 * 75)
  expect_equal(option$breakeven_price, 24150)
  expect_equal(greeks$model, "black_scholes")
  expect_true(greeks$delta > 0 && greeks$delta < 1)
})

test_that("a future outside equities has no default underlying", {
  fake <- FakeClient$new()
  details <- FakeDetails$new()$option()
  details$segment <- "mcx_commodity_futures"
  details$exchange <- "mcx"
  details$shape <- "future"
  details$strike_price <- NULL
  details$option_type <- NULL
  fake$answers[["/api/instruments/details"]] <- details
  future <- Futures$new(
    instrument_id = "future-id",
    unified_broker_interface = fake
  )

  expect_null(future$underlying_segment)
  expect_error(future$underlying, class = "UnderlyingError")
})

test_that("the base classes name no segment for discovery", {
  expect_error(Futures$expiries("nse", "NIFTY"), class = "FuturesError")
  expect_error(Option$chain("nse", "NIFTY", "2026-10-28"), class = "OptionError")
})
