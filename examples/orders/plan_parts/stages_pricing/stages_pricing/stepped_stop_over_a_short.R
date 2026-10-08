#' Build a stepped stop over a short position, whose gains are measured downwards from the entry.
#'
#' The program reads Vodafone Idea's last price and builds a protecting stop for a position opened by a sale at that price: it starts 2% above, moves to breakeven once the price has fallen 2%, and to a 2% gain once it has fallen 4%, moving only in steps of two ticks. Because gains are measured in the position's favour, the same positive numbers serve a short as a long. It prints the order object UBI would read. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/stages_pricing/stages_pricing/stepped_stop_over_a_short.R

library(tradeR)

#' A stepped buy stop protecting a short position in Vodafone Idea.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
ShortSteppedStop <- R6::R6Class(
  "ShortSteppedStop",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `ShortSteppedStop` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the protecting order's object.
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
      two_percent <- round(last_price * 0.02, 2)
      stop <- StagesPricing$new(
        entry_price = last_price,
        stop_price = round(last_price + two_percent, 2),
        limit_offset = 0.05,
        rules = list(
          StageRule$new(gain = two_percent, stop_at_gain = 0.0),
          StageRule$new(
            gain = round(two_percent * 2, 2),
            stop_at_gain = two_percent
          )
        ),
        step_ticks = 2
      )
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "buy",
        quantity = 1,
        pricing = stop
      )
      cat(sprintf("Short entered at %s, stop starts above it:\n", last_price))
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
  ShortSteppedStop$new()$run()
}
