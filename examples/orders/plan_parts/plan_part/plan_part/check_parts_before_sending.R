#' Check a list of plan parts before building a plan, and see that the base class itself describes nothing.
#'
#' A program that assembles plans from user input can check that every piece it was given is a `PlanPart` whose object holds exactly one key, which is the shape UBI reads. The program checks three good parts, a plain named list that is not a part, and the bare base class, which refuses to describe itself. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/plan_part/plan_part/check_parts_before_sending.R

library(tradeR)

#' A checker that reports which candidate pieces can go into a plan.
#'
#' @field candidates The list of objects to check, some of them not usable parts.
PartChecker <- R6::R6Class(
  "PartChecker",
  public = list(
    candidates = NULL,

    #' @description
    #' Builds the pieces to check.
    #' @return A new `PartChecker` object.
    initialize = function() {
      self$candidates <- list(
        TimeAt$new("10:00"),
        Trails$new(points = 5.0),
        MarketablePricing$new(buffer_ticks = 2),
        list(
          price_crosses = list(
            level = 995.0
          )
        ),
        PlanPart$new()
      )
    },

    #' @description
    #' Says whether one piece can go into a plan, and why not when it cannot.
    #' @param candidate The object to check, of any type.
    #' @return A character verdict.
    verdict = function(candidate) {
      if (!inherits(candidate, "PlanPart")) {
        return("refused: not a PlanPart, so it cannot be placed in a plan")
      }
      refusal <- NULL
      document <- tryCatch(
        candidate$document(),
        NotImplementedError = function(error) {
          refusal <<- sprintf("refused: %s", conditionMessage(error))
          NULL
        }
      )
      if (!is.null(refusal)) {
        return(refusal)
      }
      if (length(document) != 1) {
        return("refused: its object does not hold exactly one key")
      }
      sprintf(
        "accepted: %s",
        jsonlite::toJSON(document, auto_unbox = TRUE, null = "null")
      )
    },

    #' @description
    #' Prints the verdict on every candidate.
    #' @return `NULL`, invisibly.
    run = function() {
      for (candidate in self$candidates) {
        cat(
          sprintf("%-18s %s\n", class(candidate)[1], self$verdict(candidate))
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  PartChecker$new()$run()
}
