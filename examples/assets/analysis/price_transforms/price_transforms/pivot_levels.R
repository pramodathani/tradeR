#' Work out today's classic pivot levels for NIFTY from the last session's typical price.
#'
#' The program reads the NIFTY 50 index's recent daily candles through `typical_price`, takes the last complete session's typical price as the pivot, and prints the pivot with the first and second resistance and support levels that floor traders derive from it.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/price_transforms/price_transforms/pivot_levels.R

library(tradeR)

#' The classic floor pivot levels of an index.
#'
#' @field index The `EquityIndex` whose levels are worked out.
PivotLevels <- R6::R6Class(
  "PivotLevels",
  public = list(
    index = NULL,

    #' @description
    #' Creates the calculator over the NIFTY 50 index.
    #' @return A new `PivotLevels` object.
    initialize = function() {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    },

    #' @description
    #' Derives the resistance and support levels from a pivot.
    #' @param pivot The numeric typical price of the last session.
    #' @param high The numeric high of the last session.
    #' @param low The numeric low of the last session.
    #' @return A named list mapping the names `R2`, `R1`, `Pivot`, `S1` and `S2` to numeric levels, from the highest to the lowest.
    levels = function(pivot, high, low) {
      list(
        R2 = pivot + (high - low),
        R1 = 2 * pivot - low,
        Pivot = pivot,
        S1 = 2 * pivot - high,
        S2 = pivot - (high - low)
      )
    },

    #' @description
    #' Reads the last session and prints its pivot levels.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      frame <- self$index$typical_price(days = 10)
      if (is.null(frame)) {
        cat("UBI has no NIFTY candles for the range.\n")
        return(invisible(NULL))
      }
      last_session <- frame[nrow(frame), ]
      session_day <- format(last_session$datetime, "%Y-%m-%d")
      cat(sprintf("Pivot levels from the NIFTY session of %s:\n", session_day))
      levels <- self$levels(
        pivot = last_session$typ_price,
        high = last_session$high,
        low = last_session$low
      )
      for (name in names(levels)) {
        cat(sprintf("%-6s %10.2f\n", name, levels[[name]]))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  PivotLevels$new()$run()
}
