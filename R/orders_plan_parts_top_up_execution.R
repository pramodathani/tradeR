#' An execution that sends one new broker order each time a join raises the order's target
#'
#' @description
#' The `top_up` execution of a plan: a new broker order for whatever a join's growing target is missing, never a resized one.
#'
#' It is meant for an order sized by a join, such as the second order of a `ThenPart` under `each_fill` that grows with every fill of the first. Each time the target grows, including after earlier orders have filled, one new broker order is sent for the quantity neither traded nor resting, so every broker order keeps the price it was given and its place in the queue; this is how UBI's `attached_hedge` and `legged_spread` presets grow their second leg. A target that shrinks cuts resting orders, newest first. A cancelled or rejected order stops it until the target next grows, so an `IOC` order the exchange cancels is not sent again at once, and a rejection stops it for good. A caller's change to the quantity of one of its orders is kept rather than modified back.
#'
#' It takes no settings and does not nest.
#' @examples
#' \dontrun{
#' execution <- TopUpExecution$new()
#' part <- OrderPart$new(execution = execution)
#' document <- part$document()
#' }
#' @export
TopUpExecution <- R6::R6Class(
  "TopUpExecution",
  inherit = PlanPart,
  public = list(
    #' @description
    #' Builds the `top_up` execution object UBI reads.
    #' @return A named list with the single key `top_up`, whose value is an empty named list, because the execution takes no settings.
    #' @examples
    #' \dontrun{
    #' execution <- TopUpExecution$new()
    #' print(execution$document())
    #'
    #' plan <- ThenPart$new(
    #'   first = OrderPart$new(),
    #'   each_fill = OrderPart$new(
    #'     side = "protect",
    #'     pricing = FixedPricing$new(
    #'       price = 1020.0,
    #'       order_type = "LIMIT"
    #'     ),
    #'     execution = TopUpExecution$new()
    #'   )
    #' )
    #' print(plan$document())
    #' }
    document = function() {
      list(
        top_up = structure(list(), names = character(0))
      )
    }
  )
)
