#' Print the four price transforms side by side for a share's last trading days.
#'
#' The program reads a month of Infosys daily candles through each of the four methods that `PriceTransforms` gives every instrument, and prints a table of the close, the average price, the median price, the typical price and the weighted close for the last ten days.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/price_transforms/price_transforms/price_transform_table.R

library(tradeR)

#' A table of the four one-number summaries of each candle.
#'
#' @field share The `Equity` whose candles are summarised.
#' @field rows The integer number of most recent days printed.
PriceTransformTable <- R6::R6Class(
  "PriceTransformTable",
  public = list(
    share = NULL,
    rows = NULL,

    #' @description
    #' Creates the table over the Infosys share.
    #' @param rows The integer number of most recent days printed.
    #' @return A new `PriceTransformTable` object.
    initialize = function(rows = 10) {
      self$share <- Equity$new(exchange = "nse", symbol = "INFY")
      self$rows <- rows
    },

    #' @description
    #' Reads the four transforms and prints them for the last days.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      frame <- self$share$average_price(days = 30)
      if (is.null(frame)) {
        cat("UBI has no Infosys candles for the range.\n")
        return(invisible(NULL))
      }
      frame$med_price <- self$share$median_price(days = 30)$med_price
      frame$typ_price <- self$share$typical_price(days = 30)$typ_price
      frame$wght_close <- self$share$weighted_close(days = 30)$wght_close
      columns <- c(
        "datetime",
        "close",
        "avg_price",
        "med_price",
        "typ_price",
        "wght_close"
      )
      table <- tail(frame[columns], self$rows)
      table$datetime <- as.Date(table$datetime, tz = "Asia/Kolkata")
      for (column in columns[-1]) {
        table[[column]] <- round(as.numeric(table[[column]]), 2)
      }
      print(table, row.names = FALSE)
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  PriceTransformTable$new()$run()
}
