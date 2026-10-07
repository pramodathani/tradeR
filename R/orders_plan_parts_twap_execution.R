#' An execution that sends equal slices at even intervals
#'
#' @description
#' The `twap` execution of a plan: equal slices sent on a clock, a time-weighted average price order.
#'
#' The quantity is cut into `slices`, from 2 to 60, and one is sent every `over_minutes` times 60 divided by `slices` seconds, the first at once. Units that do not divide evenly go to the earliest slices, each slice is worked out from the order's total when it falls due, so a total a join changes is spread over the slices still to come, and a slice that has not filled is left resting when the next goes. Slices are whole lots, and a slice that comes to nothing is skipped rather than stalling the order. The order starts working as soon as its trigger holds.
#'
#' A TWAP can be the outer execution of a nested pair, releasing slices that an inner `IcebergExecution`, `VwapExecution`, `FrontLoadedExecution` or another TWAP works, or the inner one, working each slice of an outer execution. It cannot carry a resting stop, because a stop protects the whole position at once.
#' @examples
#' \dontrun{
#' execution <- TwapExecution$new(slices = 6, over_minutes = 60)
#' part <- OrderPart$new(execution = execution)
#' document <- part$document()
#' }
#' @export
TwapExecution <- R6::R6Class(
  "TwapExecution",
  inherit = PlanPart,
  public = list(
    #' @field slices The integer number of slices, from 2 to 60.
    slices = NULL,
    #' @field over_minutes The numeric number of minutes the slices are spread across, above zero.
    over_minutes = NULL,

    #' @description
    #' Initialises the execution with its slices and its span.
    #' @param slices The integer number of slices, from 2 to 60.
    #' @param over_minutes The numeric number of minutes the slices are spread across, above zero.
    #' @return A new `TwapExecution` object.
    initialize = function(
      slices,
      over_minutes
    ) {
      self$slices <- slices
      self$over_minutes <- over_minutes
    },

    #' @description
    #' Builds the `twap` execution object UBI reads.
    #' @return A named list with the single key `twap`, whose value holds `slices` and `over_minutes`.
    #' @examples
    #' \dontrun{
    #' execution <- TwapExecution$new(slices = 6, over_minutes = 60)
    #' print(execution$document())
    #'
    #' part <- OrderPart$new(
    #'   pricing = MarketablePricing$new(buffer_ticks = 2),
    #'   execution = TwapExecution$new(
    #'     slices = 12,
    #'     over_minutes = 120
    #'   )
    #' )
    #' print(part$document())
    #'
    #' part <- OrderPart$new(
    #'   execution = TwapExecution$new(
    #'     slices = 4,
    #'     over_minutes = 40
    #'   ),
    #'   inner_execution = IcebergExecution$new(
    #'     visible_quantity = 25
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      list(
        twap = list(
          slices = self$slices,
          over_minutes = self$over_minutes
        )
      )
    }
  )
)
