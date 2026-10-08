#' Build a large buy of Vodafone Idea sent as TWAP slices, each shown as an iceberg.
#'
#' The program reads Vodafone Idea's last price and builds an order for 6000 shares, limited one percent above that price, sent as six TWAP slices over an hour with each slice of 1000 shown 250 at a time and varied by up to a tenth. This is a nested execution: the `TwapExecution` passed as `execution` splits the order into slices, and the `IcebergExecution` passed as `inner_execution` works each slice. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/iceberg_execution/iceberg_execution/twap_slices_shown_as_icebergs.R

library(tradeR)

#' A buy of Vodafone Idea worked as TWAP slices, each slice an iceberg.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
TwapOfIcebergs <- R6::R6Class(
  "TwapOfIcebergs",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `TwapOfIcebergs` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the order's object.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    run = function() {
      last_price <- self$share$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$share$format())
        )
      }
      limit_price <- round(last_price * 1.01, 2)
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "buy",
        quantity = 6000,
        product = "cnc",
        pricing = FixedPricing$new(
          price = limit_price,
          order_type = "LIMIT"
        ),
        execution = TwapExecution$new(
          slices = 6,
          over_minutes = 60
        ),
        inner_execution = IcebergExecution$new(
          visible_quantity = 250,
          randomise_percent = 10
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(
        jsonlite::toJSON(
          part$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TwapOfIcebergs$new()$run()
}
