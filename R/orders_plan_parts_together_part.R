#' Several plans started at once, each trading its own quantity
#'
#' @description
#' The `together` join of a plan: one to twenty-five plans started at once, each trading its own quantity.
#'
#' Unlike an `either` join, a fill on one child does nothing to the others, so a together join is how a plan sends a basket, a pair or a spread whose legs are independent. By default UBI's broker selector chooses a broker that can afford the whole group, and `hedge_benefit` prices hedged legs as one position. With `done_when` set to `any`, the rest are cancelled once one child is done. A together join cannot be a `then` join's child, because that child is sized to the first plan's fills.
#' @examples
#' \dontrun{
#' part <- TogetherPart$new(
#'   children = list(
#'     OrderPart$new(transaction_type = "buy"),
#'     OrderPart$new(transaction_type = "sell")
#'   ),
#'   hedge_benefit = TRUE
#' )
#' document <- part$document()
#' }
#' @export
TogetherPart <- R6::R6Class(
  "TogetherPart",
  inherit = PlanPart,
  public = list(
    #' @field children The list of `PlanPart` nodes started at once.
    children = NULL,
    #' @field group_margin A logical that is `FALSE` to let each child choose its broker alone, or `NULL` for UBI's default of `TRUE`.
    group_margin = NULL,
    #' @field hedge_benefit A logical that is `TRUE` to price hedged children together as one position when checking the broker can afford them.
    hedge_benefit = NULL,
    #' @field done_when The character rule, `all` or `any`, for when the join is done, or `NULL` for UBI's default of `all`.
    done_when = NULL,

    #' @description
    #' Initialises the join with its children and settings.
    #' @param children A list of one to twenty-five `PlanPart` nodes, each an `OrderPart` or another join.
    #' @param group_margin A logical that is `TRUE` for the broker selector to choose a broker that can afford the whole group, `FALSE` for each child to choose alone, or `NULL` for UBI's default of `TRUE`.
    #' @param hedge_benefit A logical that is `TRUE` to price options and futures on one underlying and expiry together as one hedged position when checking the broker can afford the group.
    #' @param done_when The character rule `all` for the join to be done once every child is done, `any` to cancel the rest once one child is done, or `NULL` for UBI's default of `all`.
    #' @return A new `TogetherPart` object.
    initialize = function(
      children,
      group_margin = NULL,
      hedge_benefit = FALSE,
      done_when = NULL
    ) {
      self$children <- children
      self$group_margin <- group_margin
      self$hedge_benefit <- hedge_benefit
      self$done_when <- done_when
    },

    #' @description
    #' Builds the `together` node UBI reads.
    #' @return A named list with the single key `together`, whose value holds `children`, `group_margin` and `done_when` when they are not `NULL`, and `hedge_benefit` when it is `TRUE`.
    #' @examples
    #' \dontrun{
    #' part <- TogetherPart$new(
    #'   children = list(
    #'     OrderPart$new(transaction_type = "buy", quantity = 10),
    #'     OrderPart$new(transaction_type = "sell", quantity = 10)
    #'   ),
    #'   hedge_benefit = TRUE
    #' )
    #' print(part$document())
    #'
    #' part <- TogetherPart$new(
    #'   children = list(
    #'     OrderPart$new(
    #'       trigger = PriceCrosses$new(level = 995.0)
    #'     ),
    #'     OrderPart$new(
    #'       trigger = PriceCrosses$new(level = 990.0)
    #'     )
    #'   ),
    #'   group_margin = FALSE,
    #'   done_when = "any"
    #' )
    #' print(part$document())
    #' }
    document = function() {
      child_documents <- list()
      for (child in self$children) {
        child_documents[[length(child_documents) + 1]] <- child$document()
      }
      settings <- list(
        children = child_documents
      )
      if (!is.null(self$group_margin)) {
        settings[["group_margin"]] <- self$group_margin
      }
      if (isTRUE(self$hedge_benefit)) {
        settings[["hedge_benefit"]] <- TRUE
      }
      if (!is.null(self$done_when)) {
        settings[["done_when"]] <- self$done_when
      }
      list(
        together = settings
      )
    }
  )
)
