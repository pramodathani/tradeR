CurrenciesFixtures <- R6::R6Class(
  "CurrenciesFixtures",
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
        instrument_id = "currency-id",
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
        tick_size = "0.0025",
        carried_by = list()
      )
    },

    client_with = function(details) {
      client <- FakeClient$new()
      client$answers[["/api/instruments/details"]] <- details
      client
    }
  )
)

CurrenciesNotFoundClient <- R6::R6Class(
  "CurrenciesNotFoundClient",
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

test_that("the populated currency classes are built from canned details", {
  fixtures <- CurrenciesFixtures$new()
  client <- fixtures$client_with(fixtures$details("nse_currencies", symbol = "USDINR"))
  pair <- Currency$new("nse", "USDINR", unified_broker_interface = client)
  expect_equal(pair$segment, "nse_currencies")
  expect_equal(client$requests[[1]]$params$segment, "currencies")
  client <- fixtures$client_with(
    fixtures$details(
      "nse_currency_futures",
      shape = "future",
      underlying_symbol = "USDINR",
      expiry_date = "2026-10-28"
    )
  )
  future <- CurrencyFutures$new(
    "nse",
    "USDINR",
    "2026-10-28",
    unified_broker_interface = client
  )
  expect_equal(future$segment, "nse_currency_futures")
  client <- fixtures$client_with(
    fixtures$details(
      "nse_currency_options",
      shape = "option",
      underlying_symbol = "USDINR",
      expiry_date = "2026-10-28",
      strike_price = 95.625,
      option_type = "PE"
    )
  )
  option <- CurrencyOption$new(
    "nse",
    "USDINR",
    "2026-10-28",
    95.625,
    "PE",
    unified_broker_interface = client
  )
  expect_equal(option$strike_price, 95.625)
})

test_that("the empty index classes would work if UBI gained rows", {
  fixtures <- CurrenciesFixtures$new()
  client <- fixtures$client_with(fixtures$details("nse_currency_indices", symbol = "DXY"))
  index <- CurrencyIndex$new("nse", "DXY", unified_broker_interface = client)
  expect_equal(index$segment, "nse_currency_indices")
  client <- fixtures$client_with(
    fixtures$details(
      "nse_currency_index_options",
      shape = "option",
      underlying_symbol = "DXY",
      expiry_date = "2026-10-28",
      strike_price = 100,
      option_type = "CE"
    )
  )
  option <- CurrencyIndexOption$new(
    "nse",
    "DXY",
    "2026-10-28",
    100,
    "CE",
    unified_broker_interface = client
  )
  expect_s3_class(option, "IndexOption")
})

test_that("the segment checks signal the family errors", {
  fixtures <- CurrenciesFixtures$new()
  client <- fixtures$client_with(fixtures$details("mcx_commodities", symbol = "GOLD"))
  expect_error(
    Currency$new("mcx", "GOLD", unified_broker_interface = client),
    "is not a Currency",
    class = "CurrencyError"
  )
  client <- fixtures$client_with(
    fixtures$details(
      "nse_currency_options",
      shape = "option",
      underlying_symbol = "USDINR",
      expiry_date = "2026-10-28",
      strike_price = 95,
      option_type = "CE"
    )
  )
  expect_error(
    CurrencyIndexOption$new(
      "nse",
      "USDINR",
      "2026-10-28",
      95,
      "CE",
      unified_broker_interface = client
    ),
    class = "CurrencyIndexOptionError"
  )
})

test_that("each class turns a missing instrument into its own error", {
  client <- CurrenciesNotFoundClient$new()
  expect_error(
    Currency$new("nse", "NOPE", unified_broker_interface = client),
    "UBI has no nse currency pair for the symbol NOPE",
    class = "CurrencyError"
  )
  expect_error(
    CurrencyFutures$new(
      "nse",
      "USDINR",
      as.Date("2001-01-01"),
      unified_broker_interface = client
    ),
    "expiring 2001-01-01",
    class = "CurrencyFuturesError"
  )
  expect_error(
    CurrencyOption$new(
      "nse",
      "USDINR",
      "2026-10-28",
      1,
      "CE",
      unified_broker_interface = client
    ),
    class = "CurrencyOptionError"
  )
  expect_error(
    CurrencyIndex$new("nse", "USD", unified_broker_interface = client),
    class = "CurrencyIndexError"
  )
  expect_error(
    CurrencyIndexFutures$new(
      "nse",
      "USD",
      "2026-10-28",
      unified_broker_interface = client
    ),
    class = "CurrencyIndexFuturesError"
  )
  error <- tryCatch(
    CurrencyIndexOption$new(
      "nse",
      "USD",
      "2026-10-28",
      1,
      "CE",
      unified_broker_interface = client
    ),
    InstrumentError = function(error) error
  )
  expect_s3_class(error, "CurrencyIndexOptionError")
  expect_s3_class(error$parent, "InstrumentError")
})

test_that("the empty segments answer the discovery functions without signalling", {
  client <- FakeClient$new()
  client$answers[["/api/instruments/master"]] <- list()
  client$answers[["/api/instruments/search"]] <- list(instruments = list())
  expect_null(CurrencyIndex$search("nse", "USD", unified_broker_interface = client))
  expect_length(
    CurrencyIndexFutures$expiries("nse", "USD", unified_broker_interface = client),
    0
  )
  expect_null(CurrencyIndexFutures$contracts("nse", unified_broker_interface = client))
  expect_length(
    CurrencyIndexOption$expiries("nse", "USD", unified_broker_interface = client),
    0
  )
  expect_length(
    CurrencyIndexOption$strikes(
      "nse",
      "USD",
      "2026-10-28",
      unified_broker_interface = client
    ),
    0
  )
  expect_null(
    CurrencyIndexOption$chain(
      "nse",
      "USD",
      "2026-10-28",
      unified_broker_interface = client
    )
  )
  segments <- character(0)
  for (request in client$requests) {
    segments <- c(segments, request$params$segment)
  }
  expect_equal(
    segments,
    c(
      "currency_indices",
      "currency_index_futures",
      "currency_index_futures",
      "currency_index_options",
      "currency_index_options",
      "currency_index_options"
    )
  )
})

test_that("the populated discovery functions read the currency segments", {
  client <- FakeClient$new()
  client$answers[["/api/instruments/master"]] <- list(
    list(
      instrument_id = "u2",
      exchange = "nse",
      segment = "nse_currency_options",
      shape = "option",
      underlying_symbol = "USDINR",
      expiry_date = "2099-10-28",
      strike_price = 96,
      option_type = "CE"
    ),
    list(
      instrument_id = "u1",
      exchange = "nse",
      segment = "nse_currency_options",
      shape = "option",
      underlying_symbol = "USDINR",
      expiry_date = "2099-10-28",
      strike_price = 95.625,
      option_type = "CE"
    )
  )
  chain <- CurrencyOption$chain(
    "nse",
    "USDINR",
    "2099-10-28",
    unified_broker_interface = client
  )
  expect_equal(
    chain$instrument_id,
    c(
      "u1",
      "u2"
    )
  )
  CurrencyFutures$expiries("nse", "USDINR", unified_broker_interface = client)
  Currency$search("nse", "USD", unified_broker_interface = client)
  expect_equal(client$requests[[1]]$params$segment, "currency_options")
  expect_equal(client$requests[[2]]$params$segment, "currency_futures")
  expect_equal(client$requests[[3]]$params$segment, "currencies")
})
