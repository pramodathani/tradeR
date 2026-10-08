#' Build a scale-in: three buys of Vodafone Idea at successively lower levels, each considered only once the one before is done.
#'
#' The program reads the share's last price and builds three buys waiting for dips of 1%, 2% and 3%. In a sequence join the second buy does not start watching until the first is done, so a single sharp fall fills one buy at a time rather than all three at once. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/sequence_part/sequence_part/scale_in_on_three_dips.R

library(tradeR)

#' Three dip buys run one after another.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field dip_percents The numeric vector of percentages below the last price each buy waits for.
ThreeStepScaleIn <- R6::R6Class(
  "ThreeStepScaleIn",
  public = list(
    share = NULL,
    dip_percents = NULL,

    #' @description
    #' Looks the share up and sets the dips.
    #' @return A new `ThreeStepScaleIn` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$dip_percents <- c(
        1.0,
        2.0,
        3.0
      )
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
      buys <- list()
      for (dip_percent in self$dip_percents) {
        level <- round(last_price * (1 - dip_percent / 100), 2)
        buys[[length(buys) + 1]] <- OrderPart$new(
          trigger = PriceCrosses$new(level = level),
          pricing = MarketablePricing$new(buffer_ticks = 2),
          quantity = 500
        )
      }
      plan <- SequencePart$new(children = buys)
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
  ThreeStepScaleIn$new()$run()
}
