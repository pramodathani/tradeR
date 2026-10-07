FundsFixtures <- R6::R6Class(
  "FundsFixtures",
  public = list(
    details = function(segment, symbol) {
      list(
        instrument_id = "fund-id",
        exchange = "nse",
        segment = segment,
        shape = "security",
        symbol = symbol,
        mapping_date = "2026-10-07",
        lot_size = 1,
        tick_size = "0.01",
        carried_by = list()
      )
    },

    client_with = function(details) {
      client <- FakeClient$new()
      client$answers[["/api/instruments/details"]] <- details
      client
    },

    fund = function() {
      client <- self$client_with(
        self$details("nse_exchange_traded_funds", "NIFTYBEES")
      )
      list(
        client = client,
        instrument = ExchangeTradedFund$new(
          "nse",
          "NIFTYBEES",
          unified_broker_interface = client
        )
      )
    },

    trust = function() {
      client <- self$client_with(self$details("nse_investment_trusts", "EMBASSY"))
      list(
        client = client,
        instrument = InvestmentTrust$new(
          "nse",
          "EMBASSY",
          unified_broker_interface = client
        )
      )
    },

    holding = function(instrument_id, symbol, quantity, collateral_quantity) {
      list(
        holdings = list(
          list(
            instrument_id = instrument_id,
            symbol = symbol,
            quantity = quantity,
            collateral_quantity = collateral_quantity,
            current_value = 2665.3,
            pnl = list(
              day_change = 4.5,
              day_change_percentage = 0.17,
              unrealized = 120
            )
          )
        )
      )
    },

    use_stand_in_basket_store = function(environment, test_environment) {
      stand_in <- R6::R6Class(
        "StandInBasketStore",
        public = list(
          unified_broker_interface = NULL,
          initialize = function(unified_broker_interface = NULL) {
            self$unified_broker_interface <- unified_broker_interface
          },
          load_for_instrument = function(instrument) {
            list(
              unified_broker_interface = self$unified_broker_interface,
              instrument_id = instrument$instrument_id
            )
          }
        )
      )
      had_store <- exists("BasketStore", envir = environment, inherits = FALSE)
      original_store <- NULL
      was_locked <- FALSE
      if (had_store) {
        original_store <- get("BasketStore", envir = environment)
        was_locked <- bindingIsLocked("BasketStore", environment)
      }
      if (was_locked) {
        unlockBinding("BasketStore", environment)
      }
      assign("BasketStore", stand_in, envir = environment)
      withr::defer(
        {
          if (had_store) {
            assign("BasketStore", original_store, envir = environment)
          } else {
            rm("BasketStore", envir = environment)
          }
          if (was_locked) {
            lockBinding("BasketStore", environment)
          }
        },
        envir = test_environment
      )
    }
  )
)

FundsNotFoundClient <- R6::R6Class(
  "FundsNotFoundClient",
  inherit = FakeClient,
  public = list(
    get = function(path, params = NULL) {
      if (path == "/api/instruments/details") {
        ErrorCatalogue$raise("NotFoundError", "no such instrument")
      }
      super$get(path, params)
    }
  )
)

test_that("both classes are built from canned details", {
  fixtures <- FundsFixtures$new()
  made <- fixtures$fund()
  expect_equal(made$instrument$segment, "nse_exchange_traded_funds")
  expect_equal(made$client$requests[[1]]$params$segment, "exchange_traded_funds")
  made <- fixtures$trust()
  expect_equal(made$instrument$segment, "nse_investment_trusts")
  expect_equal(made$client$requests[[1]]$params$segment, "investment_trusts")
})

test_that("the segment checks and missing instruments signal the family errors", {
  fixtures <- FundsFixtures$new()
  client <- fixtures$client_with(fixtures$details("nse_equities", "INFY"))
  expect_error(
    ExchangeTradedFund$new("nse", "INFY", unified_broker_interface = client),
    "is not an ExchangeTradedFund",
    class = "ExchangeTradedFundError"
  )
  client <- fixtures$client_with(
    fixtures$details("nse_exchange_traded_funds", "NIFTYBEES")
  )
  expect_error(
    InvestmentTrust$new("nse", "NIFTYBEES", unified_broker_interface = client),
    "is not an InvestmentTrust",
    class = "InvestmentTrustError"
  )
  client <- FundsNotFoundClient$new()
  expect_error(
    ExchangeTradedFund$new("nse", "NOPE", unified_broker_interface = client),
    "UBI has no nse exchange traded fund for the symbol NOPE",
    class = "ExchangeTradedFundError"
  )
  expect_error(
    InvestmentTrust$new("nse", "NOPE", unified_broker_interface = client),
    "UBI has no nse investment trust for the symbol NOPE",
    class = "InvestmentTrustError"
  )
})

