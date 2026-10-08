#' Show the whole-rupee levels around each share's close and the size of its price.
#'
#' The program reads a month of daily candles for several NSE shares through `floor`, `ceiling`, `logarithm_base_10` and `square_root`, and prints for each share the whole rupees its latest close sits between, how many digits its price has, and the square root of the close, which some traders use to space round-number levels.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/math_transforms/math_transforms/whole_rupee_levels.R

library(tradeR)

#' A table of the round-number levels around each share's close.
#'
#' @field symbols A character vector of the NSE symbols of the shares that are described.
#' @field days The integer number of days of daily candles to read.
WholeRupeeLevels <- R6::R6Class(
  "WholeRupeeLevels",
  public = list(
    symbols = NULL,
    days = NULL,

    #' @description
    #' Creates the table over four NSE shares.
    #' @param days The integer number of days of daily candles to read.
    #' @return A new `WholeRupeeLevels` object.
    initialize = function(days = 30) {
      self$symbols <- c(
        "IDEA",
        "ITC",
        "INFY",
        "RELIANCE"
      )
      self$days <- days
    },

    #' @description
    #' Describes the levels around one share's latest close.
    #' @param symbol The character NSE symbol of the share.
    #' @return A character line with the close, the whole rupees around it, the digit count and the square root.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    describe = function(symbol) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      floor_frame <- share$floor(days = self$days)
      if (is.null(floor_frame)) {
        return(sprintf("%-10s no candles", symbol))
      }
      last_row <- nrow(floor_frame)
      close <- floor_frame$close[last_row]
      below <- floor_frame$floor[last_row]
      ceiling_frame <- share$ceiling(days = self$days)
      above <- ceiling_frame$ceil[nrow(ceiling_frame)]
      logarithm_frame <- share$logarithm_base_10(days = self$days)
      logarithm <- logarithm_frame$log10[nrow(logarithm_frame)]
      root_frame <- share$square_root(days = self$days)
      root <- root_frame$sqrt[nrow(root_frame)]
      digits <- as.integer(floor(logarithm) + 1)
      sprintf(
        "%-10s %10.2f %8.0f %8.0f %7d %8.2f",
        symbol,
        close,
        below,
        above,
        digits,
        root
      )
    },

    #' @description
    #' Prints a header and one line per share.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat(
        sprintf(
          "%-10s %10s %8s %8s %7s %8s\n",
          "Symbol",
          "Close",
          "Floor",
          "Ceiling",
          "Digits",
          "Root"
        )
      )
      for (symbol in self$symbols) {
        cat(self$describe(symbol), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  WholeRupeeLevels$new()$run()
}
