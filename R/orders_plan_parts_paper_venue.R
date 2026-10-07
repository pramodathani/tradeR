#' Paper trading, where an order is filled from the queue estimate and nothing reaches a broker
#'
#' @description
#' The `paper` venue of a plan: an order that is never sent and is filled on paper instead.
#'
#' UBI fills a paper order from the virtual book's queue estimate, as a resting order at its limit would have filled, records each fill as a `paper_filled` event and completes the plan once the whole quantity has filled. Because the fills come from that estimate, the order must wait on a `limit_marketable` trigger alone (`paper_needs_limit_marketable`), which also means it takes no pricing of its own and is held at the body's own limit price, and it must be the whole plan (`paper_is_the_whole_plan`), since it cannot be joined with orders that trade for real. Unlike most parts, a venue is an entry of the order's `venue` list rather than a one-key object.
#' @examples
#' \dontrun{
#' part <- OrderPart$new(
#'   trigger = LimitMarketable$new(),
#'   venue = PaperVenue$new()
#' )
#' document <- part$document()
#' }
#' @export
PaperVenue <- R6::R6Class(
  "PaperVenue",
  inherit = PlanPart,
  public = list(
    #' @description
    #' Builds the venue entry UBI reads.
    #' @return A named list holding `session` set to `paper`. `OrderPart` puts it in a list of one under `venue`.
    #' @examples
    #' \dontrun{
    #' print(PaperVenue$new()$document())
    #'
    #' part <- OrderPart$new(
    #'   trigger = LimitMarketable$new(),
    #'   venue = PaperVenue$new()
    #' )
    #' print(part$document())
    #' }
    document = function() {
      list(
        session = "paper"
      )
    }
  )
)
