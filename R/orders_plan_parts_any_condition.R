#' A group of trigger conditions of which any one is enough
#'
#' @description
#' The `any` trigger of a plan: a group of conditions that holds when any one of them holds.
#' @examples
#' \dontrun{
#' condition <- AnyCondition$new(
#'   list(
#'     PriceCrosses$new(level = 990.0, direction = "at_or_below"),
#'     TimeAt$new("15:10")
#'   )
#' )
#' document <- condition$document()
#' }
#' @export
AnyCondition <- R6::R6Class(
  "AnyCondition",
  inherit = PlanPart,
  public = list(
    #' @field conditions The list of `PlanPart` conditions in the group.
    conditions = NULL,

    #' @description
    #' Initialises the group with its conditions.
    #' @param conditions A list of `PlanPart` conditions, which may include other groups.
    #' @return A new `AnyCondition` object.
    initialize = function(conditions) {
      self$conditions <- conditions
    },

    #' @description
    #' Builds the `any` group UBI reads.
    #' @return A named list with the single key `any`, whose value is the list of the conditions' objects.
    #' @examples
    #' \dontrun{
    #' condition <- AnyCondition$new(
    #'   list(
    #'     PriceCrosses$new(level = 990.0, direction = "at_or_below"),
    #'     TimeAt$new("15:10")
    #'   )
    #' )
    #' print(condition$document())
    #'
    #' condition <- AnyCondition$new(
    #'   list(
    #'     Trails$new(points = 5.0),
    #'     PriceCrosses$new(level = 990.0, direction = "at_or_below")
    #'   )
    #' )
    #' print(condition$document())
    #' }
    document = function() {
      condition_documents <- list()
      for (condition in self$conditions) {
        condition_documents[[length(condition_documents) + 1]] <-
          condition$document()
      }
      list(
        any = condition_documents
      )
    }
  )
)
