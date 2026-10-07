#' An execution that waits for enough displayed size at or inside a price and then strikes
#'
#' @description
#' The `book_depth` execution of a plan: nothing shown until enough size is displayed at an acceptable price, then a strike for what is there.
#'
#' It adds up the displayed quantity at every level of the other side of the book that is no worse than `limit_price`, and when that reaches `minimum_quantity` it sends the smaller of what is shown and what is left of the order. A strike that partly fills rests at its price, and later strikes are only for what is neither traded nor resting. A strike the broker rejects stops the order. The order starts watching the book as soon as its trigger holds.
#'
#' The strike's price comes from the order's pricing, so the `liquidity_seeking` preset pairs this execution with a `FixedPricing` at the same `limit_price`, and that is the usual way to write it out. It does not nest, and cannot carry a resting stop.
#' @examples
#' \dontrun{
#' execution <- BookDepthExecution$new(
#'   limit_price = 1000.0,
#'   minimum_quantity = 500
#' )
#' part <- OrderPart$new(execution = execution)
#' document <- part$document()
#' }
#' @export
BookDepthExecution <- R6::R6Class(
  "BookDepthExecution",
  inherit = PlanPart,
  public = list(
    #' @field limit_price The numeric worst price in rupees the order will trade at.
    limit_price = NULL,
    #' @field minimum_quantity The integer displayed size, at least 1, that makes a strike worthwhile.
    minimum_quantity = NULL,

    #' @description
    #' Initialises the execution with its price and its minimum size.
    #' @param limit_price The numeric worst price in rupees the order will trade at.
    #' @param minimum_quantity The integer displayed size, at least 1, that makes a strike worthwhile.
    #' @return A new `BookDepthExecution` object.
    initialize = function(
      limit_price,
      minimum_quantity
    ) {
      self$limit_price <- limit_price
      self$minimum_quantity <- minimum_quantity
    },

    #' @description
    #' Builds the `book_depth` execution object UBI reads.
    #' @return A named list with the single key `book_depth`, whose value holds `limit_price` and `minimum_quantity`.
    #' @examples
    #' \dontrun{
    #' execution <- BookDepthExecution$new(
    #'   limit_price = 1000.0,
    #'   minimum_quantity = 500
    #' )
    #' print(execution$document())
    #'
    #' part <- OrderPart$new(
    #'   pricing = FixedPricing$new(
    #'     price = 1000.0,
    #'     order_type = "LIMIT"
    #'   ),
    #'   execution = BookDepthExecution$new(
    #'     limit_price = 1000.0,
    #'     minimum_quantity = 500
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      list(
        book_depth = list(
          limit_price = self$limit_price,
          minimum_quantity = self$minimum_quantity
        )
      )
    }
  )
)
