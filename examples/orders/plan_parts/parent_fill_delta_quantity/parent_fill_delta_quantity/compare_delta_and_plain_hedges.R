#' Compare a hedge sized by an option's delta with one sized by a fixed ratio of the option's fills.
#'
#' Both plans buy an option and hedge each fill on another instrument. The first uses a `parent_fill_delta` quantity, which needs the `against_delta` side and lets UBI choose the hedge's direction from the option type, selling against a call and buying against a put. The second uses a `parent_fill` quantity with a fixed ratio of one half and states the hedge's side itself. The program prints both so the difference in the documents is plain to see. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/parent_fill_delta_quantity/parent_fill_delta_quantity/compare_delta_and_plain_hedges.R

library(tradeR)

#' Two hedges of the same option entry, one by delta and one by a fixed ratio.
#'
#' @field volatility_percent The numeric volatility in percent the delta is worked out at.
HedgeComparison <- R6::R6Class(
  "HedgeComparison",
  public = list(
    volatility_percent = NULL,

    #' @description
    #' Sets the volatility.
    #' @return A new `HedgeComparison` object.
    initialize = function() {
      self$volatility_percent <- 15.0
    },

    #' @description
    #' Prints both plans.
    #' @return `NULL`, invisibly.
    run = function() {
      by_delta <- ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(
          side = "against_delta",
          quantity = ParentFillDeltaQuantity$new(
            volatility = self$volatility_percent
          )
        )
      )
      by_ratio <- ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(
          transaction_type = "sell",
          quantity = ParentFillQuantity$new(ratio = 0.5)
        )
      )
      cat("Hedged by the option's delta:\n")
      cat(
        jsonlite::toJSON(
          by_delta$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat("Hedged by a fixed half of each fill:\n")
      cat(
        jsonlite::toJSON(
          by_ratio$document(),
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
  HedgeComparison$new()$run()
}
