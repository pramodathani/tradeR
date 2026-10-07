FakeClient <- R6::R6Class(
  "FakeClient",
  public = list(
    requests = list(),
    answers = list(),

    get = function(path, params = NULL) {
      self$record("GET", path, NULL, params)
      self$answers[[path]]
    },

    post = function(path, body = NULL, params = NULL, timeout_seconds = NULL) {
      self$record("POST", path, body, params)
      answer <- self$answers[[paste("POST", path)]]
      if (is.null(answer)) {
        answer <- list(
          outcome = "accepted",
          order_id = "fake-order"
        )
      }
      answer
    },

    put = function(path, body = NULL, params = NULL) {
      self$record("PUT", path, body, params)
      self$answers[[paste("PUT", path)]]
    },

    patch = function(path, body = NULL, params = NULL) {
      self$record("PATCH", path, body, params)
      self$answers[[paste("PATCH", path)]]
    },

    delete = function(path, body = NULL, params = NULL) {
      self$record("DELETE", path, body, params)
      self$answers[[paste("DELETE", path)]]
    },

    record = function(method, path, body, params) {
      self$requests[[length(self$requests) + 1]] <- list(
        method = method,
        path = path,
        body = body,
        params = params
      )
      invisible(NULL)
    },

    last_request = function() {
      self$requests[[length(self$requests)]]
    }
  )
)

FakeDetails <- R6::R6Class(
  "FakeDetails",
  public = list(
    equity = function(symbol = "INFY", instrument_id = "infy-id") {
      list(
        instrument_id = instrument_id,
        exchange = "nse",
        segment = "nse_equities",
        shape = "security",
        symbol = symbol,
        underlying_symbol = NULL,
        expiry_date = NULL,
        strike_price = NULL,
        option_type = NULL,
        mapping_date = "2026-10-07",
        first_seen_date = "2020-01-01",
        last_seen_date = "2026-10-07",
        lot_size = 1,
        tick_size = "0.05",
        carried_by = list()
      )
    },

    index = function(symbol = "NIFTY", instrument_id = "nifty-id") {
      details <- self$equity(symbol = symbol, instrument_id = instrument_id)
      details$segment <- "nse_equity_indices"
      details
    },

    option = function(
      underlying_symbol = "NIFTY",
      expiry_date = "2026-10-28",
      strike_price = 24000,
      option_type = "CE",
      instrument_id = "option-id"
    ) {
      list(
        instrument_id = instrument_id,
        exchange = "nse",
        segment = "nse_equity_index_options",
        shape = "option",
        symbol = NULL,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
        underlying_instrument_id = NULL,
        mapping_date = "2026-10-07",
        first_seen_date = NULL,
        last_seen_date = NULL,
        lot_size = 75,
        tick_size = "0.05",
        carried_by = list()
      )
    }
  )
)
