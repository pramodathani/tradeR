#' Print one order ended each of the three ways UBI offers when its time comes.
#'
#' A limit entry can be cancelled at 14:30, made marketable at 14:30 so it fills, or have whatever filled closed at market thirty minutes after placing. The program builds the same limit entry at 995 with each lifetime and prints all three. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/lifetime/lifetime/three_ways_to_end_an_order.R

library(tradeR)

#' The same limit entry with three different lifetimes.
#'
#' @field lifetimes The named list of `Lifetime` objects by the character name of how each ends.
ThreeEndings <- R6::R6Class(
  "ThreeEndings",
  public = list(
    lifetimes = NULL,

    #' @description
    #' Builds the three lifetimes.
    #' @return A new `ThreeEndings` object.
    initialize = function() {
      self$lifetimes <- list(
        "cancel at 14:30" = Lifetime$new(at_time = "14:30"),
        "marketable at 14:30" = Lifetime$new(
          at_time = "14:30",
          on_end = "marketable"
        ),
        "close what filled after 30 minutes" = Lifetime$new(
          after_minutes = 30,
          on_end = "close_filled"
        )
      )
    },

    #' @description
    #' Prints the entry's object with each lifetime.
    #' @return `NULL`, invisibly.
    run = function() {
      for (name in names(self$lifetimes)) {
        ending <- self$lifetimes[[name]]
        part <- OrderPart$new(
          pricing = FixedPricing$new(price = 995.0),
          lifetime = ending
        )
        cat(sprintf("Ending by %s:\n", name))
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
  ThreeEndings$new()$run()
}
