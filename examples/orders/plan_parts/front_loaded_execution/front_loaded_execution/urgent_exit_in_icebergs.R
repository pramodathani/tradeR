#' Build an urgent exit from a Vodafone Idea position that trades most of it early without showing its size.
#'
#' The program builds a protecting sell for 4000 shares that starts when the price falls through 95% of the last price, sent front-loaded at an urgency of 0.8 over twenty minutes with each slice shown as an iceberg of 300. This is a nested execution: `FrontLoadedExecution` is the outer one and `IcebergExecution` the inner one. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/front_loaded_execution/front_loaded_execution/urgent_exit_in_icebergs.R

library(tradeR)

#' A front-loaded exit of icebergs from a Vodafone Idea position.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
UrgentIcebergExit <- R6::R6Class(
  "UrgentIcebergExit",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `UrgentIcebergExit` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the exit's object.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    run = function() {
      last_price <- self$share$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$share$format())
        )
      }
      level <- round(last_price * 0.95, 2)
      part <- OrderPart$new(
        side = "protect",
        quantity = 4000,
        trigger = PriceCrosses$new(level = level, direction = "at_or_below"),
        pricing = MarketablePricing$new(buffer_ticks = 2),
        execution = FrontLoadedExecution$new(
          slices = 5,
          over_minutes = 20,
          urgency = 0.8
        ),
        inner_execution = IcebergExecution$new(
          visible_quantity = 300
        )
      )
      cat(
        sprintf(
          "Last price of %s: %s; the exit starts below %s\n",
          self$share$symbol,
          last_price,
          level
        )
      )
      cat(
        jsonlite::toJSON(
          part$document(),
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
  UrgentIcebergExit$new()$run()
}
