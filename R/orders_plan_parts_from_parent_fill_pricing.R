#' A pricing rule for a spread's second leg, priced from the first leg's fill to reach a net price
#'
#' @description
#' The `from_parent_fill` pricing rule of a plan: the second leg of a spread priced from what the first leg filled at.
#'
#' UBI works out the price that makes the two legs add up to `net_price`, the net debit per unit, which is positive when the spread costs money and negative for a credit. The first leg's side signs its average fill, a buy costing and a sell bringing money in, and the second leg's price is the net less that, signed by the second leg's own side. Each new order of the second leg is priced so that it and the second leg's earlier orders together average the price the net needs, and is rounded to the second leg's tick in the caller's favour, down for a buy and up for a sell. A price at or below zero cannot be sent, so the order waits. The order must be the child of a `ThenPart` whose first plan is a single order, or UBI refuses the plan with `from_parent_fill_needs_then`.
#' @examples
#' \dontrun{
#' pricing <- FromParentFillPricing$new(net_price = 45.0)
#' document <- pricing$document()
#' }
#' @export
FromParentFillPricing <- R6::R6Class(
  "FromParentFillPricing",
  inherit = PlanPart,
  public = list(
    #' @field net_price The numeric net debit per unit in rupees, negative for a credit.
    net_price = NULL,

    #' @description
    #' Initialises the rule with the net price aimed at.
    #' @param net_price The numeric net debit per unit in rupees that the two legs should add up to, positive when the spread costs money and negative for a credit.
    #' @return A new `FromParentFillPricing` object.
    initialize = function(net_price) {
      self$net_price <- net_price
    },

    #' @description
    #' Builds the `from_parent_fill` pricing object UBI reads.
    #' @return A named list with the single key `from_parent_fill`, whose value holds `net_price`.
    #' @examples
    #' \dontrun{
    #' pricing <- FromParentFillPricing$new(net_price = 45.0)
    #' print(pricing$document())
    #'
    #' part <- ThenPart$new(
    #'   first = OrderPart$new(transaction_type = "sell"),
    #'   each_fill = OrderPart$new(
    #'     transaction_type = "buy",
    #'     pricing = FromParentFillPricing$new(
    #'       net_price = -30.0
    #'     )
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      list(
        from_parent_fill = list(
          net_price = self$net_price
        )
      )
    }
  )
)
