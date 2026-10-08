#' Build a TWAP buy of Vodafone Idea in four slices over an hour, where every slice carries its own bracket.
#'
#' The program reads the share's last price and splits a buy with a `TwapExecution`. The using join turns each of the four slices into a whole plan of its own, and `each_piece` names the `bracket` preset, so every slice is followed by a stop 3% below and a target 3% above the price now, sized to that slice's fills. A timed execution in a using join gives `over_minutes`, because UBI spaces the pieces by its interval. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/using_part/using_part/twap_slices_each_with_a_bracket.R

library(tradeR)

#' A TWAP buy whose every slice is bracketed.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
BracketedTwapSlices <- R6::R6Class(
  "BracketedTwapSlices",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `BracketedTwapSlices` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
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
      stop_price <- round(last_price * 0.97, 2)
      plan <- UsingPart$new(
        order = OrderPart$new(
          execution = TwapExecution$new(
            slices = 4,
            over_minutes = 60
          )
        ),
        each_piece = OrderPart$new(
          presets = list(
            Preset$new(
              "bracket",
              stop_price = stop_price,
              stop_limit_price = round(stop_price - 0.05, 2),
              target_price = round(last_price * 1.03, 2)
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
  BracketedTwapSlices$new()$run()
}
