#' Build a dip entry followed by a stop and a target measured from wherever the entry fills.
#'
#' The program reads Vodafone Idea's last price and builds a Then join: a buy that waits for the price to fall 1%, and on each of its fills an Either join of a stop 2% of the price below the fill and a target 4% above it, which share the position so a fill on one reduces the other. The exits need no absolute prices, because UBI measures them from the entry's average fill. It prints the join's object as UBI would read it. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/from_fill_pricing/from_fill_pricing/stop_and_target_after_a_dip_entry.R

library(tradeR)

#' A dip buy of Vodafone Idea with a stop and a target measured from its fill.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
DipEntryWithExits <- R6::R6Class(
  "DipEntryWithExits",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `DipEntryWithExits` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the join's object.
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
      tick_size <- 0.05
      if (!is.null(self$share$tick_size)) {
        tick_size <- as.numeric(self$share$tick_size)
      }
      stop <- OrderPart$new(
        side = "protect",
        pricing = FromFillPricing$new(
          stop_distance = round(last_price * 0.02, 2),
          stop_limit_offset = tick_size
        )
      )
      target <- OrderPart$new(
        side = "protect",
        pricing = FromFillPricing$new(
          target_distance = round(last_price * 0.04, 2)
        )
      )
      part <- ThenPart$new(
        first = OrderPart$new(
          trigger = PriceCrosses$new(
            level = round(last_price * 0.99, 2)
          )
        ),
        each_fill = EitherPart$new(
          children = list(
            stop,
            target
          ),
          sibling_rule = "reduce"
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
  DipEntryWithExits$new()$run()
}
