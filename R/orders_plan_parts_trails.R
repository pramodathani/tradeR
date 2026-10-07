#' A condition that holds once the last price has pulled back from its best by a distance
#'
#' @description
#' The `trails` trigger of a plan: the last price pulling back from its best by a distance.
#'
#' For an order sent as a sell, the best is the highest price seen and the pullback a fall; for a buy, the lowest price seen and a rise. It is a trailing stop kept inside UBI's order engine, so the order it fires can be priced any way, but it does nothing while the engine is down. Give exactly one of `points` and `percent`.
#' @examples
#' \dontrun{
#' condition <- Trails$new(points = 5.0)
#' document <- condition$document()
#' }
#' @export
Trails <- R6::R6Class(
  "Trails",
  inherit = PlanPart,
  public = list(
    #' @field points The numeric distance in rupees, or `NULL` when `percent` is given.
    points = NULL,
    #' @field percent The numeric distance as a percentage of the price, or `NULL` when `points` is given.
    percent = NULL,

    #' @description
    #' Initialises the condition with its distance.
    #' @param points The numeric distance in rupees, or `NULL` when `percent` is given.
    #' @param percent The numeric distance as a percentage of the price, or `NULL` when `points` is given.
    #' @return A new `Trails` object.
    initialize = function(
      points = NULL,
      percent = NULL
    ) {
      self$points <- points
      self$percent <- percent
    },

    #' @description
    #' Builds the `trails` condition UBI reads.
    #' @return A named list with the single key `trails`, whose value holds whichever of `points` and `percent` is set.
    #' @examples
    #' \dontrun{
    #' print(Trails$new(points = 5.0)$document())
    #'
    #' print(Trails$new(percent = 1.5)$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$points)) {
        settings[["points"]] <- self$points
      }
      if (!is.null(self$percent)) {
        settings[["percent"]] <- self$percent
      }
      list(
        trails = settings
      )
    }
  )
)
