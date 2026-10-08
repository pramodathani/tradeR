#' Build a ladder of five buy limits under Vodafone Idea's price, where every rung that fills is protected by its own stop.
#'
#' The program reads the share's last price and ladders a buy from 1% to 5% below it. The using join turns each rung into a whole plan, and `each_piece` names the `cover` preset, a then join of the rung and a native stop sized to its fills, so each rung's fills are protected by a stop 2% below the lowest rung. Neither the order nor `each_piece` takes a pricing, because the ladder prices each rung itself. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/using_part/using_part/ladder_rungs_each_with_a_stop.R

library(tradeR)

#' A five-rung buy ladder whose every rung carries its own stop.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field rungs The integer number of rungs.
StoppedLadder <- R6::R6Class(
  "StoppedLadder",
  public = list(
    share = NULL,
    rungs = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `StoppedLadder` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$rungs <- 5
    },

    #' @description
    #' Prints the plan.
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
      lowest_rung <- round(last_price * 0.95, 2)
      stop_price <- round(lowest_rung * 0.98, 2)
      plan <- UsingPart$new(
        order = OrderPart$new(
          quantity = 500,
          execution = LadderExecution$new(
            from_price = round(last_price * 0.99, 2),
            to_price = lowest_rung,
            steps = self$rungs
          )
        ),
        each_piece = OrderPart$new(
          presets = list(
            Preset$new(
              "cover",
              stop_price = stop_price,
              stop_limit_price = round(stop_price - 0.05, 2)
            )
          )
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
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
  StoppedLadder$new()$run()
}
