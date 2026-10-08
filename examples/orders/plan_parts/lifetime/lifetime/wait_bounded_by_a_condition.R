#' Build a dip entry whose wait ends if the index breaks down or the afternoon comes.
#'
#' The program watches the NIFTY index and gives a dip entry on NSE IDEA a lifetime ending `when` either the index falls to 2 percent below its last value or it is 14:00, whichever comes first. The lifetime applies only to the wait, so an entry already sent is left to work. The market data read is read-only, and nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/lifetime/lifetime/wait_bounded_by_a_condition.R

library(tradeR)

#' A dip entry whose wait ends on an index breakdown or at a time.
#'
#' @field share The `Equity` bought on the dip.
#' @field index The `EquityIndex` watched for a breakdown.
BoundedDipEntry <- R6::R6Class(
  "BoundedDipEntry",
  public = list(
    share = NULL,
    index = NULL,

    #' @description
    #' Looks the share and the index up.
    #' @return A new `BoundedDipEntry` object.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    },

    #' @description
    #' Prints the entry's object with the levels it uses.
    #' @return `NULL`, invisibly.
    run = function() {
      entry_level <- round(self$share$last_price * 0.98, 2)
      breakdown_level <- round(self$index$last_price * 0.98, 2)
      ending <- Lifetime$new(
        when = AnyCondition$new(
          list(
            PriceCrosses$new(
              level = breakdown_level,
              direction = "at_or_below",
              instrument = self$index
            ),
            TimeAt$new("14:00")
          )
        ),
        applies_to = "waiting"
      )
      part <- OrderPart$new(
        trigger = PriceCrosses$new(level = entry_level),
        lifetime = ending
      )
      cat(
        sprintf(
          "Entry at %s, given up if the index reaches %s or at 14:00:\n",
          entry_level,
          breakdown_level
        )
      )
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
  BoundedDipEntry$new()$run()
}
