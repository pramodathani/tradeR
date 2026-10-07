FixedIncomeFixtures <- R6::R6Class(
  "FixedIncomeFixtures",
  public = list(
    details = function(
      segment,
      shape = "security",
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL
    ) {
      list(
        instrument_id = "bond-id",
        exchange = "nse",
        segment = segment,
        shape = shape,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
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

    bond = function() {
      details <- self$details("nse_fixed_income", symbol = "IN000126C010")
      client <- self$client_with(details)
      list(
        client = client,
        bond = FixedIncome$new(
          exchange = "nse",
          symbol = "IN000126C010",
          unified_broker_interface = client
        )
      )
    },

    holding = function(quantity, collateral_quantity) {
      list(
        holdings = list(
          list(
            instrument_id = "bond-id",
            symbol = "IN000126C010",
            isin = "IN000126C010",
            quantity = quantity,
            collateral_quantity = collateral_quantity,
            current_value = 1000.5,
            pnl = list(
              day_change = 1,
              day_change_percentage = 0.1,
              unrealized = 50
            )
          )
        )
      )
    }
  )
)

FixedIncomeNotFoundClient <- R6::R6Class(
  "FixedIncomeNotFoundClient",
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

test_that("FixedIncome is built from canned details and looks up the fixed income segment", {
  fixtures <- FixedIncomeFixtures$new()
  made <- fixtures$bond()
  expect_equal(made$bond$segment, "nse_fixed_income")
  expect_equal(made$client$requests[[1]]$params$segment, "fixed_income")
  expect_equal(
    made$bond$format(),
    "FixedIncome(exchange='nse', segment='nse_fixed_income', symbol='IN000126C010')"
  )
})

test_that("an instrument outside the segment signals FixedIncomeError", {
  fixtures <- FixedIncomeFixtures$new()
  client <- fixtures$client_with(fixtures$details("nse_equities", symbol = "INFY"))
  expect_error(
    FixedIncome$new("nse", "INFY", unified_broker_interface = client),
    "is not a FixedIncome",
    class = "FixedIncomeError"
  )
  client <- fixtures$client_with(
    fixtures$details(
      "nse_fixed_income_index_futures",
      shape = "future",
      underlying_symbol = "ONMIBOR",
      expiry_date = "2026-09-30"
    )
  )
  expect_error(
    FixedIncomeFutures$new(
      "nse",
      "ONMIBOR",
      "2026-09-30",
      unified_broker_interface = client
    ),
    "is not a FixedIncomeFutures",
    class = "FixedIncomeFuturesError"
  )
})

test_that("an index asked for as a bond signals FixedIncomeError", {
  fixtures <- FixedIncomeFixtures$new()
  client <- fixtures$client_with(
    fixtures$details("nse_fixed_income_indices", symbol = "ONMIBOR")
  )
  expect_error(
    FixedIncome$new("nse", "ONMIBOR", unified_broker_interface = client),
    "UBI has no nse bond for the symbol ONMIBOR",
    class = "FixedIncomeError"
  )
})

test_that("each class turns a missing instrument into its own error", {
  client <- FixedIncomeNotFoundClient$new()
  expect_error(
    FixedIncome$new("nse", "IN0000000000", unified_broker_interface = client),
    class = "FixedIncomeError"
  )
  expect_error(
    FixedIncomeIndex$new("nse", "X", unified_broker_interface = client),
    class = "FixedIncomeIndexError"
  )
  expect_error(
    FixedIncomeFutures$new(
      "nse",
      "633GS2035",
      "2001-01-25",
      unified_broker_interface = client
    ),
    "UBI has no nse bond futures contract on 633GS2035 expiring 2001-01-25",
    class = "FixedIncomeFuturesError"
  )
  expect_error(
    FixedIncomeOption$new(
      "nse",
      "633GS2035",
      "2026-09-24",
      999999,
      "CE",
      unified_broker_interface = client
    ),
    class = "FixedIncomeOptionError"
  )
  expect_error(
    FixedIncomeIndexFutures$new(
      "nse",
      "ONMIBOR",
      "2001-01-25",
      unified_broker_interface = client
    ),
    class = "FixedIncomeIndexFuturesError"
  )
  error <- tryCatch(
    FixedIncomeIndexOption$new(
      "nse",
      "ONMIBOR",
      "2026-09-30",
      5.5,
      "CE",
      unified_broker_interface = client
    ),
    InstrumentError = function(error) error
  )
  expect_s3_class(error, "FixedIncomeIndexOptionError")
  expect_s3_class(error$parent, "InstrumentError")
})

test_that("the option discovery functions read the fixed income options master", {
  client <- FakeClient$new()
  client$answers[["/api/instruments/master"]] <- list(
    list(
      instrument_id = "a",
      exchange = "nse",
      segment = "nse_fixed_income_options",
      shape = "option",
      underlying_symbol = "633GS2035",
      expiry_date = "2099-12-31",
      strike_price = 98,
      option_type = "PE"
    ),
    list(
      instrument_id = "b",
      exchange = "nse",
      segment = "nse_fixed_income_options",
      shape = "option",
      underlying_symbol = "633GS2035",
      expiry_date = "2099-12-31",
      strike_price = 97.25,
      option_type = "CE"
    ),
    list(
      instrument_id = "c",
      exchange = "nse",
      segment = "nse_fixed_income_options",
      shape = "option",
      underlying_symbol = "633GS2035",
      expiry_date = "2099-11-26",
      strike_price = 97.25,
      option_type = "CE"
    )
  )
  expiries <- FixedIncomeOption$expiries(
    "nse",
    "633GS2035",
    unified_broker_interface = client
  )
  expect_equal(
    expiries,
    as.Date(
      c(
        "2099-11-26",
        "2099-12-31"
      )
    )
  )
  strikes <- FixedIncomeOption$strikes(
    "nse",
    "633GS2035",
    "2099-12-31",
    unified_broker_interface = client
  )
  expect_equal(
    strikes,
    c(
      97.25,
      98
    )
  )
  chain <- FixedIncomeOption$chain(
    "nse",
    "633GS2035",
    "2099-12-31",
    unified_broker_interface = client
  )
  expect_equal(
    chain$instrument_id,
    c(
      "b",
      "a"
    )
  )
  expect_equal(client$requests[[1]]$params$segment, "fixed_income_options")
})

test_that("the empty index options segment answers without signalling", {
  client <- FakeClient$new()
  client$answers[["/api/instruments/master"]] <- list()
  expect_length(
    FixedIncomeIndexOption$expiries(
      "nse",
      "ONMIBOR",
      unified_broker_interface = client
    ),
    0
  )
  expect_length(
    FixedIncomeIndexOption$strikes(
      "nse",
      "ONMIBOR",
      "2026-09-30",
      unified_broker_interface = client
    ),
    0
  )
  expect_null(
    FixedIncomeIndexOption$chain(
      "nse",
      "ONMIBOR",
      "2026-09-30",
      unified_broker_interface = client
    )
  )
  expect_null(
    FixedIncomeIndexFutures$contracts("nse", unified_broker_interface = client)
  )
  expect_equal(client$requests[[4]]$params$segment, "fixed_income_index_futures")
})

test_that("search sends the term, limit and segment", {
  client <- FakeClient$new()
  client$answers[["/api/instruments/search"]] <- list(
    instruments = list(
      list(
        instrument_id = "s1",
        exchange = "nse",
        segment = "nse_fixed_income",
        shape = "security",
        symbol = "633GS2035"
      )
    )
  )
  matches <- FixedIncome$search("nse", "GS2035", unified_broker_interface = client)
  expect_equal(matches$symbol, "633GS2035")
  expect_equal(client$requests[[1]]$params$segment, "fixed_income")
  expect_equal(client$requests[[1]]$params$limit, 50)
  FixedIncomeIndex$search("nse", "MIBOR", limit = 5, unified_broker_interface = client)
  expect_equal(client$requests[[2]]$params$segment, "fixed_income_indices")
  expect_equal(client$requests[[2]]$params$limit, 5)
})

test_that("the holdings members read the canned holdings", {
  fixtures <- FixedIncomeFixtures$new()
  made <- fixtures$bond()
  made$client$answers[["/api/portfolio/holdings"]] <- list(holdings = list())
  expect_null(made$bond$holdings)
  expect_null(made$bond$holdings_value)
  expect_null(made$bond$holdings_pnl)
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(10, 0)
  expect_equal(made$bond$holdings_value, 1000.5)
  expect_equal(made$bond$holdings_pnl$unrealized, 50)
  expect_error(made$bond$holdings <- 1, "read-only")
})

test_that("the holdings orders are sent at once as cnc", {
  fixtures <- FixedIncomeFixtures$new()
  made <- fixtures$bond()
  made$bond$add_to_holdings(quantity = 2)
  expect_equal(
    made$client$last_request()$body,
    list(
      instrument_id = "bond-id",
      transaction_type = "buy",
      order_type = "market",
      product = "cnc",
      after_market = FALSE,
      dry_run = FALSE,
      quantity = 2,
      synthetic = list(
        type = "simple"
      )
    )
  )
  made$bond$add_to_holdings(quantity = 2, price = 90)
  expect_equal(made$client$last_request()$body$order_type, "limit")
  expect_equal(made$client$last_request()$body$price, 90)
  expect_equal(made$client$last_request()$body$synthetic$type, "simple")
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(10, 4)
  made$bond$liquidate_holdings(price = 150)
  body <- made$client$last_request()$body
  expect_equal(body$transaction_type, "sell")
  expect_equal(body$quantity, 6L)
  expect_equal(body$synthetic$type, "simple")
  made$bond$reduce_holdings(quantity = 5)
  body <- made$client$last_request()$body
  expect_equal(body$order_type, "market")
  expect_equal(body$synthetic$type, "simple")
})

test_that("selling refuses when nothing is free", {
  fixtures <- FixedIncomeFixtures$new()
  made <- fixtures$bond()
  made$client$answers[["/api/portfolio/holdings"]] <- list(holdings = list())
  expect_error(
    made$bond$reduce_holdings(quantity = 1, price = 150),
    "No IN000126C010 units are held",
    class = "HoldingError"
  )
  made$client$answers[["/api/portfolio/holdings"]] <- fixtures$holding(10, 10)
  expect_error(
    made$bond$reduce_holdings(quantity = 5),
    "0 of the 10 IN000126C010 units held are free to sell, because 10 are pledged as collateral, so 5 cannot be sold",
    fixed = TRUE
  )
  expect_error(
    made$bond$liquidate_holdings(),
    "All 10 IN000126C010 units held are pledged as collateral",
    class = "HoldingError"
  )
})
