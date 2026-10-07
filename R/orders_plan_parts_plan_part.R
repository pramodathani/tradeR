#' One piece of a plan order, which can describe itself as the object UBI's order engine reads
#'
#' @description
#' The shared base of every part of a plan order.
#'
#' Every node, preset, trigger condition and pricing rule of a plan is a `PlanPart`, whose `document()` method gives the piece of UBI's `plan` object that the part stands for. The base holds no state of its own.
#' @examples
#' \dontrun{
#' part <- PriceCrosses$new(level = 995.0)
#' if (inherits(part, "PlanPart")) {
#'   document <- part$document()
#' }
#' }
#' @export
PlanPart <- R6::R6Class(
  "PlanPart",
  public = list(
    #' @description
    #' Builds the object UBI reads for this part.
    #' @return A named list holding exactly one key, the part's UBI name, whose value is the part's settings. The few parts that are entries of a list rather than named values, `Lifetime`, `PreOpenVenue`, `PaperVenue` and `StageRule`, hold their settings directly instead.
    #' @details Errors: signals `NotImplementedError` when the part is the base class itself, which stands for no part of a plan.
    #' @examples
    #' \dontrun{
    #' part <- PriceCrosses$new(level = 995.0)
    #' print(inherits(part, "PlanPart"))
    #' print(part$document())
    #'
    #' tryCatch(
    #'   PlanPart$new()$document(),
    #'   NotImplementedError = function(error) {
    #'     print(sprintf("Refused: %s", conditionMessage(error)))
    #'   }
    #' )
    #' }
    document = function() {
      message <- sprintf(
        "%s does not describe a part of a plan",
        class(self)[1]
      )
      ErrorCatalogue$raise("NotImplementedError", message)
    }
  )
)
