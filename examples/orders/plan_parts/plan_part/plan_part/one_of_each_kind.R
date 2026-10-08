#' Build one part of every kind a plan is made of and show that each is a PlanPart.
#'
#' The program builds a node, a preset, a trigger condition and a pricing rule, checks that each is a `PlanPart`, and prints the single UBI key each one's object holds. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/plan_part/plan_part/one_of_each_kind.R

library(tradeR)

#' A report of the UBI key each kind of plan part stands for.
#'
#' @field parts The named list of a character kind name to the `PlanPart` of that kind.
PartKindReport <- R6::R6Class(
  "PartKindReport",
  public = list(
    parts = NULL,

    #' @description
    #' Builds one part of each kind.
    #' @return A new `PartKindReport` object.
    initialize = function() {
      self$parts <- list(
        node = OrderPart$new(),
        preset = Preset$new("scheduled", at_time = "10:00"),
        trigger = PriceCrosses$new(level = 995.0),
        pricing = FixedPricing$new(price = 1010.0, order_type = "LIMIT")
      )
    },

    #' @description
    #' Prints each part's kind, class, whether it is a PlanPart and its UBI key.
    #' @return `NULL`, invisibly.
    run = function() {
      for (kind in names(self$parts)) {
        part <- self$parts[[kind]]
        document <- part$document()
        is_part <- inherits(part, "PlanPart")
        for (key in names(document)) {
          cat(
            sprintf(
              "%-8s %-14s PlanPart=%s key=%s\n",
              kind,
              class(part)[1],
              is_part,
              key
            )
          )
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  PartKindReport$new()$run()
}
