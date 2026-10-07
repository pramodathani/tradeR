FakeDetailsClient <- R6::R6Class(
  "FakeDetailsClient",
  inherit = FakeClient,
  public = list(
    catalogue = list(),

    initialize = function() {
      details <- FakeDetails$new()
      self$catalogue <- list(
        details$equity(symbol = "INFY", instrument_id = "infy-id"),
        details$equity(symbol = "TCS", instrument_id = "tcs-id"),
        details$index(symbol = "NIFTY", instrument_id = "nifty-id")
      )
    },

    post = function(path, body = NULL, params = NULL, timeout_seconds = NULL) {
      if (path != "/api/instruments/details") {
        return(super$post(path, body, params, timeout_seconds))
      }
      self$record("POST", path, body, params)
      results <- list()
      for (index in seq_along(body$instruments)) {
        lookup <- body$instruments[[index]]
        found <- NULL
        for (details in self$catalogue) {
          same_id <- identical(lookup$instrument_id, details$instrument_id)
          same_symbol <- is.null(lookup$instrument_id) &&
            identical(lookup$symbol, details$symbol)
          if (same_id || same_symbol) {
            found <- details
          }
        }
        if (is.null(found)) {
          results[[index]] <- list(
            request_index = index - 1,
            status = 404,
            error = "no instrument"
          )
        } else {
          results[[index]] <- list(
            request_index = index - 1,
            status = 200,
            data = found
          )
        }
      }
      list(results = results)
    }
  )
)