test_that("search sends the segment of each class", {
  client <- FakeClient$new()
  client$answers[["/api/instruments/search"]] <- list(
    instruments = list(
      list(
        instrument_id = "f1",
        exchange = "nse",
        segment = "nse_exchange_traded_funds",
        shape = "security",
        symbol = "NIFTYBEES"
      )
    )
  )
  matches <- ExchangeTradedFund$search(
    "nse",
    "NIFTYBEE",
    unified_broker_interface = client
  )
  expect_equal(matches$symbol, "NIFTYBEES")
  InvestmentTrust$search("nse", "INVIT", limit = 20, unified_broker_interface = client)
  expect_equal(client$requests[[1]]$params$segment, "exchange_traded_funds")
  expect_equal(client$requests[[2]]$params$segment, "investment_trusts")
  expect_equal(client$requests[[2]]$params$limit, 20)
})

test_that("the holdings members read the canned holdings, falling back to the symbol", {
  fixtures <- FundsFixtures$new()
  made <- fixtures$fund()
  made$client$answers[["/api/portfolio/holdings"]] <- list(holdings = list())
  expect_null(made$instrument$holdings)
  expect_null(made$instrument$holdings_value)
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(
    "other-exchange-id",
    "NIFTYBEES",
    10,
    0
  )
  expect_equal(made$instrument$holdings_value, 2665.3)
  expect_equal(made$instrument$holdings_pnl$unrealized, 120)
})

test_that("the fund's holdings orders use the ordinary cnc wrappers", {
  fixtures <- FundsFixtures$new()
  made <- fixtures$fund()
  made$instrument$add_to_holdings(quantity = 2)
  expect_equal(
    made$client$last_request()$body,
    list(
      instrument_id = "fund-id",
      transaction_type = "buy",
      order_type = "market",
      product = "cnc",
      after_market = FALSE,
      dry_run = FALSE,
      quantity = 2
    )
  )
  made$instrument$add_to_holdings(quantity = 2, price = 258.5)
  expect_equal(
    made$client$last_request()$body,
    list(
      instrument_id = "fund-id",
      transaction_type = "buy",
      order_type = "limit",
      product = "cnc",
      after_market = FALSE,
      dry_run = FALSE,
      quantity = 2,
      price = 258.5
    )
  )
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(
    "fund-id",
    "NIFTYBEES",
    10,
    4
  )
  made$instrument$liquidate_holdings(price = 275)
  body <- made$client$last_request()$body
  expect_equal(body$transaction_type, "sell")
  expect_equal(body$quantity, 6L)
  expect_null(body$synthetic)
  expect_error(
    made$instrument$reduce_holdings(quantity = 7),
    "6 of the 10 NIFTYBEES units held are free to sell, because 4 are pledged as collateral, so 7 cannot be sold",
    fixed = TRUE
  )
})

test_that("the trust's holdings orders refuse when nothing is free", {
  fixtures <- FundsFixtures$new()
  made <- fixtures$trust()
  made$client$answers[["/api/portfolio/holdings"]] <- list(holdings = list())
  expect_error(
    made$instrument$liquidate_holdings(),
    "No EMBASSY units are held",
    class = "HoldingError"
  )
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(
    "fund-id",
    "EMBASSY",
    10,
    10
  )
  expect_error(
    made$instrument$liquidate_holdings(),
    "All 10 EMBASSY units held are pledged as collateral, so none can be sold",
    class = "HoldingError"
  )
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(
    "fund-id",
    "EMBASSY",
    10,
    0
  )
  made$instrument$reduce_holdings(quantity = 5)
  body <- made$client$last_request()$body
  expect_equal(body$order_type, "market")
  expect_equal(body$quantity, 5)
  expect_null(body$synthetic)
})

test_that("only the fund has constituents, read through the basket store", {
  fixtures <- FundsFixtures$new()
  expect_true("constituents" %in% names(ExchangeTradedFund$active))
  expect_false("constituents" %in% names(InvestmentTrust$active))
  fixtures$use_stand_in_basket_store(
    ExchangeTradedFund$parent_env,
    environment()
  )
  made <- fixtures$fund()
  basket <- made$instrument$constituents
  expect_identical(basket$unified_broker_interface, made$client)
  expect_equal(basket$instrument_id, "fund-id")
  expect_error(made$instrument$constituents <- 1, "read-only")
})
