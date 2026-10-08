#' Build an entry in a share that waits for the Nifty index, not the share, to rise through a level.
#'
#' The program reads the Nifty index's last price, sets a level 0.5% above it, and builds a `price_crosses` condition that watches the index through its `instrument` setting, so the object carries the index's `instrument_id`. A share bought on that condition enters when the whole market breaks out. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/price_crosses/price_crosses/entry_when_the_index_rises.R

library(tradeR)

#' An entry that waits for the Nifty index to rise through a level.
#'
#' @field index The `EquityIndex` for the Nifty on the NSE.
IndexTriggeredEntry <- R6::R6Class(
  "IndexTriggeredEntry",
  public = list(
    index = NULL,

    #' @description
    #' Looks up the index.
    #' @return A new `IndexTriggeredEntry` object.
    #' @details Errors: signals `InstrumentError` when the index could not be found in UBI.
    initialize = function() {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    },

    #' @description
    #' Builds the entry that waits for the index to reach a level.
    #' @param level The numeric index level.
    #' @return The `OrderPart`.
    build_order = function(level) {
      OrderPart$new(
        trigger = PriceCrosses$new(
          level = level,
          direction = "at_or_above",
          instrument = self$index
        )
      )
    },

    #' @description
    #' Prints the index's last price, the level and the entry's object.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the index.
    run = function() {
      last_price <- self$index$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$index$format())
        )
      }
      level <- round(last_price * 1.005, 2)
      cat(sprintf("Nifty last price: %s, level: %s\n", last_price, level))
      cat(
        jsonlite::toJSON(
          self$build_order(level)$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexTriggeredEntry$new()$run()
}
