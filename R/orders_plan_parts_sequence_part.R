#' Several plans run one after another, each starting once the one before is done
#'
#' @description
#' The `sequence` join of a plan: two to twenty-five plans run one after another.
#'
#' Each child starts only once the one before it is done, whether it filled or ended, so a sequence is how a plan waits for one order to finish before the next is even considered. A sequence join cannot be a `then` join's child, because that child is sized to the first plan's fills.
#' @examples
#' \dontrun{
#' part <- SequencePart$new(
#'   children = list(
#'     OrderPart$new(trigger = TimeAt$new("10:00")),
#'     OrderPart$new(trigger = TimeAt$new("14:00"))
#'   )
#' )
#' document <- part$document()
#' }
#' @export
SequencePart <- R6::R6Class(
  "SequencePart",
  inherit = PlanPart,
  public = list(
    #' @field children The list of `PlanPart` nodes, in the order they run.
    children = NULL,

    #' @description
    #' Initialises the join with its children.
    #' @param children A list of two to twenty-five `PlanPart` nodes, each an `OrderPart` or another join, in the order they run.
    #' @return A new `SequencePart` object.
    initialize = function(children) {
      self$children <- children
    },

    #' @description
    #' Builds the `sequence` node UBI reads.
    #' @return A named list with the single key `sequence`, whose value holds `children`.
    #' @examples
    #' \dontrun{
    #' part <- SequencePart$new(
    #'   children = list(
    #'     OrderPart$new(
    #'       trigger = PriceCrosses$new(level = 995.0)
    #'     ),
    #'     OrderPart$new(
    #'       trigger = PriceCrosses$new(level = 990.0)
    #'     )
    #'   )
    #' )
    #' print(part$document())
    #'
    #' part <- SequencePart$new(
    #'   children = list(
    #'     ThenPart$new(
    #'       first = OrderPart$new(),
    #'       each_fill = OrderPart$new(
    #'         side = "protect",
    #'         pricing = NativeStopPricing$new(
    #'           trigger_price = 990.0,
    #'           limit_price = 988.0
    #'         )
    #'       )
    #'     ),
    #'     OrderPart$new(trigger = TimeAt$new("14:00"))
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      child_documents <- list()
      for (child in self$children) {
        child_documents[[length(child_documents) + 1]] <- child$document()
      }
      list(
        sequence = list(
          children = child_documents
        )
      )
    }
  )
)
