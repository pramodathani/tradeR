#' Build a participation order for the nearest NIFTY future and show how UBI rounds its slices down to whole lots.
#'
#' The program finds the nearest NIFTY futures contract, reads its lot size, and builds an order for ten lots that takes 5% of the traded volume with at most thirty slices. Since UBI's fix of 2026-10-02, each slice is cut down to whole lots and a share under one lot waits for more volume, so the program prints what a few volumes would send. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/participation_execution/participation_execution/nifty_futures_in_whole_lots.R

library(tradeR)

#' A participation buy of ten lots of the nearest NIFTY future.
#'
#' @field contract The `EquityIndexFutures` for the nearest NIFTY future.
#' @field execution The `ParticipationExecution` the order is sent with.
NiftyFuturesParticipation <- R6::R6Class(
  "NiftyFuturesParticipation",
  public = list(
    contract = NULL,
    execution = NULL,

    #' @description
    #' Finds the nearest contract and builds the execution.
    #' @return A new `NiftyFuturesParticipation` object.
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
      self$execution <- ParticipationExecution$new(
        percent = 5.0,
        most_slices = 30
      )
    },

    #' @description
    #' Prints the order's object and the slices a few volumes would send.
    #' @return `NULL`, invisibly.
    run = function() {
      lot_size <- as.integer(self$contract$lot_size)
      part <- OrderPart$new(
        instrument = self$contract,
        transaction_type = "buy",
        quantity = 10 * lot_size,
        product = "nrml",
        pricing = MarketablePricing$new(buffer_ticks = 2),
        execution = self$execution
      )
      cat(
        sprintf(
          "Lot size of the NIFTY future expiring %s: %d\n",
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
      traded_volumes <- c(
        1000,
        2600,
        5000
      )
      for (traded_volume in traded_volumes) {
        share <- traded_volume * self$execution$percent / 100
        whole_share <- as.integer(share)
        whole_lots <- whole_share - whole_share %% lot_size
        cat(
          sprintf(
            "%d traded gives a share of %.0f, sent as %d\n",
            as.integer(traded_volume),
            share,
            whole_lots
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  NiftyFuturesParticipation$new()$run()
}
