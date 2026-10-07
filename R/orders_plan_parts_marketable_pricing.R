#' A pricing rule that sends a limit a few ticks past the opposite touch
#'
#' @description
#' The `marketable` pricing rule of a plan: a limit a few ticks past the other side of the book.
#'
#' UBI reads the opposite touch when it sends the order, the best offer for a buy and the best bid for a sell, and sets the limit `buffer_ticks` past it, so the order trades at once like a market order but cannot fill far from the book. With no book to price against, or a quote marked stale, the order waits for the next tick, even an order sent only when a fill arrives, such as a hedge.
#' @examples
#' \dontrun{
#' pricing <- MarketablePricing$new(buffer_ticks = 2)
#' document <- pricing$document()
#' }
#' @export
MarketablePricing <- R6::R6Class(
  "MarketablePricing",
  inherit = PlanPart,
  public = list(
    #' @field buffer_ticks The integer number of ticks past the opposite touch, or `NULL` for UBI's default of 2.
    buffer_ticks = NULL,

    #' @description
    #' Initialises the rule with its buffer.
    #' @param buffer_ticks The integer number of ticks past the opposite touch, or `NULL` for UBI's default of 2.
    #' @return A new `MarketablePricing` object.
    initialize = function(buffer_ticks = NULL) {
      self$buffer_ticks <- buffer_ticks
    },

    #' @description
    #' Builds the `marketable` pricing object UBI reads.
    #' @return A named list with the single key `marketable`, whose value holds `buffer_ticks` when it is set.
    #' @examples
    #' \dontrun{
    #' print(MarketablePricing$new()$document())
    #'
    #' print(MarketablePricing$new(buffer_ticks = 5)$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$buffer_ticks)) {
        settings[["buffer_ticks"]] <- self$buffer_ticks
      }
      list(
        marketable = settings
      )
    }
  )
)
