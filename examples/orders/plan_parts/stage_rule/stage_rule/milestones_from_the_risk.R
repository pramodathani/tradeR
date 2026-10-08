#' Build a table of stop milestones measured in multiples of a trade's risk, ending in a trail.
#'
#' The program reads Vodafone Idea's last price, treats a stop 2% below it as the trade's risk, and builds three milestones: at one risk of gain the stop moves to breakeven, at two it locks in one risk, and at three it starts trailing one risk behind. It prints each milestone's entry and the list as UBI would read it in a `stages` rule. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/stage_rule/stage_rule/milestones_from_the_risk.R

library(tradeR)

#' Three stop milestones for Vodafone Idea, in multiples of a 2% risk.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
RiskMilestones <- R6::R6Class(
  "RiskMilestones",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `RiskMilestones` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the risk and the milestones.
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
      risk <- round(last_price * 0.02, 2)
      rules <- list(
        StageRule$new(gain = risk, stop_at_gain = 0.0),
        StageRule$new(gain = round(risk * 2, 2), stop_at_gain = risk),
        StageRule$new(gain = round(risk * 3, 2), trail_points = risk)
      )
      rule_documents <- list()
      for (rule in rules) {
        rule_documents[[length(rule_documents) + 1]] <- rule$document()
      }
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(sprintf("One risk, 2%% of the price: %s\n", risk))
      cat(
        jsonlite::toJSON(
          rule_documents,
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
  RiskMilestones$new()$run()
}
