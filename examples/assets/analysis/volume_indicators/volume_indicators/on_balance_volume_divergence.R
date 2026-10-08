#' Look for divergence between price and on balance volume in a few shares.
#'
#' The program reads two months of daily candles for each share, compares the change in its close with the change in its on balance volume over the last twenty sessions, and says whether volume confirms the price move or diverges from it.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/volume_indicators/volume_indicators/on_balance_volume_divergence.R

library(tradeR)

#' A check of whether volume agrees with each share's recent price move.
#'
#' @field shares A list of `Equity` objects to check.
#' @field sessions The integer number of sessions the change is measured over.
OnBalanceVolumeDivergence <- R6::R6Class(
  "OnBalanceVolumeDivergence",
  public = list(
    shares = NULL,
    sessions = NULL,

    #' @description
    #' Creates the check over five NSE shares.
    #' @param sessions The integer number of sessions the change is measured over.
    #' @return A new `OnBalanceVolumeDivergence` object.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the shares.
    initialize = function(sessions = 20) {
      symbols <- c(
        "RELIANCE",
        "INFY",
        "HDFCBANK",
        "TCS",
        "IDEA"
      )
      self$shares <- list()
      for (symbol in symbols) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        self$shares[[length(self$shares) + 1]] <- share
      }
      self$sessions <- sessions
    },

    #' @description
    #' Names the relationship between the two changes.
    #' @param price_change The numeric change in the close.
    #' @param volume_change The numeric change in the on balance volume.
    #' @return The character verdict, `confirms` when both moved the same way and `diverges` otherwise.
    verdict = function(price_change, volume_change) {
      if (price_change > 0 && volume_change > 0) {
        return("confirms")
      }
      if (price_change < 0 && volume_change < 0) {
        return("confirms")
      }
      "diverges"
    },

    #' @description
    #' Prints each share's price change, volume change and verdict.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      for (share in self$shares) {
        candles <- share$on_balance_volume(days = 60)
        if (is.null(candles) || nrow(candles) <= self$sessions) {
          cat(sprintf("%s: not enough candles\n", share$symbol))
          next
        }
        last <- nrow(candles)
        start <- last - self$sessions
        price_change <- candles$close[[last]] - candles$close[[start]]
        volume_change <- candles$obv[[last]] - candles$obv[[start]]
        percent <- price_change / candles$close[[start]] * 100
        volume_text <- formatC(
          volume_change,
          format = "f",
          digits = 0,
          big.mark = ",",
          flag = "+"
        )
        cat(
          sprintf(
            "%-10s price %+6.2f%%  on balance volume %s  volume %s the move\n",
            share$symbol,
            percent,
            volume_text,
            self$verdict(price_change, volume_change)
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OnBalanceVolumeDivergence$new()$run()
}
