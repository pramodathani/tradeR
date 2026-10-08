#' Choose a pullback distance for a share in rupees or as a percentage, and see the two side by side.
#'
#' The program reads Vodafone Idea's last price, builds a `trails` condition 2% behind it as a percentage, and another with the same distance written in rupees, and prints both. A percentage keeps its meaning as the price moves, while rupees are easier to reason about for one trade. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/trails/trails/points_or_percent_for_a_share.R

library(tradeR)

#' The same pullback distance for Vodafone Idea, as a percentage and in rupees.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field percent The numeric pullback distance as a percentage of the price.
PullbackDistance <- R6::R6Class(
  "PullbackDistance",
  public = list(
    share = NULL,
    percent = NULL,

    #' @description
    #' Looks up the share and sets the distance.
    #' @return A new `PullbackDistance` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$percent <- 2.0
    },

    #' @description
    #' Prints the last price and both conditions' objects.
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
      points <- round(last_price * self$percent / 100, 2)
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(sprintf("%s%% of it is %s rupees.\n", self$percent, points))
      cat(
        jsonlite::toJSON(
          Trails$new(percent = self$percent)$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat(
        jsonlite::toJSON(
          Trails$new(points = points)$document(),
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
  PullbackDistance$new()$run()
}
