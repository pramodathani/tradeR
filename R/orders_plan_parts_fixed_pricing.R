#' A pricing rule that sends the order at a set price, or at market
#'
#' @description
#' The `fixed` pricing rule of a plan: a limit at a given price, or a market order.
#'
#' It is the rule an order in a plan uses when it names none, taking the template's own order type and price. UBI writes its order type in capitals here, `LIMIT` or `MARKET`, unlike the template's lower-case `limit` and `market`.
#' @examples
#' \dontrun{
#' pricing <- FixedPricing$new(price = 1010.0, order_type = "LIMIT")
#' document <- pricing$document()
#' }
#' @export
FixedPricing <- R6::R6Class(
  "FixedPricing",
  inherit = PlanPart,
  public = list(
    #' @field price The numeric limit price in rupees, or `NULL` to use the template's price.
    price = NULL,
    #' @field order_type The character order type, `LIMIT` or `MARKET`, or `NULL` to use the template's.
    order_type = NULL,

    #' @description
    #' Initialises the rule with its price and order type.
    #' @param price The numeric limit price in rupees, or `NULL` to use the template's price.
    #' @param order_type The character order type in capitals, `LIMIT` or `MARKET`, or `NULL` to use the template's.
    #' @return A new `FixedPricing` object.
    initialize = function(
      price = NULL,
      order_type = NULL
    ) {
      self$price <- price
      self$order_type <- order_type
    },

    #' @description
    #' Builds the `fixed` pricing object UBI reads.
    #' @return A named list with the single key `fixed`, whose value holds `price` and `order_type` when each is set.
    #' @examples
    #' \dontrun{
    #' pricing <- FixedPricing$new(price = 1010.0, order_type = "LIMIT")
    #' print(pricing$document())
    #'
    #' print(FixedPricing$new(order_type = "MARKET")$document())
    #' print(FixedPricing$new()$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$price)) {
        settings[["price"]] <- self$price
      }
      if (!is.null(self$order_type)) {
        settings[["order_type"]] <- self$order_type
      }
      list(
        fixed = settings
      )
    }
  )
)
