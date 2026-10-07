CommoditiesFixtures <- R6::R6Class(
  "CommoditiesFixtures",
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
        instrument_id = "commodity-id",
        exchange = "mcx",
        segment = segment,
        shape = shape,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
        mapping_date = "2026-10-07",
        lot_size = 100,
        tick_size = "1",
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

CommoditiesNotFoundClient <- R6::R6Class(
  "CommoditiesNotFoundClient",
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

test_that("each commodity class is built from canned details", {
  fixtures <- CommoditiesFixtures$new()
  client <- fixtures$client_with(fixtures$details("mcx_commodities", symbol = "GOLD"))
  gold <- Commodity$new("mcx", "GOLD", unified_broker_interface = client)
  expect_equal(gold$segment, "mcx_commodities")
  expect_equal(client$requests[[1]]$params$segment, "commodities")
  client <- fixtures$client_with(
    fixtures$details(
      "mcx_commodity_futures",
      shape = "future",
      underlying_symbol = "GOLD",
      expiry_date = "2026-12-04"
    )
  )
  future <- CommodityFutures$new(
    "mcx",
    "GOLD",
    "2026-12-04",
    unified_broker_interface = client
  )
  expect_equal(future$expiry_date, as.Date("2026-12-04"))
  client <- fixtures$client_with(
    fixtures$details(
      "mcx_commodity_options",
      shape = "option",
      underlying_symbol = "GOLD",
      expiry_date = "2026-10-30",
      strike_price = 173500,
      option_type = "CE"
    )
  )
  option <- CommodityOption$new(
    "mcx",
    "GOLD",
    "2026-10-30",
    173500,
    "CE",
    unified_broker_interface = client
  )
  expect_equal(option$strike_price, 173500)
  client <- fixtures$client_with(
    fixtures$details("mcx_commodity_indices", symbol = "MCXBULLDEX")
  )
  index <- CommodityIndex$new("mcx", "MCXBULLDEX", unified_broker_interface = client)
  expect_equal(index$segment, "mcx_commodity_indices")
  client <- fixtures$client_with(
    fixtures$details(
      "mcx_commodity_index_futures",
      shape = "future",
      underlying_symbol = "MCXBULLDEX",
      expiry_date = "2026-10-28"
    )
  )
  index_future <- CommodityIndexFutures$new(
    "mcx",
    "MCXBULLDEX",
    "2026-10-28",
    unified_broker_interface = client
  )
  expect_s3_class(index_future, "IndexFutures")
  client <- fixtures$client_with(
    fixtures$details(
      "mcx_commodity_index_options",
      shape = "option",
      underlying_symbol = "MCXBULLDEX",
      expiry_date = "2026-10-28",
      strike_price = 34900,
      option_type = "CE"
    )
  )
  index_option <- CommodityIndexOption$new(
    "mcx",
    "MCXBULLDEX",
    "2026-10-28",
    34900,
    "CE",
    unified_broker_interface = client
  )
  expect_s3_class(index_option, "IndexOption")
})

test_that("no commodity class carries holdings members", {
  expect_false("holdings" %in% names(Commodity$active))
  expect_false("add_to_holdings" %in% names(Commodity$public_methods))
})

test_that("the segment checks signal the family errors", {
  fixtures <- CommoditiesFixtures$new()
  client <- fixtures$client_with(fixtures$details("nse_equities", symbol = "INFY"))
  expect_error(
    Commodity$new("nse", "INFY", unified_broker_interface = client),
    "is not a Commodity",
    class = "CommodityError"
  )
  client <- fixtures$client_with(
    fixtures$details("mcx_commodity_indices", symbol = "MCXBULLDEX")
  )
  expect_error(
    Commodity$new("mcx", "MCXBULLDEX", unified_broker_interface = client),
    "UBI has no mcx commodity for the symbol MCXBULLDEX",
    class = "CommodityError"
  )
  client <- fixtures$client_with(fixtures$details("mcx_commodities", symbol = "GOLD"))
  expect_error(
    CommodityIndex$new("mcx", "GOLD", unified_broker_interface = client),
    class = "CommodityIndexError"
  )
  client <- fixtures$client_with(
    fixtures$details(
      "mcx_commodity_index_options",
      shape = "option",
      underlying_symbol = "MCXBULLDEX",
      expiry_date = "2026-10-28",
      strike_price = 34900,
      option_type = "CE"
    )
  )
  expect_error(
    CommodityOption$new(
      "mcx",
      "MCXBULLDEX",
      "2026-10-28",
      34900,
      "CE",
      unified_broker_interface = client
    ),
    "is not a CommodityOption",
    class = "CommodityOptionError"
  )
})

test_that("each class turns a missing instrument into its own error", {
  client <- CommoditiesNotFoundClient$new()
  expect_error(
    Commodity$new("mcx", "NOPE", unified_broker_interface = client),
    class = "CommodityError"
  )
  expect_error(
    CommodityFutures$new(
      "mcx",
      "GOLD",
      "2001-01-01",
      unified_broker_interface = client
    ),
    "UBI has no mcx commodity futures contract on GOLD expiring 2001-01-01",
    class = "CommodityFuturesError"
  )
  expect_error(
    CommodityOption$new(
      "mcx",
      "GOLD",
      "2026-10-30",
      1,
      "CE",
      unified_broker_interface = client
    ),
    class = "CommodityOptionError"
  )
  expect_error(
    CommodityIndex$new("mcx", "NOPE", unified_broker_interface = client),
    class = "CommodityIndexError"
  )
  expect_error(
    CommodityIndexFutures$new(
      "mcx",
      "MCXBULLDEX",
      "2001-01-01",
      unified_broker_interface = client
    ),
    class = "CommodityIndexFuturesError"
  )
  expect_error(
    CommodityIndexOption$new(
      "mcx",
      "MCXBULLDEX",
      "2026-10-28",
      1,
      "PE",
      unified_broker_interface = client
    ),
    class = "CommodityIndexOptionError"
  )
})

test_that("the discovery functions read the commodity segments", {
  client <- FakeClient$new()
  client$answers[["/api/instruments/master"]] <- list(
    list(
      instrument_id = "g1",
      exchange = "mcx",
      segment = "mcx_commodity_futures",
      shape = "future",
      underlying_symbol = "GOLD",
      expiry_date = "2099-02-05"
    ),
    list(
      instrument_id = "g2",
      exchange = "mcx",
      segment = "mcx_commodity_futures",
      shape = "future",
      underlying_symbol = "GOLD",
      expiry_date = "2098-12-04"
    ),
    list(
      instrument_id = "s1",
      exchange = "mcx",
      segment = "mcx_commodity_futures",
      shape = "future",
      underlying_symbol = "SILVER",
      expiry_date = "2098-12-04"
    )
  )
  expiries <- CommodityFutures$expiries("mcx", "GOLD", unified_broker_interface = client)
  expect_equal(
    expiries,
    as.Date(
      c(
        "2098-12-04",
        "2099-02-05"
      )
    )
  )
  contracts <- CommodityFutures$contracts(
    "mcx",
    "GOLD",
    unified_broker_interface = client
  )
  expect_equal(
    contracts$instrument_id,
    c(
      "g2",
      "g1"
    )
  )
  CommodityOption$expiries("mcx", "GOLD", unified_broker_interface = client)
  CommodityOption$strikes("mcx", "GOLD", "2098-12-04", unified_broker_interface = client)
  CommodityOption$chain("mcx", "GOLD", "2098-12-04", unified_broker_interface = client)
  CommodityIndexFutures$expiries("mcx", "MCXBULLDEX", unified_broker_interface = client)
  CommodityIndexFutures$contracts("mcx", unified_broker_interface = client)
  CommodityIndexOption$expiries("mcx", "MCXBULLDEX", unified_broker_interface = client)
  CommodityIndexOption$strikes(
    "mcx",
    "MCXBULLDEX",
    "2098-12-04",
    unified_broker_interface = client
  )
  CommodityIndexOption$chain(
    "mcx",
    "MCXBULLDEX",
    "2098-12-04",
    unified_broker_interface = client
  )
  segments <- character(0)
  for (request in client$requests) {
    segments <- c(segments, request$params$segment)
  }
  expect_equal(
    segments,
    c(
      "commodity_futures",
      "commodity_futures",
      "commodity_options",
      "commodity_options",
      "commodity_options",
      "commodity_index_futures",
      "commodity_index_futures",
      "commodity_index_options",
      "commodity_index_options",
      "commodity_index_options"
    )
  )
})

test_that("search sends the segment of each class", {
  client <- FakeClient$new()
  client$answers[["/api/instruments/search"]] <- list(instruments = list())
  expect_null(Commodity$search("mcx", "CRUDE", unified_broker_interface = client))
  CommodityIndex$search("mcx", "BULL", limit = 10, unified_broker_interface = client)
  expect_equal(client$requests[[1]]$params$segment, "commodities")
  expect_equal(client$requests[[1]]$params$q, "CRUDE")
  expect_equal(client$requests[[2]]$params$segment, "commodity_indices")
  expect_equal(client$requests[[2]]$params$limit, 10)
})
