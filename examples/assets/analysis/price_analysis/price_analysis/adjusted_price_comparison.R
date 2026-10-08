#' Compare a share's adjusted and unadjusted daily closes.
#'
#' The program reads five years of Reliance Industries' daily candles twice, once adjusted for splits and bonuses and once as traded, and prints the first close of each series and the number of days on which the two differ, which shows whether a corporate action fell inside the range.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/price_analysis/price_analysis/adjusted_price_comparison.R

library(tradeR)

#' A comparison of one share's adjusted and unadjusted closes.
#'
#' @field share The `Equity` whose candles are compared.
#' @field days The integer number of days to count back from today.
AdjustedPriceComparison <- R6::R6Class(
  "AdjustedPriceComparison",
  public = list(
    share = NULL,
    days = NULL,

    #' @description
    #' Creates the comparison for one NSE share.
    #' @param symbol The character NSE symbol of the share.
    #' @param days The integer number of days to count back from today.
    #' @return A new `AdjustedPriceComparison` object.
    #' @details Errors: signals `InstrumentError` when UBI does not know the share.
    initialize = function(symbol = "RELIANCE", days = 1825) {
      self$share <- Equity$new(exchange = "nse", symbol = symbol)
      self$days <- days
    },

    #' @description
    #' Counts the days on which the two closes differ by more than a paisa.
    #' @param adjusted_closes A numeric vector of closes adjusted for corporate actions.
    #' @param traded_closes A numeric vector of closes as traded, the same length as `adjusted_closes`.
    #' @return The integer number of days whose two closes differ.
    count_differences = function(adjusted_closes, traded_closes) {
      differences <- 0L
      for (index in seq_along(adjusted_closes)) {
        gap <- abs(adjusted_closes[index] - traded_closes[index])
        if (isTRUE(gap > 0.01)) {
          differences <- differences + 1L
        }
      }
      differences
    },

    #' @description
    #' Reads both series and prints how they compare.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      adjusted <- self$share$prices(days = self$days, adjusted = TRUE)
      traded <- self$share$prices(days = self$days, adjusted = FALSE)
      if (is.null(adjusted) || is.null(traded)) {
        cat(sprintf("UBI has no candles for %s.\n", self$share$symbol))
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "%s: %d adjusted candles, %d traded candles\n",
          self$share$symbol,
          nrow(adjusted),
          nrow(traded)
        )
      )
      cat(sprintf("First adjusted close: %.2f\n", adjusted$close[1]))
      cat(sprintf("First traded close: %.2f\n", traded$close[1]))
      if (nrow(adjusted) != nrow(traded)) {
        cat(
          "The two series have different lengths, so they are not compared day by day.\n"
        )
        return(invisible(NULL))
      }
      differences <- self$count_differences(adjusted$close, traded$close)
      cat(sprintf("Days whose closes differ: %d\n", differences))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  AdjustedPriceComparison$new()$run()
}
