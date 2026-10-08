#' Build an entry that is given up once the day's loss across the account reaches a limit.
#'
#' The program holds a dip-buying entry on a touch, and gives the entry a lifetime that ends it, cancelling whatever still rests, once `day_pnl` falls to minus 5,000 rupees. The account figure is read by UBI's engine across every broker. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/account_condition/account_condition/stop_trading_after_a_bad_day.R

library(tradeR)

#' A dip entry that ends once the day's loss reaches a limit.
#'
#' @field loss_limit The numeric day's profit, negative for a loss, at which the entry ends.
#' @field entry_level The numeric price the entry waits for.
BadDayCutoff <- R6::R6Class(
  "BadDayCutoff",
  public = list(
    loss_limit = NULL,
    entry_level = NULL,

    #' @description
    #' Sets the loss limit and the entry level.
    #' @return A new `BadDayCutoff` object.
    initialize = function() {
      self$loss_limit <- -5000.0
      self$entry_level <- 995.0
    },

    #' @description
    #' Prints the entry's object.
    #' @return `NULL`, invisibly.
    run = function() {
      cutoff <- AccountCondition$new(
        field = "day_pnl",
        level = self$loss_limit,
        direction = "at_or_below"
      )
      part <- OrderPart$new(
        trigger = PriceCrosses$new(level = self$entry_level),
        lifetime = Lifetime$new(when = cutoff)
      )
      cat(
        sprintf(
          "The entry ends once the day's profit is %s:\n",
          self$loss_limit
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
  BadDayCutoff$new()$run()
}
