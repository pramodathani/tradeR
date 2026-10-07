#' One named preset and its settings
#'
#' @description
#' A preset in a plan: one of the existing synthetic order types used as an ingredient of an order.
#'
#' A preset stands for slot values, or for a whole join, and takes the settings of the type it is named after, so `Preset$new("bracket", stop_price = 990.0, stop_limit_price = 988.0, target_price = 1010.0)` makes an order a bracket. The preset names and their settings are UBI's, and UBI refuses a name it does not offer yet, so new presets work here as soon as UBI adds them.
#' @examples
#' \dontrun{
#' part <- Preset$new("market_if_touched", trigger_price = 995.0)
#' document <- part$document()
#' }
#' @export
Preset <- R6::R6Class(
  "Preset",
  inherit = PlanPart,
  public = list(
    #' @field name The character name of the preset, such as `bracket`, `trailing_stop` or `scheduled`.
    name = NULL,
    #' @field settings The named list of the preset's settings, keyed by UBI's field names.
    settings = NULL,

    #' @description
    #' Initialises the preset with its name and settings.
    #' @param name The character name of the preset, as UBI names the synthetic order type, such as `bracket`, `oto` or `hidden_stop`.
    #' @param ... The preset's settings as named arguments by UBI's field names, such as `trigger_price = 995.0`. A setting UBI reads as a list, such as a list of prices, is given as a `list()`, because a vector of length one is sent as a single value.
    #' @return A new `Preset` object.
    initialize = function(name, ...) {
      self$name <- name
      self$settings <- list(...)
    },

    #' @description
    #' Builds the preset object UBI reads.
    #' @return A named list with the single key `name`, whose value is the named list of settings.
    #' @examples
    #' \dontrun{
    #' part <- Preset$new("market_if_touched", trigger_price = 995.0)
    #' print(part$document())
    #'
    #' part <- Preset$new(
    #'   "bracket",
    #'   stop_price = 990.0,
    #'   stop_limit_price = 988.0,
    #'   target_price = 1010.0
    #' )
    #' print(part$document())
    #'
    #' print(Preset$new("simple")$document())
    #' }
    document = function() {
      settings <- self$settings
      if (length(settings) == 0) {
        settings <- structure(list(), names = character(0))
      }
      document <- list()
      document[[self$name]] <- settings
      document
    }
  )
)
