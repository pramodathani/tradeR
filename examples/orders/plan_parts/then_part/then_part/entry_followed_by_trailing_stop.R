#' Build an entry whose every fill is protected at once by a trailing stop.
#'
#' The program builds a then join whose first plan is the template's own order and whose `each_fill` child is a protecting order priced by a stop that trails 2% behind the market. Because the child is sized to what has filled and resized with every fill, a partly filled entry is protected for exactly what was bought. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/then_part/then_part/entry_followed_by_trailing_stop.R

library(tradeR)

#' An entry followed by a trailing stop sized to each fill.
#'
#' @field join The `ThenPart` the program prints.
TrailedEntry <- R6::R6Class(
  "TrailedEntry",
  public = list(
    join = NULL,

    #' @description
    #' Builds the then join.
    #' @return A new `TrailedEntry` object.
    initialize = function() {
      self$join <- ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(
          side = "protect",
          pricing = TrailPricing$new(
            percent = 2.0,
            limit_offset = 0.05
          )
        )
      )
    },

    #' @description
    #' Prints the join's object and says when its child starts.
    #' @return `NULL`, invisibly.
    run = function() {
      document <- self$join$document()
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
      if ("each_fill" %in% names(document[["then"]])) {
        cat(
          "The stop starts on the entry's first fill and grows with every fill.\n"
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TrailedEntry$new()$run()
}
