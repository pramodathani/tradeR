#' Build an exit that fires on a pullback from the best price or on a hard floor, whichever is reached first.
#'
#' A trailing stop alone gives a winning trade room, but a trade that never rises leaves it far from the entry. The program reads Vodafone Idea's last price and joins a 3% pullback with a hard floor 2% below the market in an `AnyCondition` group. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/any_condition/any_condition/trail_with_a_hard_floor.R

library(tradeR)

#' A pullback condition with a hard floor beside it.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
TrailWithFloor <- R6::R6Class(
  "TrailWithFloor",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `TrailWithFloor` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the floor and the group's object.
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
      floor <- round(last_price * 0.98, 2)
      group <- AnyCondition$new(
        list(
          Trails$new(percent = 3.0),
          PriceCrosses$new(level = floor, direction = "at_or_below")
        )
      )
      cat(
        sprintf(
          "Last price of %s: %s, floor: %s\n",
          self$share$symbol,
          last_price,
          floor
        )
      )
      cat(
        jsonlite::toJSON(
          group$document(),
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
  TrailWithFloor$new()$run()
}
