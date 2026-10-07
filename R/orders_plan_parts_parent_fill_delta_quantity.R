#' A quantity that is what an option entry filled times that option's delta
#'
#' @description
#' The `parent_fill_delta` quantity of a plan: what a `then` join's first plan filled, scaled by the delta of the option the plan trades.
#'
#' It is for a delta hedge. The plan's own instrument must be an option, or UBI refuses the plan, and at each fill UBI works out the option's Black-76 delta at `volatility` percent, using the last price of the order's own instrument, usually the future, as the forward. The order must be a `then` join's child (`parent_fill_needs_then`), and an order with side `against_delta` must have this quantity (`against_delta_needs_delta`); that side sells against a bought call and buys against a bought put. With `whole_lots` the size is rounded to whole lots of the order's own instrument. An expired option, or a forward with no price, leaves the size as it was, and UBI tries again on every tick until the order has started. An order sized this way that names an instrument the first plan trades is refused with HTTP 400, because it would only trade back what was filled.
#' @examples
#' \dontrun{
#' part <- ThenPart$new(
#'   first = OrderPart$new(),
#'   each_fill = OrderPart$new(
#'     instrument = future,
#'     side = "against_delta",
#'     quantity = ParentFillDeltaQuantity$new(volatility = 12.5, whole_lots = TRUE)
#'   )
#' )
#' document <- part$document()
#' }
#' @export
ParentFillDeltaQuantity <- R6::R6Class(
  "ParentFillDeltaQuantity",
  inherit = PlanPart,
  public = list(
    #' @field volatility The numeric volatility in percent the delta is worked out at.
    volatility = NULL,
    #' @field whole_lots A logical that is `TRUE` to round the result to whole lots of the order's own instrument.
    whole_lots = NULL,

    #' @description
    #' Initialises the quantity with the volatility its delta is worked out at.
    #' @param volatility The numeric annual volatility in percent above zero, such as 12.5.
    #' @param whole_lots A logical that is `TRUE` to round to whole lots of the order's own instrument.
    #' @return A new `ParentFillDeltaQuantity` object.
    initialize = function(
      volatility,
      whole_lots = FALSE
    ) {
      self$volatility <- volatility
      self$whole_lots <- whole_lots
    },

    #' @description
    #' Builds the `parent_fill_delta` quantity UBI reads.
    #' @return A named list with the single key `parent_fill_delta`, whose value holds `volatility`, and `whole_lots` when it is `TRUE`.
    #' @examples
    #' \dontrun{
    #' part <- ThenPart$new(
    #'   first = OrderPart$new(),
    #'   each_fill = OrderPart$new(
    #'     side = "against_delta",
    #'     quantity = ParentFillDeltaQuantity$new(
    #'       volatility = 12.5,
    #'       whole_lots = TRUE
    #'     )
    #'   )
    #' )
    #' print(part$document())
    #'
    #' quantity <- ParentFillDeltaQuantity$new(volatility = 18.0)
    #' print(quantity$document())
    #' }
    document = function() {
      settings <- list(
        volatility = self$volatility
      )
      if (isTRUE(self$whole_lots)) {
        settings[["whole_lots"]] <- TRUE
      }
      list(
        parent_fill_delta = settings
      )
    }
  )
)
