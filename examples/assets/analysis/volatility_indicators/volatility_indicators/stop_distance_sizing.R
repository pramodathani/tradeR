#' Size a hypothetical position so that a stop two average true ranges away risks a fixed amount.
#'
#' The program reads each share's 14-day average true range, sets a stop two average true ranges below the latest close, rounded to the share's 0.01 rupee tick, and works out how many shares a trader could buy so that being stopped out loses no more than the chosen amount. It only calculates and places no orders.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/volatility_indicators/volatility_indicators/stop_distance_sizing.R

library(tradeR)

#' A position size calculator driven by the average true range.
#'
#' @field symbols A character vector of NSE symbols of the shares that are sized.
#' @field risk_amount The numeric rupees the trader accepts losing if the stop is hit.
#' @field multiple The numeric number of average true ranges between the close and the stop.
StopDistanceSizing <- R6::R6Class(
  "StopDistanceSizing",
  public = list(
    symbols = NULL,
    risk_amount = NULL,
    multiple = NULL,

    #' @description
    #' Creates the calculator over three NSE shares.
    #' @param risk_amount The numeric rupees the trader accepts losing if the stop is hit.
    #' @param multiple The numeric number of average true ranges between the close and the stop.
    #' @return A new `StopDistanceSizing` object.
    initialize = function(risk_amount = 5000.0, multiple = 2.0) {
      self$symbols <- c(
        "IDEA",
        "INFY",
        "RELIANCE"
      )
      self$risk_amount <- risk_amount
      self$multiple <- multiple
    },

    #' @description
    #' Works out the stop and the position size for one share.
    #' @param symbol The character NSE symbol of the share.
    #' @return A character line with the close, the average true range, the stop level and the number of shares.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    size = function(symbol) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      frame <- share$average_true_range(window = 14, days = 90)
      if (is.null(frame)) {
        return(sprintf("%s: no candles", symbol))
      }
      close <- tail(frame$close, 1)
      average_true_range <- tail(frame$atr_14, 1)
      stop_level <- round(close - self$multiple * average_true_range, 2)
      risk_per_share <- close - stop_level
      quantity <- floor(self$risk_amount / risk_per_share)
      sprintf(
        "%-10s close %9.2f  ATR %7.2f  stop %9.2f  buy %.0f shares",
        symbol,
        close,
        average_true_range,
        stop_level,
        quantity
      )
    },

    #' @description
    #' Prints the stop and the position size for every share.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat(
        sprintf(
          "Risking Rs %.0f with a stop %s ATRs below the close:\n",
          self$risk_amount,
          format(self$multiple, nsmall = 1)
        )
      )
      for (symbol in self$symbols) {
        cat(self$size(symbol), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  StopDistanceSizing$new()$run()
}
