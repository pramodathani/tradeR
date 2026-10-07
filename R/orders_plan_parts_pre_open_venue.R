#' The pre-open session, with the time the order is sent into it
#'
#' @description
#' The `pre_open` venue of a plan: an order sent in the pre-open session so it trades at the opening auction's price.
#'
#' UBI sends the order at `at_time`, 09:00:30 by default, through a `time_from` trigger of its own, so an order with this venue takes no trigger (`pre_open_sets_its_time`). The pre-open takes only `LIMIT` and `MARKET` orders, on NSE and BSE cash until 09:10, market orders until 09:05, and on NSE stock and index futures until 09:07; anything else, or an order sent after collection has closed, is refused with HTTP 400. Unlike most parts, a venue is an entry of the order's `venue` list rather than a one-key object.
#' @examples
#' \dontrun{
#' part <- OrderPart$new(venue = PreOpenVenue$new(at_time = "09:02"))
#' document <- part$document()
#' }
#' @export
PreOpenVenue <- R6::R6Class(
  "PreOpenVenue",
  inherit = PlanPart,
  public = list(
    #' @field at_time The character time of day the order is sent, such as `09:02`, or `NULL` for UBI's default of `09:00:30`.
    at_time = NULL,

    #' @description
    #' Initialises the venue with the time the order is sent.
    #' @param at_time The character time of day in India while the pre-open takes orders, such as `09:02` or `09:00:30`, or `NULL` for UBI's default of `09:00:30`.
    #' @return A new `PreOpenVenue` object.
    initialize = function(at_time = NULL) {
      self$at_time <- at_time
    },

    #' @description
    #' Builds the venue entry UBI reads.
    #' @return A named list holding `session` set to `pre_open`, and `at_time` when it is not `NULL`. `OrderPart` puts it in a list of one under `venue`.
    #' @examples
    #' \dontrun{
    #' print(PreOpenVenue$new()$document())
    #'
    #' part <- OrderPart$new(
    #'   pricing = FixedPricing$new(price = 1000.0, order_type = "LIMIT"),
    #'   venue = PreOpenVenue$new(at_time = "09:02")
    #' )
    #' print(part$document())
    #' }
    document = function() {
      entry <- list(
        session = "pre_open"
      )
      if (!is.null(self$at_time)) {
        entry[["at_time"]] <- self$at_time
      }
      entry
    }
  )
)
