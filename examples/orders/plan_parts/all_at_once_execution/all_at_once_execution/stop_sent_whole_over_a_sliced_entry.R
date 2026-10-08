#' Build an entry sent in TWAP slices whose protective stop is sent whole.
#'
#' The program builds a then join whose first order buys in six TWAP slices over half an hour and whose `each_fill` order protects every fill with a native stop. The stop states `AllAtOnceExecution` explicitly, because a resting stop protects the whole position at once and UBI refuses to slice it. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/all_at_once_execution/all_at_once_execution/stop_sent_whole_over_a_sliced_entry.R

library(tradeR)

#' A sliced entry protected by one stop that grows with every fill.
#'
#' @field join The `ThenPart` the program prints.
SlicedEntryWholeStop <- R6::R6Class(
  "SlicedEntryWholeStop",
  public = list(
    join = NULL,

    #' @description
    #' Builds the then join.
    #' @return A new `SlicedEntryWholeStop` object.
    initialize = function() {
      self$join <- ThenPart$new(
        first = OrderPart$new(
          execution = TwapExecution$new(
            slices = 6,
            over_minutes = 30
          )
        ),
        each_fill = OrderPart$new(
          side = "protect",
          pricing = NativeStopPricing$new(
            trigger_price = 11.9,
            limit_price = 11.85
          ),
          execution = AllAtOnceExecution$new()
        )
      )
    },

    #' @description
    #' Prints the join's object.
    #' @return `NULL`, invisibly.
    run = function() {
      cat(
        jsonlite::toJSON(
          self$join$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat(
        "The entry goes in six slices; the stop is one order resized with every fill.\n"
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SlicedEntryWholeStop$new()$run()
}
