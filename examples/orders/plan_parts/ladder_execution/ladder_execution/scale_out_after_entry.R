#' Build an entry whose position is taken off on a ladder of targets once it has filled.
#'
#' The program builds a then join: the template's own order first, and under `on_complete` a protecting order sent as a ladder of four limit orders from 1020 to 1050, so the position is sold in four equal parts as the price rises. The ladder needs no pricing, because its rungs set the prices. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/ladder_execution/ladder_execution/scale_out_after_entry.R

library(tradeR)

#' An entry followed by a four-rung ladder of targets.
#'
#' @field join The `ThenPart` the program prints.
LadderedExit <- R6::R6Class(
  "LadderedExit",
  public = list(
    join = NULL,

    #' @description
    #' Builds the then join.
    #' @return A new `LadderedExit` object.
    initialize = function() {
      self$join <- ThenPart$new(
        first = OrderPart$new(),
        on_complete = OrderPart$new(
          side = "protect",
          execution = LadderExecution$new(
            from_price = 1020.0,
            to_price = 1050.0,
            steps = 4
          )
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
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  LadderedExit$new()$run()
}
