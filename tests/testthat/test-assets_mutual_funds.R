MutualFundsFixtures <- R6::R6Class(
  "MutualFundsFixtures",
  public = list(
    details = function(segment, symbol) {
      list(
        instrument_id = "scheme-id",
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

    scheme = function() {
      client <- self$client_with(self$details("nse_mutual_funds", "ABSLFTTIDG"))
      list(
        client = client,
        instrument = MutualFund$new(
          "nse",
          "ABSLFTTIDG",
          unified_broker_interface = client
        )
      )
    },

    holding = function(quantity, collateral_quantity) {
      list(
        holdings = list(
          list(
            instrument_id = "scheme-id",
            symbol = "ABSLFTTIDG",
            quantity = quantity,
            collateral_quantity = collateral_quantity,
            last_price = 25,
            current_value = 250,
            pnl = list(
              day_change = 0,
              day_change_percentage = 0,
              unrealized = 12
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

MutualFundsNotFoundClient <- R6::R6Class(
  "MutualFundsNotFoundClient",
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

test_that("MutualFund is built from canned details and looks up the mutual funds segment", {
  fixtures <- MutualFundsFixtures$new()
  made <- fixtures$scheme()
  expect_equal(made$instrument$segment, "nse_mutual_funds")
  expect_equal(made$client$requests[[1]]$params$segment, "mutual_funds")
})

test_that("the segment check and a missing scheme signal MutualFundError", {
  fixtures <- MutualFundsFixtures$new()
  client <- fixtures$client_with(fixtures$details("nse_equities", "INFY"))
  expect_error(
    MutualFund$new("nse", "INFY", unified_broker_interface = client),
    "is not a MutualFund",
    class = "MutualFundError"
  )
  client <- MutualFundsNotFoundClient$new()
  error <- tryCatch(
    MutualFund$new("nse", "NOPE", unified_broker_interface = client),
    InstrumentError = function(error) error
  )
  expect_s3_class(error, "MutualFundError")
  expect_equal(
    conditionMessage(error),
    "UBI has no nse mutual fund for the symbol NOPE"
  )
  expect_s3_class(error$parent, "InstrumentError")
})

test_that("search sends the mutual funds segment", {
  client <- FakeClient$new()
  client$answers[["/api/instruments/search"]] <- list(instruments = list())
  expect_null(MutualFund$search("nse", "ABSL", unified_broker_interface = client))
  expect_equal(client$requests[[1]]$params$segment, "mutual_funds")
  expect_equal(client$requests[[1]]$params$q, "ABSL")
  expect_equal(client$requests[[1]]$params$limit, 50)
})

test_that("the holdings members read the canned holdings", {
  fixtures <- MutualFundsFixtures$new()
  made <- fixtures$scheme()
  made$client$answers[["/api/portfolio/holdings"]] <- list(holdings = list())
  expect_null(made$instrument$holdings)
  expect_null(made$instrument$holdings_pnl)
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(10, 0)
  expect_equal(made$instrument$holdings_value, 250)
  expect_equal(made$instrument$holdings_pnl$unrealized, 12)
})

test_that("the holdings orders are sent at once as cnc", {
  fixtures <- MutualFundsFixtures$new()
  made <- fixtures$scheme()
  made$instrument$add_to_holdings(quantity = 2, price = 25)
  expect_equal(
    made$client$last_request()$body,
    list(
      instrument_id = "scheme-id",
      transaction_type = "buy",
      order_type = "limit",
      product = "cnc",
      after_market = FALSE,
      dry_run = FALSE,
      quantity = 2,
      price = 25,
      synthetic = list(
        type = "simple"
      )
    )
  )
  made$instrument$add_to_holdings(quantity = 2)
  expect_equal(made$client$last_request()$body$order_type, "market")
  expect_equal(made$client$last_request()$body$synthetic$type, "simple")
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(10, 4)
  made$instrument$reduce_holdings(quantity = 5, price = 25)
  body <- made$client$last_request()$body
  expect_equal(body$transaction_type, "sell")
  expect_equal(body$quantity, 5)
  expect_equal(body$synthetic$type, "simple")
  made$instrument$liquidate_holdings()
  body <- made$client$last_request()$body
  expect_equal(body$order_type, "market")
  expect_equal(body$quantity, 6L)
  expect_equal(body$synthetic$type, "simple")
})

test_that("selling refuses when nothing is free", {
  fixtures <- MutualFundsFixtures$new()
  made <- fixtures$scheme()
  made$client$answers[["/api/portfolio/holdings"]] <- list(holdings = list())
  expect_error(
    made$instrument$reduce_holdings(quantity = 1, price = 25),
    "No ABSLFTTIDG units are held",
    class = "HoldingError"
  )
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(10, 10)
  expect_error(
    made$instrument$liquidate_holdings(price = 25),
    "All 10 ABSLFTTIDG units held are pledged as collateral",
    class = "HoldingError"
  )
})

test_that("constituents is read through the basket store", {
  fixtures <- MutualFundsFixtures$new()
  fixtures$use_stand_in_basket_store(MutualFund$parent_env, environment())
  made <- fixtures$scheme()
  basket <- made$instrument$constituents
  expect_identical(basket$unified_broker_interface, made$client)
  expect_equal(basket$instrument_id, "scheme-id")
})
