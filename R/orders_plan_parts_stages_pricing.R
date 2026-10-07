#' A pricing rule that rests a stop-limit at the broker and steps it through profit milestones
#'
#' @description
#' The `stages` pricing rule of a plan: a stop-limit at the broker that profit milestones move in the position's favour.
#'
#' The stop starts at `stop_price`, with its limit `limit_offset` past the trigger, and rests at the broker the whole time. Each `StageRule` names a gain from `entry_price`, and once the market reaches it the stop is modified to the rule's `stop_at_gain`, or handed to a trail of `trail_points`. The stop only ever moves in the position's favour, by at least `step_ticks`, so a rule that would loosen it is skipped. UBI takes 1 to 20 rules with rising gains, each with exactly one of `stop_at_gain` and `trail_points`, and only the last may trail. Like every stop, it cannot be split into pieces.
#' @examples
#' \dontrun{
#' pricing <- StagesPricing$new(
#'   entry_price = 1000.0,
#'   stop_price = 990.0,
#'   limit_offset = 1.0,
#'   rules = list(
#'     StageRule$new(gain = 10.0, stop_at_gain = 0.0),
#'     StageRule$new(gain = 25.0, trail_points = 8.0)
#'   )
#' )
#' document <- pricing$document()
#' }
#' @export
StagesPricing <- R6::R6Class(
  "StagesPricing",
  inherit = PlanPart,
  public = list(
    #' @field entry_price The numeric price in rupees the gains are measured from.
    entry_price = NULL,
    #' @field stop_price The numeric price in rupees where the stop starts.
    stop_price = NULL,
    #' @field limit_offset The numeric distance in rupees between the stop's trigger and its limit.
    limit_offset = NULL,
    #' @field rules The list of `PlanPart` milestones, `StageRule` objects, in order of rising gain.
    rules = NULL,
    #' @field step_ticks The integer smallest move in ticks, or `NULL` for UBI's default of 1.
    step_ticks = NULL,

    #' @description
    #' Initialises the rule with its prices and milestones.
    #' @param entry_price The numeric price in rupees the gains are measured from, usually where the position was opened.
    #' @param stop_price The numeric price in rupees where the stop starts.
    #' @param limit_offset The numeric distance in rupees between the stop's trigger and its limit.
    #' @param rules A list of 1 to 20 `StageRule` objects, each with a larger gain than the one before, of which only the last may trail.
    #' @param step_ticks The integer smallest move in ticks, or `NULL` for UBI's default of 1.
    #' @return A new `StagesPricing` object.
    initialize = function(
      entry_price,
      stop_price,
      limit_offset,
      rules,
      step_ticks = NULL
    ) {
      self$entry_price <- entry_price
      self$stop_price <- stop_price
      self$limit_offset <- limit_offset
      self$rules <- rules
      self$step_ticks <- step_ticks
    },

    #' @description
    #' Builds the `stages` pricing object UBI reads.
    #' @return A named list with the single key `stages`, whose value holds `entry_price`, `stop_price`, `limit_offset`, `step_ticks` when it is set, and `rules` as a list of each milestone's object.
    #' @examples
    #' \dontrun{
    #' pricing <- StagesPricing$new(
    #'   entry_price = 1000.0,
    #'   stop_price = 990.0,
    #'   limit_offset = 1.0,
    #'   rules = list(
    #'     StageRule$new(gain = 10.0, stop_at_gain = 0.0),
    #'     StageRule$new(gain = 20.0, stop_at_gain = 5.0)
    #'   )
    #' )
    #' print(pricing$document())
    #'
    #' pricing <- StagesPricing$new(
    #'   entry_price = 1000.0,
    #'   stop_price = 990.0,
    #'   limit_offset = 1.0,
    #'   rules = list(
    #'     StageRule$new(gain = 10.0, stop_at_gain = 0.0),
    #'     StageRule$new(gain = 25.0, trail_points = 8.0)
    #'   ),
    #'   step_ticks = 2
    #' )
    #' print(pricing$document())
    #' }
    document = function() {
      rule_documents <- list()
      for (rule in self$rules) {
        rule_documents[[length(rule_documents) + 1]] <- rule$document()
      }
      settings <- list(
        entry_price = self$entry_price,
        stop_price = self$stop_price,
        limit_offset = self$limit_offset
      )
      if (!is.null(self$step_ticks)) {
        settings[["step_ticks"]] <- self$step_ticks
      }
      settings[["rules"]] <- rule_documents
      list(
        stages = settings
      )
    }
  )
)
