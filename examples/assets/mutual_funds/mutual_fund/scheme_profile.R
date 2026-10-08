#' Print what UBI can and cannot say about one mutual fund scheme.
#'
#' The program builds the ABSLFTTIDG scheme and prints its identity, then tries each kind of market data in turn: the live price, which signals `ServiceUnavailableError` because no broker that serves quotes carries mutual funds, the candles, which are `NULL` because UBI stores none, and the Sharpe ratio, which is `NULL` for the same reason. It ends with this account's holding of the scheme, which is what a mutual fund in UBI is for. It places no order.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/mutual_funds/mutual_fund/scheme_profile.R

library(tradeR)

#' A profile of one mutual fund scheme.
#'
#' @field fund The `MutualFund` the profile describes.
SchemeProfile <- R6::R6Class(
  "SchemeProfile",
  public = list(
    fund = NULL,

    #' @description
    #' Looks ABSLFTTIDG up in UBI.
    #' @return A new `SchemeProfile` object.
    #' @details Errors: signals `MutualFundError` when UBI has no such scheme, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    initialize = function() {
      self$fund <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
    },

    #' @description
    #' Prints the identity, the market data checks and the holding.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat(self$fund$format(), "\n", sep = "")
      cat(sprintf("Instrument id: %s\n", self$fund$instrument_id))
      cat(sprintf("Segment: %s\n", self$fund$segment))
      cat(sprintf(
        "Lot size %s, tick size %s\n",
        private$text(self$fund$lot_size),
        private$text(self$fund$tick_size)
      ))
      cat(sprintf(
        "Carried by: %s\n",
        jsonlite::toJSON(self$fund$carried_by, auto_unbox = TRUE, null = "null")
      ))
      cat(sprintf(
        "First seen %s, last seen %s\n",
        private$text(self$fund$first_seen_date),
        private$text(self$fund$last_seen_date)
      ))
      private$print_live_price()
      candles <- self$fund$prices(days = 30)
      cat("Candles for the last thirty days:\n")
      print(candles)
      cat(sprintf(
        "Sharpe ratio over a year: %s\n",
        private$text(self$fund$sharpe_ratio(days = 365))
      ))
      private$print_holding()
      invisible(NULL)
    }
  ),
  private = list(
    #' @description
    #' Writes one value as text, giving `"NULL"` for a missing value.
    #' @param value A single value of any type, or `NULL`.
    #' @return A character value.
    text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      format(value)
    },

    #' @description
    #' Tries to read the scheme's last price and reports why there is none.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI failed in a way other than having no quote.
    print_live_price = function() {
      tryCatch(
        cat(sprintf("Last price: %s\n", private$text(self$fund$last_price))),
        ServiceUnavailableError = function(error) {
          cat(sprintf(
            "No live price, as expected for a mutual fund: %s\n",
            conditionMessage(error)
          ))
        }
      )
      invisible(NULL)
    },

    #' @description
    #' Prints this account's holding of the scheme, if any.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    print_holding = function() {
      row <- self$fund$holdings
      if (is.null(row)) {
        cat("This account holds no units of the scheme.\n")
        return(invisible(NULL))
      }
      cat(sprintf(
        "Held: %s units at an average of %s\n",
        private$text(row[["quantity"]]),
        private$text(row[["average_price"]])
      ))
      cat(sprintf(
        "Worth %s, profit or loss %s\n",
        private$text(self$fund$holdings_value),
        jsonlite::toJSON(
          self$fund$holdings_pnl,
          auto_unbox = TRUE,
          null = "null"
        )
      ))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SchemeProfile$new()$run()
}
