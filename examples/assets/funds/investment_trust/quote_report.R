#' Print a short market report on the EMBASSY real estate investment trust.
#'
#' The program reads the trust's live quote and day range, confirms that UBI stores no candles for a trust, and says whether this account holds any units. It places no order.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/funds/investment_trust/quote_report.R

library(tradeR)

#' A one-screen report on one listed investment trust.
#'
#' @field trust The `InvestmentTrust` the report describes.
QuoteReport <- R6::R6Class(
  "QuoteReport",
  public = list(
    trust = NULL,

    #' @description
    #' Looks EMBASSY up in UBI.
    #' @return A new `QuoteReport` object.
    #' @details Errors: signals `InvestmentTrustError` when UBI has no such trust, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    initialize = function() {
      self$trust <- InvestmentTrust$new(exchange = "nse", symbol = "EMBASSY")
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
    #' Prints the trust's identity, live values, candles and holding.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      print(self$trust)
      cat(
        sprintf(
          "Tick size %s, lot size %s\n",
          self$display_text(self$trust$tick_size),
          self$display_text(self$trust$lot_size)
        )
      )
      quote <- self$trust$ohlc
      day <- quote[["ohlc"]]
      change <- (quote[["last_price"]] / quote[["previous_close"]] - 1) * 100
      cat(
        sprintf(
          "Last price %s, %.2f per cent today\n",
          quote[["last_price"]],
          change
        )
      )
      cat(
        sprintf(
          "Today: open %s, high %s, low %s\n",
          day[["open"]],
          day[["high"]],
          day[["low"]]
        )
      )
      candles <- self$trust$prices(days = 30)
      if (is.null(candles)) {
        cat("UBI stores no candles for a trust, so prices returned NULL.\n")
      } else {
        cat(sprintf("UBI returned %d candles.\n", nrow(candles)))
      }
      row <- self$trust$holdings
      if (is.null(row)) {
        cat("This account holds no EMBASSY units.\n")
      } else {
        cat(
          sprintf(
            "Held: %s units worth %s\n",
            row[["quantity"]],
            self$display_text(self$trust$holdings_value)
          )
        )
        cat(
          sprintf(
            "Profit or loss: %s\n",
            self$display_text(self$trust$holdings_pnl)
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  QuoteReport$new()$run()
}
