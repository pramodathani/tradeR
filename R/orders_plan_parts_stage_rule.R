#' One milestone of a stepped stop, an entry of the `rules` list of `StagesPricing`
#'
#' @description
#' One milestone of a `stages` stop: a gain that, once reached, moves the stop or hands it to a trail.
#'
#' The `gain` is measured from the stop's entry price in the position's favour. A rule with `stop_at_gain` moves the stop to that gain measured the same way, so 0 is breakeven, and a rule with `trail_points` hands the rest of the trade to an ordinary trail that many rupees behind. A rule takes exactly one of the two, and a trailing rule must be the last one.
#' @examples
#' \dontrun{
#' rule <- StageRule$new(gain = 10.0, stop_at_gain = 0.0)
#' entry <- rule$document()
#' }
#' @export
StageRule <- R6::R6Class(
  "StageRule",
  inherit = PlanPart,
  public = list(
    #' @field gain The numeric gain in rupees, from the entry price in the position's favour, that applies the rule.
    gain = NULL,
    #' @field stop_at_gain The numeric gain in rupees where the stop goes, below `gain`, with 0 for breakeven, or `NULL` when `trail_points` is given.
    stop_at_gain = NULL,
    #' @field trail_points The numeric distance in rupees the stop trails from here on, or `NULL` when `stop_at_gain` is given.
    trail_points = NULL,

    #' @description
    #' Initialises the milestone with its gain and what happens there.
    #' @param gain The numeric gain in rupees, above zero, from the entry price in the position's favour, that applies the rule.
    #' @param stop_at_gain The numeric gain in rupees where the stop goes, below `gain`, with 0 for breakeven and a negative value for a smaller loss, or `NULL` when `trail_points` is given.
    #' @param trail_points The numeric distance in rupees the stop trails behind the market from here on, or `NULL` when `stop_at_gain` is given.
    #' @return A new `StageRule` object.
    initialize = function(
      gain,
      stop_at_gain = NULL,
      trail_points = NULL
    ) {
      self$gain <- gain
      self$stop_at_gain <- stop_at_gain
      self$trail_points <- trail_points
    },

    #' @description
    #' Builds the milestone object UBI reads as one entry of a `stages` rule list.
    #' @return A named list holding `gain` and whichever of `stop_at_gain` and `trail_points` is set, directly rather than under a name, because it is an entry of a list.
    #' @examples
    #' \dontrun{
    #' rule <- StageRule$new(gain = 10.0, stop_at_gain = 0.0)
    #' print(rule$document())
    #'
    #' rule <- StageRule$new(gain = 30.0, trail_points = 5.0)
    #' print(rule$document())
    #' }
    document = function() {
      settings <- list(
        gain = self$gain
      )
      if (!is.null(self$stop_at_gain)) {
        settings[["stop_at_gain"]] <- self$stop_at_gain
      }
      if (!is.null(self$trail_points)) {
        settings[["trail_points"]] <- self$trail_points
      }
      settings
    }
  )
)
