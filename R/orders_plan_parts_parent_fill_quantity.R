#' A quantity that is a ratio of what the first plan of a `then` join has filled
#'
#' @description
#' The `parent_fill` quantity of a plan: what a `then` join's first plan has filled, scaled by a ratio.
#'
#' It is only for an order that is a `then` join's child, which UBI checks as `parent_fill_needs_then`. The child is resized at every fill of the first plan to `ratio` times what has filled, and with `whole_lots` the result is rounded to whole lots of the child's own instrument, so a size under one lot waits for more fills and is cancelled once the first plan has finished. An order sized this way that names an instrument the first plan trades is refused with HTTP 400, because it would only trade back what was filled. This is how a hedge on another instrument follows an entry.
#' @examples
#' \dontrun{
#' part <- ThenPart$new(
#'   first = OrderPart$new(),
#'   each_fill = OrderPart$new(
#'     instrument = hedge,
#'     transaction_type = "sell",
#'     quantity = ParentFillQuantity$new(ratio = 0.5, whole_lots = TRUE)
#'   )
#' )
#' document <- part$document()
#' }
#' @export
ParentFillQuantity <- R6::R6Class(
  "ParentFillQuantity",
  inherit = PlanPart,
  public = list(
    #' @field ratio The numeric ratio above zero applied to what filled, or `NULL` for UBI's default of 1.
    ratio = NULL,
    #' @field whole_lots A logical that is `TRUE` to round the result to whole lots of the order's own instrument.
    whole_lots = NULL,

    #' @description
    #' Initialises the quantity with its ratio.
    #' @param ratio The numeric ratio above zero, such as 0.5 for half of what filled, or `NULL` for UBI's default of 1.
    #' @param whole_lots A logical that is `TRUE` to round to whole lots of the order's own instrument, waiting for more fills while the size is under one lot and cancelling the order once the first plan has finished.
    #' @return A new `ParentFillQuantity` object.
    initialize = function(
      ratio = NULL,
      whole_lots = FALSE
    ) {
      self$ratio <- ratio
      self$whole_lots <- whole_lots
    },

    #' @description
    #' Builds the `parent_fill` quantity UBI reads.
    #' @return A named list with the single key `parent_fill`, whose value holds `ratio` when it is not `NULL` and `whole_lots` when it is `TRUE`.
    #' @examples
    #' \dontrun{
    #' part <- ThenPart$new(
    #'   first = OrderPart$new(),
    #'   each_fill = OrderPart$new(
    #'     transaction_type = "sell",
    #'     quantity = ParentFillQuantity$new(
    #'       ratio = 0.5,
    #'       whole_lots = TRUE
    #'     )
    #'   )
    #' )
    #' print(part$document())
    #'
    #' print(ParentFillQuantity$new()$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$ratio)) {
        settings[["ratio"]] <- self$ratio
      }
      if (isTRUE(self$whole_lots)) {
        settings[["whole_lots"]] <- TRUE
      }
      list(
        parent_fill = settings
      )
    }
  )
)
