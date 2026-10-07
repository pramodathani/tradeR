#' A pricing rule that moves a resting limit after another instrument
#'
#' @description
#' The `follow_instrument` pricing rule of a plan: a limit moved by how far another instrument has moved since the order was sent.
#'
#' The order starts at the template's own limit price, and from then on its price is that start price plus `delta` times the followed instrument's move, so a Nifty call bid with a delta of 0.5 rises by 20 when the index rises by 40, without reading the option's own thin book. The price stays between `lowest` and `highest`, never goes below one tick, and moves only when it would move by at least `step_ticks`. The template must be a limit order with a price, and the followed instrument must be another one than the order's own.
#' @examples
#' \dontrun{
#' index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
#' pricing <- FollowInstrumentPricing$new(
#'   instrument = index,
#'   delta = 0.5
#' )
#' document <- pricing$document()
#' }
#' @export
FollowInstrumentPricing <- R6::R6Class(
  "FollowInstrumentPricing",
  inherit = PlanPart,
  public = list(
    #' @field instrument The `Instrument` followed, sent as its `instrument_id`.
    instrument = NULL,
    #' @field delta The numeric number of rupees the price moves for each rupee the followed instrument moves.
    delta = NULL,
    #' @field lowest The numeric lowest price the order goes to, or `NULL` for no floor.
    lowest = NULL,
    #' @field highest The numeric highest price the order goes to, or `NULL` for no ceiling.
    highest = NULL,
    #' @field step_ticks The integer smallest move worth sending, in ticks, or `NULL` for UBI's default of 1.
    step_ticks = NULL,

    #' @description
    #' Initialises the rule with the instrument it follows and its settings.
    #' @param instrument The `Instrument` to follow, usually an option's underlying, which must not be the order's own instrument.
    #' @param delta The numeric number of rupees the price moves for each rupee the followed instrument moves, which may be negative, as for a put.
    #' @param lowest The numeric lowest price in rupees the order goes to, or `NULL` for no floor.
    #' @param highest The numeric highest price in rupees the order goes to, or `NULL` for no ceiling.
    #' @param step_ticks The integer smallest move worth sending, in ticks, or `NULL` for UBI's default of 1.
    #' @return A new `FollowInstrumentPricing` object.
    initialize = function(
      instrument,
      delta,
      lowest = NULL,
      highest = NULL,
      step_ticks = NULL
    ) {
      self$instrument <- instrument
      self$delta <- delta
      self$lowest <- lowest
      self$highest <- highest
      self$step_ticks <- step_ticks
    },

    #' @description
    #' Builds the `follow_instrument` pricing object UBI reads, holding every setting that is not `NULL`.
    #' @return A named list with the single key `follow_instrument`, whose value holds the followed instrument as its `instrument_id`, `delta`, and `lowest`, `highest` and `step_ticks` when each is set.
    #' @examples
    #' \dontrun{
    #' index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pricing <- FollowInstrumentPricing$new(
    #'   instrument = index,
    #'   delta = 0.5
    #' )
    #' print(pricing$document())
    #'
    #' index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pricing <- FollowInstrumentPricing$new(
    #'   instrument = index,
    #'   delta = -0.4,
    #'   lowest = 80.0,
    #'   highest = 150.0,
    #'   step_ticks = 2
    #' )
    #' print(pricing$document())
    #' }
    document = function() {
      settings <- list(
        instrument_id = self$instrument$instrument_id,
        delta = self$delta
      )
      if (!is.null(self$lowest)) {
        settings[["lowest"]] <- self$lowest
      }
      if (!is.null(self$highest)) {
        settings[["highest"]] <- self$highest
      }
      if (!is.null(self$step_ticks)) {
        settings[["step_ticks"]] <- self$step_ticks
      }
      list(
        follow_instrument = settings
      )
    }
  )
)
