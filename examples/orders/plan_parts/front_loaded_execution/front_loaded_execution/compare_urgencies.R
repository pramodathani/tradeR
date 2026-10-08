#' Build front-loaded orders at three urgencies and show how each shares out 1000 shares.
#'
#' Each slice of a front-loaded execution is `1 - urgency * 0.5` of the one before, so an urgency of 0 is an even split, UBI's default of 0.5 makes each slice three quarters of the last, and 1 halves every slice. The program builds five slices over half an hour at each urgency, prints the documents, and prints the approximate share of 1000 each slice would take, before UBI rounds them to whole units. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/front_loaded_execution/front_loaded_execution/compare_urgencies.R

library(tradeR)

#' Three front-loaded schedules for the same order.
#'
#' @field quantity The integer quantity shared out in the printed comparison.
#' @field urgencies The list of numeric urgencies compared, `NULL` standing for UBI's default.
UrgencyComparison <- R6::R6Class(
  "UrgencyComparison",
  public = list(
    quantity = NULL,
    urgencies = NULL,

    #' @description
    #' Chooses the quantity and the urgencies.
    #' @return A new `UrgencyComparison` object.
    initialize = function() {
      self$quantity <- 1000
      self$urgencies <- list(
        0.0,
        NULL,
        1.0
      )
    },

    #' @description
    #' Prints each order's object and its approximate slice sizes.
    #' @return `NULL`, invisibly.
    run = function() {
      for (urgency in self$urgencies) {
        execution <- FrontLoadedExecution$new(
          slices = 5,
          over_minutes = 30,
          urgency = urgency
        )
        part <- OrderPart$new(quantity = self$quantity, execution = execution)
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
        effective_urgency <- 0.5
        if (!is.null(urgency)) {
          effective_urgency <- urgency
        }
        ratio <- 1 - effective_urgency * 0.5
        weights <- c()
        weight <- 1.0
        for (index in seq_len(execution$slices)) {
          weights <- c(weights, weight)
          weight <- weight * ratio
        }
        total <- sum(weights)
        sizes <- c()
        for (weight in weights) {
          sizes <- c(sizes, round(self$quantity * weight / total))
        }
        cat(
          sprintf(
            "Urgency %s: slices of about [%s]\n",
            effective_urgency,
            paste(sizes, collapse = ", ")
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  UrgencyComparison$new()$run()
}
