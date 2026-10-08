#' Build an entry that buys a dip in a share only while the Nifty index is still above a floor, and only after ten.
#'
#' A share falling on its own may be a bargain, while a share falling with the whole market usually is not. The program reads Vodafone Idea's and the Nifty index's last prices and joins three conditions in an `AllConditions` group: the time is after 10:00, the share has dipped 1%, and the index is no more than 0.5% below its last price. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/all_conditions/all_conditions/share_dip_while_the_index_holds.R

library(tradeR)

#' An entry on a share's dip, guarded by the time and the index.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field index The `EquityIndex` for the Nifty on the NSE.
DipWhileIndexHolds <- R6::R6Class(
  "DipWhileIndexHolds",
  public = list(
    share = NULL,
    index = NULL,

    #' @description
    #' Looks up the share and the index.
    #' @return A new `DipWhileIndexHolds` object.
    #' @details Errors: signals `InstrumentError` when the share or the index could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    },

    #' @description
    #' Reads an instrument's last price.
    #' @param instrument The `Equity` or `EquityIndex` to read.
    #' @return The numeric last price.
    #' @details Errors: signals `ValueError` when UBI has no last price for the instrument.
    last_price = function(instrument) {
      last_price <- instrument$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", instrument$format())
        )
      }
      last_price
    },

    #' @description
    #' Prints the levels and the entry's object.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share or the index.
    run = function() {
      dip_level <- round(self$last_price(self$share) * 0.99, 2)
      index_floor <- round(self$last_price(self$index) * 0.995, 2)
      part <- OrderPart$new(
        trigger = AllConditions$new(
          list(
            TimeAfter$new("10:00"),
            PriceCrosses$new(
              level = dip_level,
              direction = "at_or_below"
            ),
            PriceCrosses$new(
              level = index_floor,
              direction = "at_or_above",
              instrument = self$index
            )
          )
        )
      )
      cat(
        sprintf(
          "Share dip level: %s, index floor: %s\n",
          dip_level,
          index_floor
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
  DipWhileIndexHolds$new()$run()
}
