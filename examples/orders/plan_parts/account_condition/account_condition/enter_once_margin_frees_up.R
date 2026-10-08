#' Build an entry that waits until the account has free margin again, and has no more than two positions open.
#'
#' The program joins two `account` conditions with `AllConditions`: the free margin across every broker at or above 50,000 rupees, and the count of open net positions at or below 2. The entry is sent at a marketable limit once both hold. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/account_condition/account_condition/enter_once_margin_frees_up.R

library(tradeR)

#' An entry held until the account has room for it.
#'
#' @field minimum_margin The numeric free margin in rupees the entry needs.
#' @field most_positions The integer number of open positions allowed before the entry.
MarginGatedEntry <- R6::R6Class(
  "MarginGatedEntry",
  public = list(
    minimum_margin = NULL,
    most_positions = NULL,

    #' @description
    #' Sets the margin and position limits.
    #' @return A new `MarginGatedEntry` object.
    initialize = function() {
      self$minimum_margin <- 50000.0
      self$most_positions <- 2
    },

    #' @description
    #' Prints the entry's object.
    #' @return `NULL`, invisibly.
    run = function() {
      room <- AllConditions$new(
        list(
          AccountCondition$new(
            field = "available_balance",
            level = self$minimum_margin,
            direction = "at_or_above"
          ),
          AccountCondition$new(
            field = "open_positions",
            level = self$most_positions,
            direction = "at_or_below"
          )
        )
      )
      part <- OrderPart$new(
        trigger = room,
        pricing = MarketablePricing$new()
      )
      cat("The entry waits for margin and a free position slot:\n")
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
  MarginGatedEntry$new()$run()
}
