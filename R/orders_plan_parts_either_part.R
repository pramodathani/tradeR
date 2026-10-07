#' Several plans run at once, joined by what a fill on one does to the others
#'
#' @description
#' The `either` join of a plan: two or more plans run at once, where a fill on one acts on the others.
#'
#' With the sibling rule `cancel`, the first child to fill cancels the others, which is one-cancels-other between whole plans. With `reduce`, the children share one quantity and each is kept at that quantity less what its siblings have filled, which is how a stop and a target protect one position; each child must then be a single `OrderPart`.
#' @examples
#' \dontrun{
#' part <- EitherPart$new(
#'   children = list(
#'     stop_part,
#'     target_part
#'   ),
#'   sibling_rule = "reduce"
#' )
#' document <- part$document()
#' }
#' @export
EitherPart <- R6::R6Class(
  "EitherPart",
  inherit = PlanPart,
  public = list(
    #' @field children The list of `PlanPart` nodes run at once.
    children = NULL,
    #' @field sibling_rule The character rule, `cancel` or `reduce`, for what a fill on one child does to the others.
    sibling_rule = NULL,
    #' @field cancel_before_send A logical that is `TRUE` to have a child whose trigger holds cancel its siblings' resting orders before it is sent.
    cancel_before_send = NULL,

    #' @description
    #' Initialises the join with its children and its sibling rule.
    #' @param children A list of two or more `PlanPart` nodes to run at once.
    #' @param sibling_rule The character rule, `cancel` for the first fill to cancel the others, or `reduce` for the children to share one quantity.
    #' @param cancel_before_send A logical that is `TRUE` to have a child whose trigger holds cancel its siblings' resting orders before it is sent.
    #' @return A new `EitherPart` object.
    initialize = function(
      children,
      sibling_rule,
      cancel_before_send = FALSE
    ) {
      self$children <- children
      self$sibling_rule <- sibling_rule
      self$cancel_before_send <- cancel_before_send
    },

    #' @description
    #' Builds the `either` node UBI reads.
    #' @return A named list with the single key `either`, whose value holds `children`, `sibling_rule`, and `cancel_before_send` when it is `TRUE`.
    #' @examples
    #' \dontrun{
    #' part <- EitherPart$new(
    #'   children = list(
    #'     OrderPart$new(
    #'       side = "protect",
    #'       pricing = NativeStopPricing$new(
    #'         trigger_price = 990.0,
    #'         limit_price = 988.0
    #'       )
    #'     ),
    #'     OrderPart$new(
    #'       side = "protect",
    #'       pricing = FixedPricing$new(price = 1010.0, order_type = "LIMIT")
    #'     )
    #'   ),
    #'   sibling_rule = "reduce"
    #' )
    #' print(part$document())
    #'
    #' part <- EitherPart$new(
    #'   children = list(
    #'     OrderPart$new(
    #'       side = "buy",
    #'       trigger = PriceCrosses$new(level = 1010.0, direction = "at_or_above")
    #'     ),
    #'     OrderPart$new(
    #'       side = "sell",
    #'       trigger = PriceCrosses$new(level = 990.0, direction = "at_or_below")
    #'     )
    #'   ),
    #'   sibling_rule = "cancel",
    #'   cancel_before_send = TRUE
    #' )
    #' print(part$document())
    #' }
    document = function() {
      child_documents <- list()
      for (child in self$children) {
        child_documents[[length(child_documents) + 1]] <- child$document()
      }
      settings <- list(
        children = child_documents,
        sibling_rule = self$sibling_rule
      )
      if (isTRUE(self$cancel_before_send)) {
        settings[["cancel_before_send"]] <- TRUE
      }
      list(
        either = settings
      )
    }
  )
)
