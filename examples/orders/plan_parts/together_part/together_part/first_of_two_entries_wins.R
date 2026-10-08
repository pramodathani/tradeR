#' Build two entries into Vodafone Idea, one on a dip and one on a breakout, where the first to be done cancels the other.
#'
#' The program reads the share's last price and builds a buy that waits for a 2% dip and a buy that waits for a 2% rise. They are joined with `done_when` set to `any`, so once one entry is done the other is cancelled, and with `group_margin` turned off, because only one of them will ever trade. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/together_part/together_part/first_of_two_entries_wins.R

library(tradeR)

#' A dip entry and a breakout entry where whichever finishes first ends the other.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field move_fraction The numeric fraction of the last price either entry waits for.
FirstEntryWins <- R6::R6Class(
  "FirstEntryWins",
  public = list(
    share = NULL,
    move_fraction = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `FirstEntryWins` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$move_fraction <- 0.02
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
      dip_level <- round(last_price * (1 - self$move_fraction), 2)
      breakout_level <- round(last_price * (1 + self$move_fraction), 2)
      plan <- TogetherPart$new(
        children = list(
          OrderPart$new(
            trigger = PriceCrosses$new(
              level = dip_level,
              direction = "at_or_below"
            ),
            pricing = MarketablePricing$new()
          ),
          OrderPart$new(
            trigger = PriceCrosses$new(
              level = breakout_level,
              direction = "at_or_above"
            ),
            pricing = MarketablePricing$new()
          )
        ),
        group_margin = FALSE,
        done_when = "any"
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
  FirstEntryWins$new()$run()
}
