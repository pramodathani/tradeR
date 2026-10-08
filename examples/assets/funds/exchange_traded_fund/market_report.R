#' Print a short market report on the NIFTYBEES exchange traded fund.
#'
#' The program reads the fund's live values, a year of daily candles and its fourteen-day relative strength index, and says whether this account holds any units. It places no order.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/funds/exchange_traded_fund/market_report.R

library(tradeR)

#' A one-screen report on one exchange traded fund.
#'
#' @field fund The `ExchangeTradedFund` the report describes.
MarketReport <- R6::R6Class(
  "MarketReport",
  public = list(
    fund = NULL,

    #' @description
    #' Looks NIFTYBEES up in UBI.
    #' @return A new `MarketReport` object.
    #' @details Errors: signals `ExchangeTradedFundError` when UBI has no such fund, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    initialize = function() {
      self$fund <- ExchangeTradedFund$new(
        exchange = "nse",
        symbol = "NIFTYBEES"
      )
    },

    #' @description
    #' Prints the fund's identity, live values, year range, momentum and holding.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      print(self$fund)
      cat(
        sprintf(
          "Tick size %s, lot size %s\n",
          private$display_text(self$fund$tick_size),
          private$display_text(self$fund$lot_size)
        )
      )
      private$print_live_values()
      private$print_year_range()
      private$print_momentum()
      private$print_holding()
      invisible(NULL)
    }
  ),
  private = list(
    # Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one and one line of JSON for a named list.
    # @param value The value to print, or `NULL`.
    # @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      if (is.list(value)) {
        return(jsonlite::toJSON(value, auto_unbox = TRUE, null = "null"))
      }
      as.character(value)
    },

    # Prints the last price and the day's open, high and low.
    # @return `NULL`, invisibly.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    print_live_values = function() {
      quote <- self$fund$ohlc
      day <- quote[["ohlc"]]
      cat(sprintf("Last price: %s\n", quote[["last_price"]]))
      cat(sprintf("Previous close: %s\n", quote[["previous_close"]]))
      cat(
        sprintf(
          "Today: open %s, high %s, low %s\n",
          day[["open"]],
          day[["high"]],
          day[["low"]]
        )
      )
      invisible(NULL)
    },

    # Prints the highest and lowest close of the last year and the year's return.
    # @return `NULL`, invisibly.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    print_year_range = function() {
      candles <- self$fund$prices(days = 365)
      if (is.null(candles)) {
        cat("UBI has no candles for the last year.\n")
        return(invisible(NULL))
      }
      first_close <- candles$close[[1]]
      last_close <- candles$close[[nrow(candles)]]
      year_return <- (last_close / first_close - 1) * 100
      cat(sprintf("Year's closes: %d\n", nrow(candles)))
      cat(
        sprintf(
          "Highest close %s, lowest %s\n",
          max(candles$close),
          min(candles$close)
        )
      )
      cat(sprintf("Return over the period: %.2f per cent\n", year_return))
      invisible(NULL)
    },

    # Prints the latest fourteen-day relative strength index.
    # @return `NULL`, invisibly.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    print_momentum = function() {
      frame <- self$fund$relative_strength_index(window = 14, days = 90)
      if (is.null(frame)) {
        cat("UBI has no candles to work the index out from.\n")
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "Relative strength index: %.1f\n",
          frame$rsi_14[[nrow(frame)]]
        )
      )
      invisible(NULL)
    },

    # Prints the units of the fund this account holds, if any.
    # @return `NULL`, invisibly.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    print_holding = function() {
      row <- self$fund$holdings
      if (is.null(row)) {
        cat("This account holds no NIFTYBEES units.\n")
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "Held: %s units worth %s\n",
          row[["quantity"]],
          private$display_text(self$fund$holdings_value)
        )
      )
      cat(
        sprintf(
          "Profit or loss: %s\n",
          private$display_text(self$fund$holdings_pnl)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MarketReport$new()$run()
}
