#' Build an entry whose single target is sent only once the whole entry has filled, measured from its average fill.
#'
#' The program builds a Then join for Vodafone Idea with `on_complete`, so the target waits until the buy is done, and prices the target half a rupee above the entry's average fill. The same exit works unchanged after a sale, where UBI places it below the fill instead. It prints the join's object as UBI would read it. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/from_fill_pricing/from_fill_pricing/target_once_the_entry_completes.R

library(tradeR)

#' A buy of Vodafone Idea followed by a target once it has filled completely.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
TargetAfterCompletion <- R6::R6Class(
  "TargetAfterCompletion",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `TargetAfterCompletion` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the join's object.
    #' @return `NULL`, invisibly.
    run = function() {
      part <- ThenPart$new(
        first = OrderPart$new(
          instrument = self$share,
          transaction_type = "buy",
          quantity = 10
        ),
        on_complete = OrderPart$new(
          side = "protect",
          pricing = FromFillPricing$new(target_distance = 0.5)
        )
      )
      cat(
        sprintf(
          "Buy of %s with a target half a rupee up:\n",
          self$share$symbol
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
  TargetAfterCompletion$new()$run()
}
