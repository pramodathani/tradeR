#' A condition that holds once a price reaches a level from the side that fires
#'
#' @description
#' The `price_crosses` trigger of a plan: a price reaching a level.
#'
#' With no direction, an order sent as a buy waits for the price to fall to the level and one sent as a sell for it to rise, which is market-if-touched's meaning for an entry and a stop's meaning for an order that protects a position. The price watched can be the order's own instrument or another one.
#' @examples
#' \dontrun{
#' condition <- PriceCrosses$new(level = 995.0, field = "bid")
#' document <- condition$document()
#' }
#' @export
PriceCrosses <- R6::R6Class(
  "PriceCrosses",
  inherit = PlanPart,
  public = list(
    #' @field level The numeric level in rupees.
    level = NULL,
    #' @field direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to take it from the order's side.
    direction = NULL,
    #' @field field The character price watched, such as `last`, `bid`, `ask` or `mid`, or `NULL` for `last`.
    field = NULL,
    #' @field instrument The `Instrument` watched, or `NULL` for the order's own instrument.
    instrument = NULL,
    #' @field confirm The character confirmation, `none`, `double_last` or `held`, or `NULL` for `none`.
    confirm = NULL,
    #' @field hold_seconds The integer seconds the price must stay past the level under `held`, or `NULL`.
    hold_seconds = NULL,

    #' @description
    #' Initialises the condition with its level and settings.
    #' @param level The numeric level in rupees.
    #' @param direction The character direction, `at_or_above` or `at_or_below`, or `NULL` for a buy to wait for a fall and a sell for a rise.
    #' @param field The character price watched, `last`, `bid`, `ask`, `mid`, `average_price`, `previous_close` or `opposite_touch`, or `NULL` for `last`.
    #' @param instrument The `Instrument` to watch, or `NULL` to watch the order's own instrument.
    #' @param confirm The character confirmation, `none`, `double_last` for two last prices in a row past the level, or `held` for the price to stay past it for `hold_seconds`, or `NULL` for `none`.
    #' @param hold_seconds The integer seconds the price must stay past the level, required with `held`, or `NULL`.
    #' @return A new `PriceCrosses` object.
    initialize = function(
      level,
      direction = NULL,
      field = NULL,
      instrument = NULL,
      confirm = NULL,
      hold_seconds = NULL
    ) {
      self$level <- level
      self$direction <- direction
      self$field <- field
      self$instrument <- instrument
      self$confirm <- confirm
      self$hold_seconds <- hold_seconds
    },

    #' @description
    #' Builds the `price_crosses` condition UBI reads, holding every setting that is not `NULL`.
    #' @return A named list with the single key `price_crosses`, whose value holds `level` and each other setting that is set, with the watched instrument as its `instrument_id`.
    #' @examples
    #' \dontrun{
    #' condition <- PriceCrosses$new(level = 995.0)
    #' print(condition$document())
    #'
    #' condition <- PriceCrosses$new(
    #'   level = 1010.0,
    #'   direction = "at_or_above",
    #'   field = "bid",
    #'   confirm = "held",
    #'   hold_seconds = 10
    #' )
    #' print(condition$document())
    #'
    #' index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' condition <- PriceCrosses$new(
    #'   level = 25000.0,
    #'   direction = "at_or_above",
    #'   instrument = index
    #' )
    #' print(condition$document())
    #' }
    document = function() {
      settings <- list(
        level = self$level
      )
      if (!is.null(self$direction)) {
        settings[["direction"]] <- self$direction
      }
      if (!is.null(self$field)) {
        settings[["field"]] <- self$field
      }
      if (!is.null(self$instrument)) {
        settings[["instrument_id"]] <- self$instrument$instrument_id
      }
      if (!is.null(self$confirm)) {
        settings[["confirm"]] <- self$confirm
      }
      if (!is.null(self$hold_seconds)) {
        settings[["hold_seconds"]] <- self$hold_seconds
      }
      list(
        price_crosses = settings
      )
    }
  )
)
