#' Build an entry whose profit target is placed only once the entry is done, and which stops buying once the target fills.
#'
#' The program builds a then join with an `on_complete` child, a protecting limit 2% above an entry at 1000, and sets `cancel_first_on_child_fill`, so a fill on the target cancels whatever of the entry is still working. It then nests that join as the first plan of another, whose child is a time exit at ten past three, to show that joins can hold joins. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/then_part/then_part/target_after_entry_completes.R

library(tradeR)

#' An entry, a target placed once the entry is done, and an optional time exit after both.
#'
#' @field entry_price The numeric price in rupees the entry is assumed to buy at.
TargetAfterEntry <- R6::R6Class(
  "TargetAfterEntry",
  public = list(
    entry_price = NULL,

    #' @description
    #' Sets the entry price the target is worked out from.
    #' @return A new `TargetAfterEntry` object.
    initialize = function() {
      self$entry_price <- 1000.0
    },

    #' @description
    #' Builds the entry and its target.
    #' @return The `ThenPart` joining them.
    target_join = function() {
      target_price <- round(self$entry_price * 1.02, 2)
      ThenPart$new(
        first = OrderPart$new(),
        on_complete = OrderPart$new(
          side = "protect",
          pricing = FixedPricing$new(
            price = target_price,
            order_type = "LIMIT"
          )
        ),
        cancel_first_on_child_fill = TRUE
      )
    },

    #' @description
    #' Builds a join whose first plan is the target join and whose child exits at ten past three.
    #' @return The `ThenPart` holding the target join.
    nested_join = function() {
      ThenPart$new(
        first = self$target_join(),
        on_complete = OrderPart$new(
          side = "protect",
          trigger = TimeAt$new("15:10"),
          pricing = FixedPricing$new(order_type = "MARKET")
        )
      )
    },

    #' @description
    #' Prints both joins' objects.
    #' @return `NULL`, invisibly.
    run = function() {
      cat("Entry, then a target once the entry is done:\n")
      cat(
        jsonlite::toJSON(
          self$target_join()$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat("The same, nested inside a join that ends with a time exit:\n")
      cat(
        jsonlite::toJSON(
          self$nested_join()$document(),
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
  TargetAfterEntry$new()$run()
}
