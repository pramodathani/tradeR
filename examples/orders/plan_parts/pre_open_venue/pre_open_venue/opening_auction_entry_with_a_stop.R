#' Build an entry into Vodafone Idea at the opening auction, protected by a stop once it fills.
#'
#' The first plan of a then join is a market buy sent into the pre-open at UBI's default time of 09:00:30, which is before the 09:05 cut-off for market orders. Its fills are protected by a native stop 3% below the last price read now, placed once the auction has filled the entry and the market opens. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/pre_open_venue/pre_open_venue/opening_auction_entry_with_a_stop.R

library(tradeR)

#' A pre-open market buy followed by a protecting stop.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
AuctionEntryWithStop <- R6::R6Class(
  "AuctionEntryWithStop",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `AuctionEntryWithStop` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the plan.
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
      stop_trigger <- round(last_price * 0.97, 2)
      plan <- ThenPart$new(
        first = OrderPart$new(
          pricing = FixedPricing$new(order_type = "MARKET"),
          venue = PreOpenVenue$new()
        ),
        each_fill = OrderPart$new(
          side = "protect",
          pricing = NativeStopPricing$new(
            trigger_price = stop_trigger,
            limit_price = round(stop_trigger - 0.05, 2)
          )
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
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
  AuctionEntryWithStop$new()$run()
}
