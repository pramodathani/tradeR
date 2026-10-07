#' A condition that holds when a figure from the account is at or past a level
#'
#' @description
#' The `account` trigger of a plan: a figure from the whole account reaching a level, rather than a price.
#'
#' The figure is `available_balance`, the free margin across every broker; `day_pnl`, the day's realized and unrealized profit across every broker; or `open_positions`, how many net positions are open. All three settings are required, the direction too, because nothing about an order says which way an account figure should move. The condition reads no quotes, so UBI checks it once a second on the clock.
#' @examples
#' \dontrun{
#' condition <- AccountCondition$new(
#'   field = "day_pnl",
#'   level = -5000.0,
#'   direction = "at_or_below"
#' )
#' document <- condition$document()
#' }
#' @export
AccountCondition <- R6::R6Class(
  "AccountCondition",
  inherit = PlanPart,
  public = list(
    #' @field field The character figure, `available_balance`, `day_pnl` or `open_positions`.
    field = NULL,
    #' @field level The numeric level the figure is compared with, in rupees or, for `open_positions`, a count.
    level = NULL,
    #' @field direction The character direction, `at_or_above` or `at_or_below`.
    direction = NULL,

    #' @description
    #' Initialises the condition with its figure, level and direction.
    #' @param field The character figure, `available_balance` for the free margin across every broker, `day_pnl` for the day's realized plus unrealized profit across every broker, or `open_positions` for the count of open net positions.
    #' @param level The numeric level, in rupees for the two money figures and a count for `open_positions`.
    #' @param direction The character direction, `at_or_above` or `at_or_below`, which is required.
    #' @return A new `AccountCondition` object.
    initialize = function(
      field,
      level,
      direction
    ) {
      self$field <- field
      self$level <- level
      self$direction <- direction
    },

    #' @description
    #' Builds the `account` condition UBI reads.
    #' @return A named list with the single key `account`, whose value holds `field`, `level` and `direction`.
    #' @examples
    #' \dontrun{
    #' condition <- AccountCondition$new(
    #'   field = "day_pnl",
    #'   level = -5000.0,
    #'   direction = "at_or_below"
    #' )
    #' print(condition$document())
    #'
    #' part <- OrderPart$new(
    #'   trigger = AccountCondition$new(
    #'     field = "available_balance",
    #'     level = 50000.0,
    #'     direction = "at_or_above"
    #'   )
    #' )
    #' print(part$document())
    #'
    #' condition <- AccountCondition$new(
    #'   field = "open_positions",
    #'   level = 0,
    #'   direction = "at_or_below"
    #' )
    #' print(condition$document())
    #' }
    document = function() {
      list(
        account = list(
          field = self$field,
          level = self$level,
          direction = self$direction
        )
      )
    }
  )
)
