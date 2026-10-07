#' A pricing rule for an exit set a distance from the fill that opened its position
#'
#' @description
#' The `from_fill` pricing rule of a plan: an exit placed a distance from the price its position was opened at.
#'
#' UBI prices the exit from the average fill of the orders that opened the position, in the direction that suits the side it is sent on, so one setting suits a position opened either way. When both sides of a two-sided entry filled, only the fills on the side the position is held on count, so a short opened at 990 and partly bought back at 1010 keeps its exits measured from 990. With `stop_distance` the exit is a native stop-limit that far beyond the fill against the position, with its limit `stop_limit_offset` further on; with `target_distance` it is a limit that far beyond the fill in the position's favour. Give the stop pair or the target, not both. Prices are rounded to the tick, and nothing is sent until the opening order has filled. The order must sit under a `ThenPart`'s `each_fill` or `on_complete` child, or UBI refuses the plan with `from_fill_needs_then`.
#' @examples
#' \dontrun{
#' pricing <- FromFillPricing$new(
#'   stop_distance = 10.0,
#'   stop_limit_offset = 1.0
#' )
#' document <- pricing$document()
#' }
#' @export
FromFillPricing <- R6::R6Class(
  "FromFillPricing",
  inherit = PlanPart,
  public = list(
    #' @field stop_distance The numeric distance in rupees from the fill to the stop's trigger, or `NULL` for a target.
    stop_distance = NULL,
    #' @field stop_limit_offset The numeric distance in rupees past the stop's trigger to its limit, or `NULL` for a target.
    stop_limit_offset = NULL,
    #' @field target_distance The numeric distance in rupees from the fill to the target's limit, or `NULL` for a stop.
    target_distance = NULL,

    #' @description
    #' Initialises the rule as a stop or as a target.
    #' @param stop_distance The numeric distance in rupees from the fill to the stop's trigger, given with `stop_limit_offset`, or `NULL` for a target.
    #' @param stop_limit_offset The numeric distance in rupees past the stop's trigger to its limit, given with `stop_distance`, or `NULL` for a target.
    #' @param target_distance The numeric distance in rupees from the fill to the target's limit, or `NULL` for a stop.
    #' @return A new `FromFillPricing` object.
    initialize = function(
      stop_distance = NULL,
      stop_limit_offset = NULL,
      target_distance = NULL
    ) {
      self$stop_distance <- stop_distance
      self$stop_limit_offset <- stop_limit_offset
      self$target_distance <- target_distance
    },

    #' @description
    #' Builds the `from_fill` pricing object UBI reads, holding every setting that is not `NULL`.
    #' @return A named list with the single key `from_fill`, whose value holds `stop_distance`, `stop_limit_offset` and `target_distance` when each is set.
    #' @examples
    #' \dontrun{
    #' pricing <- FromFillPricing$new(
    #'   stop_distance = 10.0,
    #'   stop_limit_offset = 1.0
    #' )
    #' print(pricing$document())
    #'
    #' part <- ThenPart$new(
    #'   first = OrderPart$new(),
    #'   each_fill = EitherPart$new(
    #'     children = list(
    #'       OrderPart$new(
    #'         side = "protect",
    #'         pricing = FromFillPricing$new(
    #'           stop_distance = 10.0,
    #'           stop_limit_offset = 1.0
    #'         )
    #'       ),
    #'       OrderPart$new(
    #'         side = "protect",
    #'         pricing = FromFillPricing$new(
    #'           target_distance = 20.0
    #'         )
    #'       )
    #'     ),
    #'     sibling_rule = "reduce"
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$stop_distance)) {
        settings[["stop_distance"]] <- self$stop_distance
      }
      if (!is.null(self$stop_limit_offset)) {
        settings[["stop_limit_offset"]] <- self$stop_limit_offset
      }
      if (!is.null(self$target_distance)) {
        settings[["target_distance"]] <- self$target_distance
      }
      list(
        from_fill = settings
      )
    }
  )
)
