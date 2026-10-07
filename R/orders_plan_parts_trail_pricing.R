#' A pricing rule that rests a stop-limit at the broker and trails it behind the market
#'
#' @description
#' The `trail` pricing rule of a plan: a stop-limit at the broker that follows the market and never moves back.
#'
#' The stop is placed `points` behind the last price, or `percent` of it, and is moved after the best price seen: a sell stop follows the highest price up and a buy stop the lowest price down. It moves only when it can move by at least `step_ticks`, and every move passes UBI's repricing throttle and rate budget. Give exactly one of `points` and `percent`.
#'
#' With `average_true_range`, the distance is a multiple of the average true range of bars UBI builds from its own ticks since the order started, and `points` is used until enough bars have closed, so this form takes `points` rather than `percent`.
#' @examples
#' \dontrun{
#' pricing <- TrailPricing$new(points = 5.0, limit_offset = 1.0)
#' document <- pricing$document()
#' }
#' @export
TrailPricing <- R6::R6Class(
  "TrailPricing",
  inherit = PlanPart,
  public = list(
    #' @field limit_offset The numeric distance in rupees between the stop's trigger and its limit.
    limit_offset = NULL,
    #' @field points The numeric trailing distance in rupees, or `NULL` when `percent` is given.
    points = NULL,
    #' @field percent The numeric trailing distance as a percentage of the price, or `NULL` when `points` is given.
    percent = NULL,
    #' @field step_ticks The integer smallest move in ticks, or `NULL` for UBI's default of 1.
    step_ticks = NULL,
    #' @field average_true_range A logical that is `TRUE` to trail by a multiple of the average true range rather than a fixed distance.
    average_true_range = NULL,
    #' @field bar_minutes The numeric length in minutes of the bars the average true range is measured over, or `NULL` for UBI's default of 5.
    bar_minutes = NULL,
    #' @field periods The integer number of bars averaged, from 2 to 49 because UBI keeps the last 50 bars, or `NULL` for UBI's default of 14.
    periods = NULL,
    #' @field average_true_range_multiple The numeric multiple of the average true range to trail by, or `NULL` for UBI's default of 2.
    average_true_range_multiple = NULL,

    #' @description
    #' Initialises the rule with its distance and limit offset.
    #' @param limit_offset The numeric distance in rupees between the stop's trigger and its limit.
    #' @param points The numeric trailing distance in rupees, or `NULL` when `percent` is given.
    #' @param percent The numeric trailing distance as a percentage of the price, or `NULL` when `points` is given.
    #' @param step_ticks The integer smallest move in ticks, or `NULL` for UBI's default of 1.
    #' @param average_true_range A logical that is `TRUE` to trail by a multiple of the average true range, with `points` as the distance until enough bars have closed.
    #' @param bar_minutes The numeric length in minutes of each bar, used with `average_true_range`, or `NULL` for UBI's default of 5.
    #' @param periods The integer number of bars averaged, from 2 to 49, used with `average_true_range`, or `NULL` for UBI's default of 14.
    #' @param average_true_range_multiple The numeric multiple of the average true range to trail by, used with `average_true_range`, or `NULL` for UBI's default of 2.
    #' @return A new `TrailPricing` object.
    initialize = function(
      limit_offset,
      points = NULL,
      percent = NULL,
      step_ticks = NULL,
      average_true_range = FALSE,
      bar_minutes = NULL,
      periods = NULL,
      average_true_range_multiple = NULL
    ) {
      self$limit_offset <- limit_offset
      self$points <- points
      self$percent <- percent
      self$step_ticks <- step_ticks
      self$average_true_range <- average_true_range
      self$bar_minutes <- bar_minutes
      self$periods <- periods
      self$average_true_range_multiple <- average_true_range_multiple
    },

    #' @description
    #' Builds the `trail` pricing object UBI reads.
    #' @return A named list with the single key `trail`, whose value holds `limit_offset`, whichever of `points` and `percent` is set, `step_ticks` when it is set, and an `atr` object with `bar_minutes`, `periods` and `multiple` when `average_true_range` is `TRUE`.
    #' @examples
    #' \dontrun{
    #' pricing <- TrailPricing$new(points = 5.0, limit_offset = 1.0)
    #' print(pricing$document())
    #'
    #' pricing <- TrailPricing$new(
    #'   percent = 2.0,
    #'   limit_offset = 1.0,
    #'   step_ticks = 4
    #' )
    #' print(pricing$document())
    #'
    #' pricing <- TrailPricing$new(
    #'   points = 5.0,
    #'   limit_offset = 1.0,
    #'   average_true_range = TRUE,
    #'   bar_minutes = 10,
    #'   average_true_range_multiple = 3
    #' )
    #' print(pricing$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$points)) {
        settings[["points"]] <- self$points
      }
      if (!is.null(self$percent)) {
        settings[["percent"]] <- self$percent
      }
      settings[["limit_offset"]] <- self$limit_offset
      if (!is.null(self$step_ticks)) {
        settings[["step_ticks"]] <- self$step_ticks
      }
      if (isTRUE(self$average_true_range)) {
        average_true_range_settings <- structure(list(), names = character(0))
        if (!is.null(self$bar_minutes)) {
          average_true_range_settings[["bar_minutes"]] <- self$bar_minutes
        }
        if (!is.null(self$periods)) {
          average_true_range_settings[["periods"]] <- self$periods
        }
        if (!is.null(self$average_true_range_multiple)) {
          average_true_range_settings[["multiple"]] <-
            self$average_true_range_multiple
        }
        settings[["atr"]] <- average_true_range_settings
      }
      list(
        trail = settings
      )
    }
  )
)
