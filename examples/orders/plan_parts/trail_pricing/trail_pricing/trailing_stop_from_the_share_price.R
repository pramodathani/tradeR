#' Build a trailing stop for a share sized from its price, in rupees and as a percentage, with a step that limits modifications.
#'
#' The program reads Vodafone Idea's last price and builds two `TrailPricing` rules 2% behind the market, one in rupees and one as a percentage, the second moving only in steps of three ticks so the broker sees fewer modifications. It prints both on a protecting order. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/trail_pricing/trail_pricing/trailing_stop_from_the_share_price.R

library(tradeR)

#' Two trailing stops for Vodafone Idea, 2% behind the market.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
ShareTrailingStop <- R6::R6Class(
  "ShareTrailingStop",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `ShareTrailingStop` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints both protecting orders' objects.
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
      tick_size <- 0.05
      if (!is.null(self$share$tick_size)) {
        tick_size <- as.numeric(self$share$tick_size)
      }
      points <- round(last_price * 0.02, 2)
      rules <- list(
        "in rupees" = TrailPricing$new(
          points = points,
          limit_offset = tick_size
        ),
        "as a percentage, in steps of three ticks" = TrailPricing$new(
          percent = 2.0,
          limit_offset = tick_size,
          step_ticks = 3
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      for (description in names(rules)) {
        rule <- rules[[description]]
        part <- OrderPart$new(side = "protect", pricing = rule)
        cat(sprintf("Trailing %s:\n", description))
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
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ShareTrailingStop$new()$run()
}
