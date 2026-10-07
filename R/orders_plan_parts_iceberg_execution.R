#' An execution that shows a small piece of the order at a time and sends the next once it has filled
#'
#' @description
#' The `iceberg` execution of a plan: only part of the order shown at a time.
#'
#' The order is sent as pieces of `visible_quantity`, the next only once the last has filled. Each piece may vary by up to `randomise_percent` either way, worked out from the parent's id and the number of pieces sent, so another trader cannot spot a repeating size; UBI's default is 0, no variation, and a varied piece is brought to the nearest whole number of lots, at least one. A piece that is cancelled or rejected rather than filled stops the iceberg.
#'
#' An iceberg can nest on either side. As the outer execution it releases its pieces as slices for an inner one to work, and as the inner execution it shows each slice of a `TwapExecution`, `VwapExecution`, `FrontLoadedExecution`, `ParticipationExecution` or another iceberg a little at a time.
#' @examples
#' \dontrun{
#' execution <- IcebergExecution$new(visible_quantity = 10)
#' part <- OrderPart$new(execution = execution)
#' document <- part$document()
#' }
#' @export
IcebergExecution <- R6::R6Class(
  "IcebergExecution",
  inherit = PlanPart,
  public = list(
    #' @field visible_quantity The integer size of each piece before any variation, at least 1.
    visible_quantity = NULL,
    #' @field randomise_percent The integer percentage, 0 to 99, by which a piece may vary either way, or `NULL` for UBI's default of 0.
    randomise_percent = NULL,

    #' @description
    #' Initialises the execution with its piece size.
    #' @param visible_quantity The integer size of each piece before any variation, at least 1.
    #' @param randomise_percent The integer percentage, 0 to 99, by which a piece may vary either way, or `NULL` for UBI's default of 0.
    #' @return A new `IcebergExecution` object.
    initialize = function(
      visible_quantity,
      randomise_percent = NULL
    ) {
      self$visible_quantity <- visible_quantity
      self$randomise_percent <- randomise_percent
    },

    #' @description
    #' Builds the `iceberg` execution object UBI reads.
    #' @return A named list with the single key `iceberg`, whose value holds `visible_quantity` and, when it is set, `randomise_percent`.
    #' @examples
    #' \dontrun{
    #' execution <- IcebergExecution$new(visible_quantity = 10)
    #' print(execution$document())
    #'
    #' execution <- IcebergExecution$new(
    #'   visible_quantity = 50,
    #'   randomise_percent = 20
    #' )
    #' print(execution$document())
    #'
    #' part <- OrderPart$new(
    #'   execution = TwapExecution$new(
    #'     slices = 6,
    #'     over_minutes = 60
    #'   ),
    #'   inner_execution = IcebergExecution$new(
    #'     visible_quantity = 10
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      settings[["visible_quantity"]] <- self$visible_quantity
      if (!is.null(self$randomise_percent)) {
        settings[["randomise_percent"]] <- self$randomise_percent
      }
      list(
        iceberg = settings
      )
    }
  )
)
