#' Print a short market report on one listed share.
#'
#' The program looks Vodafone Idea up on the nse, reads its live quote and order book, works out a few measures from a year of daily candles, and says whether the account holds any of it.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity/market_report.R

library(tradeR)

#' A market report on one share listed on the nse.
#'
#' @field share The `Equity` the report describes.
ShareMarketReport <- R6::R6Class(
  "ShareMarketReport",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up in UBI.
    #' @param symbol The character nse symbol of the share, such as `"IDEA"`.
    #' @return A new `ShareMarketReport` object.
    #' @details Errors: signals `EquityError` when UBI has no nse share with that symbol.
    initialize = function(symbol = "IDEA") {
      self$share <- Equity$new(exchange = "nse", symbol = symbol)
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one and one line of JSON for a named list.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      if (is.list(value)) {
        return(jsonlite::toJSON(value, auto_unbox = TRUE, null = "null"))
      }
      as.character(value)
    },

    #' @description
    #' Prints the live prices, the yearly measures and the holding.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      share <- self$share
      cat(sprintf("%s on the %s\n", share$symbol, share$exchange))
      cat(sprintf("Tick size: %s\n", self$display_text(share$tick_size)))
      cat(sprintf("Last price: %s\n", self$display_text(share$last_price)))
      cat(sprintf("Best bid: %s\n", self$display_text(share$best_bid)))
      cat(sprintf("Best offer: %s\n", self$display_text(share$best_offer)))
      cat(sprintf("Spread: %s\n", self$display_text(share$bid_offer_spread)))
      cat(
        sprintf(
          "Volume today: %s\n",
          self$display_text(share$total_traded_volume)
        )
      )
      private$print_yearly_measures()
      private$print_holding()
      invisible(NULL)
    }
  ),
  private = list(
    # Prints the latest relative strength index and the year's volatility and drawdown.
    # @return `NULL`, invisibly.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    print_yearly_measures = function() {
      strength_frame <- self$share$relative_strength_index(
        window = 14,
        days = 365
      )
      if (is.null(strength_frame)) {
        cat("UBI has no candles for the last year.\n")
        return(invisible(NULL))
      }
      latest_strength <- strength_frame$rsi_14[[nrow(strength_frame)]]
      cat(
        sprintf(
          "Relative strength index (14 days): %.1f\n",
          latest_strength
        )
      )
      volatility <- self$share$annualised_volatility(days = 365)
      cat(sprintf("Annualised volatility: %.1f%%\n", volatility * 100))
      drawdown <- self$share$maximum_drawdown(days = 365)
      cat(
        sprintf("Maximum drawdown over the year: %.1f%%\n", drawdown * 100)
      )
      invisible(NULL)
    },

    # Prints the holding of the share, or says that none is held.
    # @return `NULL`, invisibly.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    print_holding = function() {
      holding <- self$share$holdings
      if (is.null(holding)) {
        cat("The account holds none of this share.\n")
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "Held: %s at %s\n",
          holding[["quantity"]],
          holding[["average_price"]]
        )
      )
      cat(
        sprintf(
          "Holding value: %s\n",
          self$display_text(self$share$holdings_value)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ShareMarketReport$new()$run()
}
