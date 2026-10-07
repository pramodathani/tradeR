#' When an order of a plan stops working, and what is done with it then
#'
#' @description
#' The lifetime of an order in a plan: when it stops, which part of its life that bounds, and what is done then.
#'
#' A lifetime ends exactly one way: `at_time`, a time of day on the instrument's next trading day; `after_minutes`, counted from when the plan is placed; `after_days`, 1 to 365 days of 24 hours from then, which keeps the plan alive across trading days; or `when`, any trigger condition, checked on every tick. `applies_to` says whether the end bounds the wait for the trigger, the time the order works after it is sent, or both, which is UBI's default. An order still waiting when its end comes is done as expired. An order working then ends by `on_end`: `cancel`, UBI's default, cancels what rests and keeps what filled; `marketable` moves what rests two ticks past the other side's touch so it fills, which a stop cannot do; and `close_filled` cancels what rests and closes what filled at market, which only a plan that is this one order can do, and not an order that protects a position. A part ended by `close_filled` is done with the reason `closed`, or `expired` when nothing had filled.
#'
#' Unlike the other parts, a lifetime is an entry of the order's `lifetime` list rather than a value under one key, so its `document()` holds the settings directly. A `RepeatPart` with `until` gives each copy a lifetime of its own, so an order repeated that way takes no `Lifetime`.
#' @examples
#' \dontrun{
#' ending <- Lifetime$new(at_time = "14:30", on_end = "marketable")
#' document <- ending$document()
#' }
#' @export
Lifetime <- R6::R6Class(
  "Lifetime",
  inherit = PlanPart,
  public = list(
    #' @field at_time The character time of day the order ends at, such as `14:30`, or `NULL`.
    at_time = NULL,
    #' @field after_minutes The numeric minutes after placing that the order ends, or `NULL`.
    after_minutes = NULL,
    #' @field after_days The integer days after placing that the order ends, from 1 to 365, or `NULL`.
    after_days = NULL,
    #' @field when The `PlanPart` condition that ends the order when it holds, or `NULL`.
    when = NULL,
    #' @field applies_to The character part of the order's life the end bounds, `waiting`, `working` or `both`, or `NULL` for `both`.
    applies_to = NULL,
    #' @field on_end The character action taken on a working order, `cancel`, `marketable` or `close_filled`, or `NULL` for `cancel`.
    on_end = NULL,

    #' @description
    #' Initialises the lifetime with its end and settings.
    #'
    #' Exactly one of `at_time`, `after_minutes`, `after_days` and `when` must be given; UBI refuses none or more than one.
    #' @param at_time The character time of day in India the order ends at, such as `14:30`, on the instrument's next trading day, or `NULL`.
    #' @param after_minutes The numeric minutes after the plan is placed that the order ends, above zero, or `NULL`. UBI refuses minutes on a day the instrument does not trade.
    #' @param after_days The integer days of 24 hours after the plan is placed that the order ends, from 1 to 365, or `NULL`.
    #' @param when A `PlanPart` trigger condition, such as `PriceCrosses`, `TimeAt`, `AccountCondition` or `AnyCondition`, that ends the order when it holds, or `NULL`.
    #' @param applies_to The character part of the order's life the end bounds, `waiting` for the wait for its trigger, `working` for the time after it is sent, or `both`, or `NULL` for UBI's default of `both`.
    #' @param on_end The character action taken on an order still working, `cancel` to cancel what rests, `marketable` to move what rests past the other side's touch, or `close_filled` to cancel what rests and close what filled at market, or `NULL` for UBI's default of `cancel`.
    #' @return A new `Lifetime` object.
    initialize = function(
      at_time = NULL,
      after_minutes = NULL,
      after_days = NULL,
      when = NULL,
      applies_to = NULL,
      on_end = NULL
    ) {
      self$at_time <- at_time
      self$after_minutes <- after_minutes
      self$after_days <- after_days
      self$when <- when
      self$applies_to <- applies_to
      self$on_end <- on_end
    },

    #' @description
    #' Builds the lifetime entry UBI reads, holding every setting that is not `NULL`.
    #' @return A named list holding each setting that is set, with `when` as its condition's object. It is one entry of the order's `lifetime` list, which `OrderPart` builds.
    #' @examples
    #' \dontrun{
    #' ending <- Lifetime$new(at_time = "14:30", on_end = "marketable")
    #' print(ending$document())
    #'
    #' part <- OrderPart$new(
    #'   trigger = PriceCrosses$new(level = 1010.0),
    #'   lifetime = Lifetime$new(
    #'     when = AnyCondition$new(
    #'       list(
    #'         PriceCrosses$new(
    #'           level = 990.0,
    #'           direction = "at_or_below"
    #'         ),
    #'         TimeAt$new("15:10")
    #'       )
    #'     ),
    #'     applies_to = "waiting",
    #'     on_end = "cancel"
    #'   )
    #' )
    #' print(part$document())
    #'
    #' part <- OrderPart$new(
    #'   lifetime = Lifetime$new(
    #'     after_minutes = 30,
    #'     on_end = "close_filled"
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$at_time)) {
        settings[["at_time"]] <- self$at_time
      }
      if (!is.null(self$after_minutes)) {
        settings[["after_minutes"]] <- self$after_minutes
      }
      if (!is.null(self$after_days)) {
        settings[["after_days"]] <- self$after_days
      }
      if (!is.null(self$when)) {
        settings[["when"]] <- self$when$document()
      }
      if (!is.null(self$applies_to)) {
        settings[["applies_to"]] <- self$applies_to
      }
      if (!is.null(self$on_end)) {
        settings[["on_end"]] <- self$on_end
      }
      settings
    }
  )
)
