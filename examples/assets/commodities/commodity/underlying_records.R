#' Show what a commodity row in UBI is, and why it has no price of its own.
#'
#' A commodity such as GOLD on the mcx is the exchange's reference record for an underlying rather than something that trades. The program builds it, prints its identity and the brokers that map it, and then shows that it has no quote and no candles, catching the `ServiceUnavailableError` the quote signals.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity/underlying_records.R

library(tradeR)

#' A report on one commodity's reference record.
#'
#' @field commodity The `Commodity` the report describes.
CommodityRecordReport <- R6::R6Class(
  "CommodityRecordReport",
  public = list(
    commodity = NULL,

    #' @description
    #' Looks the commodity up in UBI.
    #' @param exchange The character exchange that publishes the commodity, `"mcx"`, `"ncdex"` or `"nse"`.
    #' @param symbol The character symbol of the commodity, such as `"GOLD"`.
    #' @return A new `CommodityRecordReport` object.
    #' @details Errors: signals `CommodityError` when UBI has no such commodity.
    initialize = function(exchange = "mcx", symbol = "GOLD") {
      self$commodity <- Commodity$new(exchange = exchange, symbol = symbol)
    },

    #' @description
    #' Prints the record and shows the missing quote and candles.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      commodity <- self$commodity
      cat(sprintf("%s on the %s\n", commodity$symbol, commodity$exchange))
      cat(
        sprintf(
          "Segment: %s, shape: %s\n",
          commodity$segment,
          commodity$shape
        )
      )
      cat(sprintf("Instrument id: %s\n", commodity$instrument_id))
      for (mapping in commodity$carried_by) {
        cat(
          sprintf(
            "Mapped by %s as %s\n",
            mapping[["broker"]],
            mapping[["broker_token"]]
          )
        )
      }
      tryCatch(
        {
          last_price <- commodity$last_price
          if (is.null(last_price)) {
            last_price <- "NULL"
          }
          cat(sprintf("Last price: %s\n", last_price))
        },
        ServiceUnavailableError = function(error) {
          cat(sprintf("No quote: %s\n", conditionMessage(error)))
        }
      )
      cat("Candles for the last month: ")
      print(commodity$prices(days = 30))
      cat("Trade it through CommodityFutures or CommodityOption instead.\n")
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CommodityRecordReport$new()$run()
}
