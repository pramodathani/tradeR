#' A pricing rule that sends a stop-limit order to rest at the broker
#'
#' @description
#' The `native_stop` pricing rule of a plan: a stop-limit order resting at the broker.
#'
#' Because the stop rests at the broker, it still fires if UBI's order engine is down, unlike a stop made from a `PriceCrosses` or `Trails` trigger. With `exit_if_gapped`, a stop whose trigger the last price has already passed when it is sent goes as a limit two ticks past the other side's touch instead, because the broker would refuse such a stop or fill it wherever the gap left the price.
#' @examples
#' \dontrun{
#' pricing <- NativeStopPricing$new(
#'   trigger_price = 990.0,
#'   limit_price = 988.0
#' )
#' document <- pricing$document()
#' }
#' @export
NativeStopPricing <- R6::R6Class(
  "NativeStopPricing",
  inherit = PlanPart,
  public = list(
    #' @field trigger_price The numeric trigger of the stop in rupees.
    trigger_price = NULL,
    #' @field limit_price The numeric limit of the stop in rupees.
    limit_price = NULL,
    #' @field exit_if_gapped A logical that is `TRUE` to send a stop the price has already passed as a marketable limit instead.
    exit_if_gapped = NULL,

    #' @description
    #' Initialises the rule with the stop's trigger and limit.
    #' @param trigger_price The numeric trigger of the stop in rupees.
    #' @param limit_price The numeric limit of the stop in rupees.
    #' @param exit_if_gapped A logical that is `TRUE` to send a stop whose trigger the last price has already passed as a limit two ticks past the other side's touch, rather than a stop the broker would refuse or fill wherever the gap left the price.
    #' @return A new `NativeStopPricing` object.
    initialize = function(
      trigger_price,
      limit_price,
      exit_if_gapped = FALSE
    ) {
      self$trigger_price <- trigger_price
      self$limit_price <- limit_price
      self$exit_if_gapped <- exit_if_gapped
    },

    #' @description
    #' Builds the `native_stop` pricing object UBI reads.
    #' @return A named list with the single key `native_stop`, whose value holds `trigger_price` and `limit_price`, and `exit_if_gapped` when it is `TRUE`.
    #' @examples
    #' \dontrun{
    #' pricing <- NativeStopPricing$new(
    #'   trigger_price = 990.0,
    #'   limit_price = 988.0
    #' )
    #' print(pricing$document())
    #'
    #' part <- OrderPart$new(
    #'   side = "protect",
    #'   pricing = NativeStopPricing$new(
    #'     trigger_price = 990.0,
    #'     limit_price = 988.0
    #'   )
    #' )
    #' print(part$document())
    #'
    #' pricing <- NativeStopPricing$new(
    #'   trigger_price = 990.0,
    #'   limit_price = 988.0,
    #'   exit_if_gapped = TRUE
    #' )
    #' print(pricing$document())
    #' }
    document = function() {
      settings <- list(
        trigger_price = self$trigger_price,
        limit_price = self$limit_price
      )
      if (isTRUE(self$exit_if_gapped)) {
        settings[["exit_if_gapped"]] <- TRUE
      }
      list(
        native_stop = settings
      )
    }
  )
)
