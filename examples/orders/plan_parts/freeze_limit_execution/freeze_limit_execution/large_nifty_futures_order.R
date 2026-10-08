#' Build a NIFTY futures order larger than the exchange's freeze quantity, split by UBI at one broker.
#'
#' The program finds the nearest NIFTY futures contract and builds a buy of 40 lots two ticks past the offer with `FreezeLimitExecution`. UBI chooses the broker first, compares the quantity with that broker's published freeze quantity in the broker's own units, and sends equal orders each within it, all at once to that broker; more than 20 slices is refused and a broker that publishes none gets the order whole. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/freeze_limit_execution/freeze_limit_execution/large_nifty_futures_order.R

library(tradeR)

#' A forty-lot NIFTY futures buy split below the freeze quantity.
#'
#' @field contract The `EquityIndexFutures` for the nearest NIFTY future.
LargeFuturesOrder <- R6::R6Class(
  "LargeFuturesOrder",
  public = list(
    contract = NULL,

    #' @description
    #' Finds the nearest contract.
    #' @return A new `LargeFuturesOrder` object.
    #' @details Errors: signals `InstrumentError` when the contract could not be found in UBI.
    initialize = function() {
      expiries <- EquityIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      self$contract <- EquityIndexFutures$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiries[1]
      )
    },

    #' @description
    #' Prints the order's object.
    #' @return `NULL`, invisibly.
    run = function() {
      lot_size <- as.integer(self$contract$lot_size)
      part <- OrderPart$new(
        instrument = self$contract,
        transaction_type = "buy",
        quantity = 40 * lot_size,
        product = "nrml",
        pricing = MarketablePricing$new(buffer_ticks = 2),
        execution = FreezeLimitExecution$new()
      )
      cat(
        sprintf(
          "NIFTY future expiring %s: 40 lots of %d\n",
          format(self$contract$expiry_date),
          lot_size
        )
      )
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
  LargeFuturesOrder$new()$run()
}
