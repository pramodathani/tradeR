#' Build a stop and a target that share one position, each shrinking as the other fills.
#'
#' The program reads Vodafone Idea's last price and builds an either join with the sibling rule `reduce`: a native stop 3% below the market and a limit target 3% above it, both protecting the same position. If the target fills half the position, the stop is cut to the half that remains. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/either_part/either_part/stop_and_target_on_one_position.R

library(tradeR)

#' A stop and a target sharing one position of Vodafone Idea.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field tick_size The numeric tick size of the share in rupees.
StopAndTarget <- R6::R6Class(
  "StopAndTarget",
  public = list(
    share = NULL,
    tick_size = NULL,

    #' @description
    #' Looks up the share and its tick size.
    #' @return A new `StopAndTarget` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$tick_size <- 0.05
      if (!is.null(self$share$tick_size)) {
        self$tick_size <- as.numeric(self$share$tick_size)
      }
    },

    #' @description
    #' Gives a price a percentage away from the last price, rounded to the tick size.
    #' @param last_price The numeric last price in rupees.
    #' @param percent The numeric percentage to move, negative for a price below the market.
    #' @return The numeric price in rupees.
    price_from_market = function(last_price, percent) {
      ticks <- round(last_price * (1 + percent / 100) / self$tick_size)
      round(ticks * self$tick_size, 2)
    },

    #' @description
    #' Builds the stop and the target as one either join.
    #' @param last_price The numeric last price in rupees the levels are worked out from.
    #' @return The `EitherPart`.
    build_join = function(last_price) {
      stop_price <- self$price_from_market(last_price, -3)
      EitherPart$new(
        children = list(
          OrderPart$new(
            side = "protect",
            pricing = NativeStopPricing$new(
              trigger_price = stop_price,
              limit_price = round(stop_price - self$tick_size, 2)
            )
          ),
          OrderPart$new(
            side = "protect",
            pricing = FixedPricing$new(
              price = self$price_from_market(last_price, 3),
              order_type = "LIMIT"
            )
          )
        ),
        sibling_rule = "reduce"
      )
    },

    #' @description
    #' Prints the last price and the join's object.
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
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(
        jsonlite::toJSON(
          self$build_join(last_price)$document(),
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
  StopAndTarget$new()$run()
}
