#' An execution that sends the order's whole quantity as one broker order, which is UBI's default
#'
#' @description
#' The `all_at_once` execution of a plan: the whole quantity sent as one broker order.
#'
#' This is what UBI does when an order names no execution, so it is needed only to say so explicitly, or to replace an execution an earlier preset gave. Under a join that changes how much the order should trade, the one resting order is modified rather than another being sent, so a bracket's exits grow and shrink in place. It is one of the two executions a resting stop may have, the other being `DailyExecution`.
#' @examples
#' \dontrun{
#' execution <- AllAtOnceExecution$new()
#' part <- OrderPart$new(execution = execution)
#' document <- part$document()
#' }
#' @export
AllAtOnceExecution <- R6::R6Class(
  "AllAtOnceExecution",
  inherit = PlanPart,
  public = list(
    #' @description
    #' Builds the `all_at_once` execution object UBI reads.
    #' @return A named list with the single key `all_at_once`, whose value is an empty named list, because the execution takes no settings.
    #' @examples
    #' \dontrun{
    #' execution <- AllAtOnceExecution$new()
    #' print(execution$document())
    #'
    #' part <- OrderPart$new(
    #'   side = "protect",
    #'   pricing = NativeStopPricing$new(
    #'     trigger_price = 990.0,
    #'     limit_price = 989.0
    #'   ),
    #'   execution = AllAtOnceExecution$new()
    #' )
    #' print(part$document())
    #' }
    document = function() {
      list(
        all_at_once = structure(list(), names = character(0))
      )
    }
  )
)
