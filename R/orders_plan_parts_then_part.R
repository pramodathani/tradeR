#' A first plan and the child plan it starts when it fills
#'
#' @description
#' The `then` join of a plan: a first plan, and a child plan started once the first one fills.
#'
#' With `each_fill`, the child starts on the first plan's first fill, sized to what has filled, and is resized as more fills arrive, which is how a stop or a target follows an entry. A `protect` or `close` order in the child works against the side the first plan actually filled on, and when both sides of a two-sided entry filled and the later side filled more, UBI cancels the exits resting on the old side and sends them again on the new side, priced from the fills on the side now held. An exit that has finished is sent again only once its target grows past what it had when it finished, so an exit the exchange cancels is not simply sent again. With `on_complete`, the child waits until the first plan is done. Give exactly one of the two.
#' @examples
#' \dontrun{
#' part <- ThenPart$new(
#'   first = OrderPart$new(),
#'   each_fill = OrderPart$new(
#'     side = "protect",
#'     pricing = TrailPricing$new(points = 5.0, limit_offset = 1.0)
#'   )
#' )
#' document <- part$document()
#' }
#' @export
ThenPart <- R6::R6Class(
  "ThenPart",
  inherit = PlanPart,
  public = list(
    #' @field first The `PlanPart` node that runs first.
    first = NULL,
    #' @field each_fill The `PlanPart` node started on the first fill and resized with every fill, or `NULL`.
    each_fill = NULL,
    #' @field on_complete The `PlanPart` node started once the first plan is done, or `NULL`.
    on_complete = NULL,
    #' @field cancel_first_on_child_fill A logical that is `TRUE` to cancel whatever of the first plan is still working once the child fills anything.
    cancel_first_on_child_fill = NULL,

    #' @description
    #' Initialises the join with its two plans.
    #' @param first The `PlanPart` node that runs first, an `OrderPart` or another join.
    #' @param each_fill The `PlanPart` node to start on the first fill and resize with every fill, or `NULL` when `on_complete` is given.
    #' @param on_complete The `PlanPart` node to start once the first plan is done, or `NULL` when `each_fill` is given.
    #' @param cancel_first_on_child_fill A logical that is `TRUE` to cancel whatever of the first plan is still working once the child fills anything.
    #' @return A new `ThenPart` object.
    initialize = function(
      first,
      each_fill = NULL,
      on_complete = NULL,
      cancel_first_on_child_fill = FALSE
    ) {
      self$first <- first
      self$each_fill <- each_fill
      self$on_complete <- on_complete
      self$cancel_first_on_child_fill <- cancel_first_on_child_fill
    },

    #' @description
    #' Builds the `then` node UBI reads.
    #' @return A named list with the single key `then`, whose value holds `first`, whichever of `each_fill` and `on_complete` is set, and `cancel_first_on_child_fill` when it is `TRUE`.
    #' @examples
    #' \dontrun{
    #' part <- ThenPart$new(
    #'   first = OrderPart$new(),
    #'   each_fill = OrderPart$new(
    #'     side = "protect",
    #'     pricing = TrailPricing$new(points = 5.0, limit_offset = 1.0)
    #'   )
    #' )
    #' print(part$document())
    #'
    #' part <- ThenPart$new(
    #'   first = OrderPart$new(),
    #'   on_complete = OrderPart$new(
    #'     side = "protect",
    #'     pricing = FixedPricing$new(price = 1010.0, order_type = "LIMIT")
    #'   ),
    #'   cancel_first_on_child_fill = TRUE
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- list(
        first = self$first$document()
      )
      if (!is.null(self$each_fill)) {
        settings[["each_fill"]] <- self$each_fill$document()
      }
      if (!is.null(self$on_complete)) {
        settings[["on_complete"]] <- self$on_complete$document()
      }
      if (isTRUE(self$cancel_first_on_child_fill)) {
        settings[["cancel_first_on_child_fill"]] <- TRUE
      }
      list(
        then = settings
      )
    }
  )
)
