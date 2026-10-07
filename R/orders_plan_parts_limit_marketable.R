#' A condition that holds once the order's own limit price would fill at once
#'
#' @description
#' The `limit_marketable` trigger of a plan: the other side of the book reaching the order's own limit price.
#'
#' It holds a limit order in UBI's engine instead of at the exchange, and sends it only once it would fill straight away: for a buy, when the best offer is at or below the limit, and for a sell, when the best bid is at or above it. A quote marked stale never counts. The condition takes no settings and is written `{}`. The order is held at the body's own `LIMIT` price, so the template must be a limit order with a price and the order takes no pricing of its own; UBI refuses a pricing rule beside it. While the order is held, UBI's virtual book estimates how much a resting order at the same price would have filled, and keeps that as `missed_quantity` when the order is sent.
#' @examples
#' \dontrun{
#' condition <- LimitMarketable$new()
#' document <- condition$document()
#' }
#' @export
LimitMarketable <- R6::R6Class(
  "LimitMarketable",
  inherit = PlanPart,
  public = list(
    #' @description
    #' Builds the `limit_marketable` condition UBI reads.
    #' @return A named list with the single key `limit_marketable`, whose value is an empty named list, because the condition takes no settings.
    #' @examples
    #' \dontrun{
    #' print(LimitMarketable$new()$document())
    #'
    #' part <- OrderPart$new(
    #'   trigger = LimitMarketable$new()
    #' )
    #' print(part$document())
    #'
    #' part <- OrderPart$new(
    #'   trigger = LimitMarketable$new(),
    #'   lifetime = Lifetime$new(
    #'     at_time = "15:20",
    #'     applies_to = "waiting"
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      list(
        limit_marketable = structure(list(), names = character(0))
      )
    }
  )
)
