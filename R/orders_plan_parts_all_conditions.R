#' A group of trigger conditions that must all hold
#'
#' @description
#' The `all` trigger of a plan: a group of conditions that holds when every one of them holds.
#' @examples
#' \dontrun{
#' condition <- AllConditions$new(
#'   list(
#'     TimeAfter$new("10:00"),
#'     PriceCrosses$new(level = 995.0)
#'   )
#' )
#' document <- condition$document()
#' }
#' @export
AllConditions <- R6::R6Class(
  "AllConditions",
  inherit = PlanPart,
  public = list(
    #' @field conditions The list of `PlanPart` conditions in the group.
    conditions = NULL,

    #' @description
    #' Initialises the group with its conditions.
    #' @param conditions A list of `PlanPart` conditions, which may include other groups.
    #' @return A new `AllConditions` object.
    initialize = function(conditions) {
      self$conditions <- conditions
    },

    #' @description
    #' Builds the `all` group UBI reads.
    #' @return A named list with the single key `all`, whose value is the list of the conditions' objects.
    #' @examples
    #' \dontrun{
    #' condition <- AllConditions$new(
    #'   list(
    #'     TimeAfter$new("10:00"),
    #'     PriceCrosses$new(level = 995.0)
    #'   )
    #' )
    #' print(condition$document())
    #'
    #' condition <- AllConditions$new(
    #'   list(
    #'     TimeBefore$new("15:00"),
    #'     AnyCondition$new(
    #'       list(
    #'         PriceCrosses$new(level = 995.0, field = "bid"),
    #'         PriceCrosses$new(level = 995.0, field = "last")
    #'       )
    #'     )
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
        all = condition_documents
      )
    }
  )
)
