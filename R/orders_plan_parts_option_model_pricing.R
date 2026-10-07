#' A pricing rule that prices an option from an implied volatility and its underlying
#'
#' @description
#' The `option_model` pricing rule of a plan: an option's premium worked out from an implied volatility and kept current as the underlying moves.
#'
#' UBI prices the order's option with the Black-76 model at the stated `volatility`, reading the option's strike, expiry and kind from its catalogue when the plan is placed, and re-prices it as the underlying moves and expiry nears. When the underlying is a future it is the forward; otherwise, as for the index, the spot is grown by `interest_rate` to expiry. The template's own price is the worst the order accepts, and the bounds and the step work as they do for `FollowInstrumentPricing`. An order whose instrument is not an option is refused.
#' @examples
#' \dontrun{
#' index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
#' pricing <- OptionModelPricing$new(
#'   instrument = index,
#'   volatility = 14.0
#' )
#' document <- pricing$document()
#' }
#' @export
OptionModelPricing <- R6::R6Class(
  "OptionModelPricing",
  inherit = PlanPart,
  public = list(
    #' @field instrument The `Instrument` that is the option's underlying, sent as its `instrument_id`.
    instrument = NULL,
    #' @field volatility The numeric implied volatility as a percentage, above zero and at most 500.
    volatility = NULL,
    #' @field interest_rate The numeric yearly interest rate as a percentage, or `NULL` for UBI's default of 0.
    interest_rate = NULL,
    #' @field lowest The numeric lowest price the order goes to, or `NULL` for no floor.
    lowest = NULL,
    #' @field highest The numeric highest price the order goes to, or `NULL` for no ceiling.
    highest = NULL,
    #' @field step_ticks The integer smallest move worth sending, in ticks, or `NULL` for UBI's default of 1.
    step_ticks = NULL,

    #' @description
    #' Initialises the rule with the underlying, the volatility and its settings.
    #' @param instrument The `Instrument` that is the option's underlying, such as the index or a future on it.
    #' @param volatility The numeric implied volatility as a percentage, such as 14.0 for 14%, above zero and at most 500.
    #' @param interest_rate The numeric yearly interest rate as a percentage, used to grow a spot underlying to expiry, or `NULL` for UBI's default of 0.
    #' @param lowest The numeric lowest price in rupees the order goes to, or `NULL` for no floor.
    #' @param highest The numeric highest price in rupees the order goes to, or `NULL` for no ceiling.
    #' @param step_ticks The integer smallest move worth sending, in ticks, or `NULL` for UBI's default of 1.
    #' @return A new `OptionModelPricing` object.
    initialize = function(
      instrument,
      volatility,
      interest_rate = NULL,
      lowest = NULL,
      highest = NULL,
      step_ticks = NULL
    ) {
      self$instrument <- instrument
      self$volatility <- volatility
      self$interest_rate <- interest_rate
      self$lowest <- lowest
      self$highest <- highest
      self$step_ticks <- step_ticks
    },

    #' @description
    #' Builds the `option_model` pricing object UBI reads, holding every setting that is not `NULL`.
    #' @return A named list with the single key `option_model`, whose value holds the underlying as its `instrument_id`, `volatility`, and `interest_rate`, `lowest`, `highest` and `step_ticks` when each is set.
    #' @examples
    #' \dontrun{
    #' index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pricing <- OptionModelPricing$new(
    #'   instrument = index,
    #'   volatility = 14.0
    #' )
    #' print(pricing$document())
    #'
    #' index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pricing <- OptionModelPricing$new(
    #'   instrument = index,
    #'   volatility = 12.5,
    #'   interest_rate = 6.5,
    #'   lowest = 50.0,
    #'   highest = 120.0,
    #'   step_ticks = 2
    #' )
    #' print(pricing$document())
    #' }
    document = function() {
      settings <- list(
        instrument_id = self$instrument$instrument_id,
        volatility = self$volatility
      )
      if (!is.null(self$interest_rate)) {
        settings[["interest_rate"]] <- self$interest_rate
      }
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
        option_model = settings
      )
    }
  )
)
