#' Build a trailing entry: a buy stop that follows a falling market down and fills on the first rebound.
#'
#' When `TrailPricing` is used on the order's own side rather than `protect`, a buy stop trails the lowest price seen, so the entry is not filled while the price keeps falling and is filled once it rebounds by the trailing distance. The program builds that entry, then protects each fill with a native stop, and prints the plan. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/trail_pricing/trail_pricing/trailing_entry_into_a_falling_market.R

library(tradeR)

#' A trailing buy stop entry followed by a protecting stop.
#'
#' @field rebound_points The numeric rebound in rupees that fills the entry.
TrailingEntry <- R6::R6Class(
  "TrailingEntry",
  public = list(
    rebound_points = NULL,

    #' @description
    #' Sets the rebound distance.
    #' @return A new `TrailingEntry` object.
    initialize = function() {
      self$rebound_points <- 4.0
    },

    #' @description
    #' Prints the plan's object.
    #' @return `NULL`, invisibly.
    run = function() {
      plan <- ThenPart$new(
        first = OrderPart$new(
          pricing = TrailPricing$new(
            points = self$rebound_points,
            limit_offset = 1.0
          )
        ),
        each_fill = OrderPart$new(
          side = "protect",
          pricing = NativeStopPricing$new(
            trigger_price = 950.0,
            limit_price = 948.0
          )
        )
      )
      cat(
        jsonlite::toJSON(
          plan$document(),
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
  TrailingEntry$new()$run()
}
