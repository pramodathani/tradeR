#' A bound on the price a pricing rule may set
#'
#' @description
#' The `cap` modifier of a plan's pricing: the most a buy will pay and the least a sell will take.
#'
#' A cap is not a pricing rule of its own but a bound on one. Whatever the rule works out, when the order is sent and every time it is moved, a buy's limit is held at or below `worst_price` and a sell's at or above it. It goes beside the one pricing rule, as `OrderPart$new(pricing = ..., cap = ...)`, and an order has at most one cap. A market order has no limit to cap.
#' @examples
#' \dontrun{
#' cap <- CapModifier$new(worst_price = 1010.0)
#' document <- cap$document()
#' }
#' @export
CapModifier <- R6::R6Class(
  "CapModifier",
  inherit = PlanPart,
  public = list(
    #' @field worst_price The numeric worst price in rupees, the most a buy pays or the least a sell takes.
    worst_price = NULL,

    #' @description
    #' Initialises the cap with its worst price.
    #' @param worst_price The numeric worst price in rupees, above zero, the most a buy pays or the least a sell takes.
    #' @return A new `CapModifier` object.
    initialize = function(worst_price) {
      self$worst_price <- worst_price
    },

    #' @description
    #' Builds the `cap` modifier object UBI reads in an order's pricing list.
    #' @return A named list with the single key `cap`, whose value holds `worst_price`.
    #' @examples
    #' \dontrun{
    #' cap <- CapModifier$new(worst_price = 1010.0)
    #' print(cap$document())
    #'
    #' part <- OrderPart$new(
    #'   pricing = ChasePricing$new(step_ticks = 1, step_seconds = 5),
    #'   cap = CapModifier$new(worst_price = 1010.0)
    #' )
    #' print(part$document())
    #' }
    document = function() {
      list(
        cap = list(
          worst_price = self$worst_price
        )
      )
    }
  )
)
