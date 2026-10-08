#' Build a group that holds inside a time window when either the bid or the last price reaches a level.
#'
#' Groups can hold groups. The program puts an `AnyCondition` on the bid or the last price inside an `AllConditions` group with a window from 10:00 to 14:30, and prints the object and how deep the tree goes. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/all_conditions/all_conditions/window_with_either_price.R

library(tradeR)

#' A nested group of conditions.
#'
#' @field group The `AllConditions` the program prints.
WindowWithEitherPrice <- R6::R6Class(
  "WindowWithEitherPrice",
  public = list(
    group = NULL,

    #' @description
    #' Builds the group.
    #' @return A new `WindowWithEitherPrice` object.
    initialize = function() {
      self$group <- AllConditions$new(
        list(
          TimeAfter$new("10:00"),
          TimeBefore$new("14:30"),
          AnyCondition$new(
            list(
              PriceCrosses$new(level = 995.0, field = "bid"),
              PriceCrosses$new(level = 995.0, field = "last")
            )
          )
        )
      )
    },

    #' @description
    #' Counts how many groups deep a condition object goes.
    #'
    #' A named list stands for a JSON object, whose `all` and `any` keys each add one level, and an unnamed list stands for a JSON array.
    #' @param document The object to measure, a named list, an unnamed list or a plain value.
    #' @return The integer depth, 0 for a plain value.
    depth = function(document) {
      deepest <- 0
      if (!is.list(document)) {
        return(deepest)
      }
      keys <- names(document)
      for (index in seq_along(document)) {
        inner <- self$depth(document[[index]])
        if (!is.null(keys) && keys[[index]] %in% c("all", "any")) {
          inner <- inner + 1
        }
        deepest <- max(deepest, inner)
      }
      deepest
    },

    #' @description
    #' Prints the group's object and its depth.
    #' @return `NULL`, invisibly.
    run = function() {
      document <- self$group$document()
      cat(
        jsonlite::toJSON(
          document,
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat(sprintf("Groups nested: %d\n", as.integer(self$depth(document))))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  WindowWithEitherPrice$new()$run()
}
