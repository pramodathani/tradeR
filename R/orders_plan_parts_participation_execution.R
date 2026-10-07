#' An execution that sends a share of the market's traded volume on each tick
#'
#' @description
#' The `participation` execution of a plan: a fixed share of the volume the market itself trades.
#'
#' On each tick it sends `percent` of the volume traded since its last slice, counting from the live quote's cumulative `volume` when the order starts working, which is as soon as its trigger holds, until the order is sent or `most_slices` have gone; UBI's default for `most_slices` is 60. Since UBI's fix of 2026-10-02 each slice is rounded down to whole lots of the instrument at the chosen broker, and only the volume a slice accounts for is used up, so a share under one lot, or the part of a lot a slice could not send, counts towards the next slice; when the day's volume falls, counting starts again from there. The unfilled part of a cancelled slice is sent again by later slices, and a rejected slice stops the order.
#'
#' Participation can be the outer execution of a nested pair, releasing its slices for an inner `IcebergExecution`, `TwapExecution`, `VwapExecution` or `FrontLoadedExecution` to work, but not the inner one. It cannot carry a resting stop.
#' @examples
#' \dontrun{
#' execution <- ParticipationExecution$new(percent = 10.0)
#' part <- OrderPart$new(execution = execution)
#' document <- part$document()
#' }
#' @export
ParticipationExecution <- R6::R6Class(
  "ParticipationExecution",
  inherit = PlanPart,
  public = list(
    #' @field percent The numeric share of traded volume to send, above zero and at most 100.
    percent = NULL,
    #' @field most_slices The integer most slices it will send, at least 1, or `NULL` for UBI's default of 60.
    most_slices = NULL,

    #' @description
    #' Initialises the execution with its share of the volume.
    #' @param percent The numeric share of traded volume to send, above zero and at most 100.
    #' @param most_slices The integer most slices it will send, at least 1, or `NULL` for UBI's default of 60.
    #' @return A new `ParticipationExecution` object.
    initialize = function(
      percent,
      most_slices = NULL
    ) {
      self$percent <- percent
      self$most_slices <- most_slices
    },

    #' @description
    #' Builds the `participation` execution object UBI reads.
    #' @return A named list with the single key `participation`, whose value holds `percent` and, when it is set, `most_slices`.
    #' @examples
    #' \dontrun{
    #' execution <- ParticipationExecution$new(
    #'   percent = 10.0
    #' )
    #' print(execution$document())
    #'
    #' execution <- ParticipationExecution$new(
    #'   percent = 5.0,
    #'   most_slices = 20
    #' )
    #' print(execution$document())
    #'
    #' part <- OrderPart$new(
    #'   execution = ParticipationExecution$new(
    #'     percent = 15.0
    #'   ),
    #'   inner_execution = IcebergExecution$new(
    #'     visible_quantity = 10
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      settings[["percent"]] <- self$percent
      if (!is.null(self$most_slices)) {
        settings[["most_slices"]] <- self$most_slices
      }
      list(
        participation = settings
      )
    }
  )
)
