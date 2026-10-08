#' Build a square-off: at a quarter past three, close every intraday position in the account, and separately close only two named shares.
#'
#' The first plan closes every instrument held under the `intraday` position product, which is what the `square_off` synthetic order does. The second closes only Vodafone Idea and Yes Bank, and keeps their resting orders alive by turning `cancel_resting_first` off. Both use the `close` side, which a position quantity requires, and neither takes a pricing or execution, because UBI prices each closing order two ticks past the touch. It prints both plans. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/position_quantity/position_quantity/square_off_intraday_at_quarter_past_three.R

library(tradeR)

#' Two afternoon closes, one of the whole intraday book and one of two shares.
#'
#' @field shares The list of `Equity` objects closed by the second plan.
#' @field close_time The character time of day both closes fire.
IntradaySquareOff <- R6::R6Class(
  "IntradaySquareOff",
  public = list(
    shares = NULL,
    close_time = NULL,

    #' @description
    #' Looks the two shares up.
    #' @return A new `IntradaySquareOff` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$shares <- list(
        Equity$new(exchange = "nse", symbol = "IDEA"),
        Equity$new(exchange = "nse", symbol = "YESBANK")
      )
      self$close_time <- "15:15"
    },

    #' @description
    #' Prints both plans.
    #' @return `NULL`, invisibly.
    run = function() {
      every_position <- OrderPart$new(
        trigger = TimeAt$new(self$close_time),
        side = "close",
        quantity = PositionQuantity$new(
          product = "intraday",
          every_instrument = TRUE
        )
      )
      two_shares <- OrderPart$new(
        trigger = TimeAt$new(self$close_time),
        side = "close",
        quantity = PositionQuantity$new(
          product = "intraday",
          held_instruments = self$shares,
          cancel_resting_first = FALSE
        )
      )
      cat("Every intraday position:\n")
      cat(
        jsonlite::toJSON(
          every_position$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat("Only the two shares, leaving their resting orders alone:\n")
      cat(
        jsonlite::toJSON(
          two_shares$document(),
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
  IntradaySquareOff$new()$run()
}
