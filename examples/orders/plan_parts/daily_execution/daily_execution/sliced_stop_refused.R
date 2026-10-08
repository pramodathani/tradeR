#' Build the two ways a resting stop may be sent, and one way UBI refuses.
#'
#' A resting stop protects the whole position at once, so UBI lets its order be sent only whole, by `AllAtOnceExecution`, or renewed whole each morning, by `DailyExecution`; any execution that splits it into pieces is refused with `stop_not_sliced`. The program builds the same stop three ways, the third with a TWAP, and prints each document with whether UBI accepts it. It only builds the documents, so the refusal it reports is UBI's documented rule rather than an answer from UBI. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/daily_execution/daily_execution/sliced_stop_refused.R

library(tradeR)

#' The same protecting stop under three executions.
#'
#' @field executions The list of named lists, each holding `description`, a character value, `execution`, a `PlanPart`, and `accepted`, a logical saying whether UBI takes it for a stop.
StopExecutions <- R6::R6Class(
  "StopExecutions",
  public = list(
    executions = NULL,

    #' @description
    #' Builds the three executions.
    #' @return A new `StopExecutions` object.
    initialize = function() {
      self$executions <- list(
        list(
          description = "sent whole",
          execution = AllAtOnceExecution$new(),
          accepted = TRUE
        ),
        list(
          description = "renewed at 09:30 each trading day",
          execution = DailyExecution$new(arm_at = "09:30"),
          accepted = TRUE
        ),
        list(
          description = "split into a TWAP",
          execution = TwapExecution$new(slices = 4, over_minutes = 20),
          accepted = FALSE
        )
      )
    },

    #' @description
    #' Prints each stop's object and whether UBI accepts it.
    #' @return `NULL`, invisibly.
    run = function() {
      for (entry in self$executions) {
        part <- OrderPart$new(
          side = "protect",
          pricing = NativeStopPricing$new(
            trigger_price = 950.0,
            limit_price = 948.0
          ),
          execution = entry[["execution"]]
        )
        verdict <- "accepted"
        if (!entry[["accepted"]]) {
          verdict <- "refused with stop_not_sliced"
        }
        cat(sprintf("A stop %s, %s:\n", entry[["description"]], verdict))
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
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  StopExecutions$new()$run()
}
