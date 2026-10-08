#' Build a stop-and-reverse on Vodafone Idea that fires when the Nifty 50 falls 1%.
#'
#' The program reads the Nifty 50's level and builds a close of Vodafone Idea's intraday position, triggered by the index rather than the share, with `ratio` 2, so one order closes the position and opens the same size the other way. A long of 1,000 shares therefore becomes a short of 1,000. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/position_quantity/position_quantity/reverse_on_a_fall_in_the_index.R

library(tradeR)

#' A close-and-reverse of a share, fired by the index.
#'
#' @field share The `Equity` whose position is reversed.
#' @field index The `EquityIndex` watched.
ReverseOnIndexFall <- R6::R6Class(
  "ReverseOnIndexFall",
  public = list(
    share = NULL,
    index = NULL,

    #' @description
    #' Looks the share and the index up.
    #' @return A new `ReverseOnIndexFall` object.
    #' @details Errors: signals `InstrumentError` when the share or the index could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    },

    #' @description
    #' Prints the plan.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the index.
    run = function() {
      index_level <- self$index$last_price
      if (is.null(index_level)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$index$format())
        )
      }
      plan <- OrderPart$new(
        trigger = PriceCrosses$new(
          level = round(index_level * 0.99, 2),
          direction = "at_or_below",
          instrument = self$index
        ),
        side = "close",
        quantity = PositionQuantity$new(
          product = "intraday",
          held_instruments = list(
            self$share
          ),
          ratio = 2
        )
      )
      cat(sprintf("Nifty 50 at %s\n", index_level))
      cat(
        jsonlite::toJSON(
          plan$document(),
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
  ReverseOnIndexFall$new()$run()
}
