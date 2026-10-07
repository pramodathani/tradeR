#' A guard that keeps an order's limit from crossing the book
#'
#' @description
#' The `post_only` guard of a plan: a limit checked against the book before it is sent or moved, so that it rests rather than trades.
#'
#' A buy is passive below the best offer and a sell above the best bid. A limit that would cross is refused with `on_crossing` `refuse`, which ends the order, or moved back to its own side's touch with `rest`; a move of a resting order that would cross is skipped with `refuse` and held at the own touch with `rest`. Indian exchanges have no post-only flag, so the book can still move while the order is in flight. It goes in `OrderPart$new(guard = ...)`. UBI refuses it on a stop with `post_only_needs_limit`, and with pricing that means to trade at once, `MarketablePricing`, `ChasePricing`, a `PegPricing` to the `opposite_touch` or a market order, with `post_only_crosses`.
#' @examples
#' \dontrun{
#' guard <- PostOnlyGuard$new(on_crossing = "rest")
#' document <- guard$document()
#' }
#' @export
PostOnlyGuard <- R6::R6Class(
  "PostOnlyGuard",
  inherit = PlanPart,
  public = list(
    #' @field on_crossing The character action for a limit that would cross, `refuse` or `rest`, or `NULL` for UBI's default of `refuse`.
    on_crossing = NULL,

    #' @description
    #' Initialises the guard with what it does to a crossing limit.
    #' @param on_crossing The character action for a limit that would cross, `refuse` to end the order or `rest` to move it back to its own side's touch, or `NULL` for UBI's default of `refuse`.
    #' @return A new `PostOnlyGuard` object.
    initialize = function(on_crossing = NULL) {
      self$on_crossing <- on_crossing
    },

    #' @description
    #' Builds the `post_only` guard object UBI reads in an order's guard list.
    #' @return A named list with the single key `post_only`, whose value holds `on_crossing` when it is set.
    #' @examples
    #' \dontrun{
    #' guard <- PostOnlyGuard$new()
    #' print(guard$document())
    #'
    #' part <- OrderPart$new(
    #'   pricing = PegPricing$new(offset_ticks = 1),
    #'   guard = PostOnlyGuard$new(on_crossing = "rest")
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$on_crossing)) {
        settings[["on_crossing"]] <- self$on_crossing
      }
      list(
        post_only = settings
      )
    }
  )
)
