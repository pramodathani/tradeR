#' Ask for a RELIANCE future through the IndexFutures class and handle the IndexFuturesError.
#'
#' IndexFutures accepts only a future on an index. The program looks a RELIANCE share future up through it, catches IndexFuturesError, and builds the same contract through the general Futures class instead.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/index_futures_error/ask_for_a_share_future_as_an_index_future.R

library(tradeR)

#' A lookup of a share future through the IndexFutures class.
#'
#' @field exchange The character exchange the future trades on.
#' @field segment The character UBI segment of share futures.
#' @field underlying_symbol The character symbol of the share.
ShareFutureAsIndexFuture <- R6::R6Class(
  "ShareFutureAsIndexFuture",
  public = list(
    exchange = NULL,
    segment = NULL,
    underlying_symbol = NULL,

    #' @description
    #' Creates the lookup for a RELIANCE future.
    #' @return A new `ShareFutureAsIndexFuture` object.
    initialize = function() {
      self$exchange <- "nse"
      self$segment <- "equity_futures"
      self$underlying_symbol <- "RELIANCE"
    },

    #' @description
    #' Looks the future up as an index future, catches the error and builds it as a plain future.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `InstrumentError` when UBI does not know the future; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      listed_expiries <- EquityFutures$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )
      expiry_date <- listed_expiries[length(listed_expiries)]
      contract <- tryCatch(
        IndexFutures$new(
          exchange = self$exchange,
          segment = self$segment,
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date
        ),
        IndexFuturesError = function(error) {
          cat(sprintf("IndexFuturesError: %s\n", conditionMessage(error)))
          Futures$new(
            exchange = self$exchange,
            segment = self$segment,
            underlying_symbol = self$underlying_symbol,
            expiry_date = expiry_date
          )
        }
      )
      cat(sprintf("Built %s\n", contract$format()))
      cat(
        sprintf(
          "Lot size: %s, expiring in %s days\n",
          format(contract$lot_size),
          format(contract$days_to_expiry)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ShareFutureAsIndexFuture$new()$run()
}
