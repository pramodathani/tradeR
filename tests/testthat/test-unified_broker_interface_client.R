UnifiedBrokerInterfaceTestServer <- R6::R6Class(
  "UnifiedBrokerInterfaceTestServer",
  public = list(
    seen = list(),
    replies = list(),

    respond = function(request) {
      self$seen[[length(self$seen) + 1]] <- request
      reply <- self$replies[[1]]
      self$replies <- self$replies[-1]
      httr2::response_json(
        status_code = reply$status_code,
        body = reply$body
      )
    }
  )
)

test_client <- function() {
  UnifiedBrokerInterface$new(
    base_url = "http://ubi.test/",
    credentials = list(
      api_key = "key",
      api_secret = "secret"
    ),
    project_configuration = Configuration$new(load_environment_file = FALSE)
  )
}

test_that("the first request connects, then sends the token and query", {
  server <- UnifiedBrokerInterfaceTestServer$new()
  server$replies <- list(
    list(
      status_code = 200,
      body = list(
        "access-token" = "token-1",
        expires_at = "2026-10-08T06:00:00+05:30"
      )
    ),
    list(
      status_code = 200,
      body = list(
        last_price = 1450.5
      )
    )
  )
  httr2::local_mocked_responses(function(req) server$respond(req))
  client <- test_client()

  answer <- client$get(
    "/api/instruments/ltp",
    params = list(
      instrument_id = "infy id",
      unused = NULL
    )
  )

  expect_equal(answer$last_price, 1450.5)
  expect_equal(server$seen[[1]]$url, "http://ubi.test/api/session/connect")
  expect_equal(server$seen[[1]]$headers[["api-key"]], "key")
  expect_equal(
    server$seen[[2]]$url,
    "http://ubi.test/api/instruments/ltp?instrument_id=infy%20id"
  )
  expect_equal(server$seen[[2]]$headers[["access-token"]], "token-1")
  expect_equal(client$token_expires_at, "2026-10-08T06:00:00+05:30")
})

test_that("a 401 reconnects once and retries", {
  server <- UnifiedBrokerInterfaceTestServer$new()
  server$replies <- list(
    list(
      status_code = 200,
      body = list(
        "access-token" = "old"
      )
    ),
    list(
      status_code = 401,
      body = list(
        error = "expired"
      )
    ),
    list(
      status_code = 200,
      body = list(
        "access-token" = "new"
      )
    ),
    list(
      status_code = 200,
      body = list(
        connected = TRUE
      )
    )
  )
  httr2::local_mocked_responses(function(req) server$respond(req))

  answer <- test_client()$status()

  expect_true(answer$connected)
  expect_equal(server$seen[[4]]$headers[["access-token"]], "new")
})

test_that("a failing status becomes its own error class with the skipped brokers", {
  server <- UnifiedBrokerInterfaceTestServer$new()
  server$replies <- list(
    list(
      status_code = 200,
      body = list(
        "access-token" = "token"
      )
    ),
    list(
      status_code = 503,
      body = list(
        error = "no broker can take the order",
        skipped = list(
          list(
            broker = "zerodha",
            reason = "at order limit"
          )
        )
      )
    )
  )
  httr2::local_mocked_responses(function(req) server$respond(req))

  caught <- tryCatch(
    test_client()$post(
      "/api/orders/place",
      body = list(
        quantity = 1
      )
    ),
    UnifiedBrokerInterfaceError = function(error) error
  )

  expect_s3_class(caught, "ServiceUnavailableError")
  expect_equal(
    conditionMessage(caught),
    "no broker can take the order (zerodha: at order limit)"
  )
  expect_equal(caught$status_code, 503)
})

test_that("an unmapped status is a ServerError", {
  server <- UnifiedBrokerInterfaceTestServer$new()
  server$replies <- list(
    list(
      status_code = 200,
      body = list(
        "access-token" = "token"
      )
    ),
    list(
      status_code = 500,
      body = list()
    )
  )
  httr2::local_mocked_responses(function(req) server$respond(req))

  caught <- tryCatch(
    test_client()$get("/api/anything"),
    UnifiedBrokerInterfaceError = function(error) error
  )

  expect_s3_class(caught, "ServerError")
  expect_equal(conditionMessage(caught), "UBI returned HTTP 500")
})

test_that("a client without a base url or credentials is refused", {
  withr::local_envvar(
    c(
      TRADINGMACHINE_UBI_BASE_URL = NA
    )
  )
  expect_error(
    UnifiedBrokerInterface$new(
      credentials = list(
        api_key = "key",
        api_secret = "secret"
      ),
      project_configuration = Configuration$new(load_environment_file = FALSE)
    ),
    "UBI base url is not configured"
  )
  expect_error(
    UnifiedBrokerInterface$new(
      base_url = "http://ubi.test",
      credentials = list(
        api_key = "key"
      )
    ),
    "missing api_key or api_secret"
  )
})
