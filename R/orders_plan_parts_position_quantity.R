#' A quantity that is the position held when the order fires, on one product and one or more instruments
#'
#' @description
#' The `position` quantity of a plan: the size of the position held when the order fires, read at that moment.
#'
#' An order with this quantity closes a position rather than trading a number named in advance, so its side must be `close`, and a `close` side needs this quantity. UBI first cancels every order resting on the instruments being closed, unless `cancel_resting_first` is `FALSE`, so a stop or target left live cannot reopen the position, and then sends each broker's share to the broker that holds it, as a limit two ticks past the other side's touch. Such an order therefore takes no pricing or execution of its own. Nothing held ends the part with the reason `nothing_held` and the plan `completed` without an order.
#' @examples
#' \dontrun{
#' part <- OrderPart$new(
#'   trigger = TimeAt$new("15:15"),
#'   side = "close",
#'   quantity = PositionQuantity$new(product = "intraday")
#' )
#' document <- part$document()
#' }
#' @export
PositionQuantity <- R6::R6Class(
  "PositionQuantity",
  inherit = PlanPart,
  public = list(
    #' @field product The character position product, `intraday`, `delivery` or `carry`, or `NULL` for the order's own product.
    product = NULL,
    #' @field held_instruments The list of `Instrument` whose positions are closed, or `NULL` for the order's own instrument.
    held_instruments = NULL,
    #' @field every_instrument A logical that is `TRUE` to close the position in every instrument held on the product.
    every_instrument = NULL,
    #' @field ratio The integer ratio, 1 to close or 2 to close and open the same size the other way, or `NULL` for UBI's default of 1.
    ratio = NULL,
    #' @field cancel_resting_first A logical that is `FALSE` to leave resting orders alone before closing, or `NULL` for UBI's default of `TRUE`.
    cancel_resting_first = NULL,

    #' @description
    #' Initialises the quantity with the positions it reads.
    #' @param product The character product as UBI names a position's product, `intraday`, `delivery` or `carry`, rather than an order's `mis`, `cnc` or `nrml`, or `NULL` for the order's own product.
    #' @param held_instruments A list of `Instrument` objects whose positions are closed, or `NULL` for the order's own instrument; UBI refuses it beside `every_instrument`.
    #' @param every_instrument A logical that is `TRUE` to close every instrument held on the product.
    #' @param ratio The integer 1 to close the position, 2 to close it and open the reverse in one order, or `NULL` for UBI's default of 1.
    #' @param cancel_resting_first A logical that is `TRUE` to cancel every order resting on those instruments first, `FALSE` to leave them, or `NULL` for UBI's default of `TRUE`.
    #' @return A new `PositionQuantity` object.
    initialize = function(
      product = NULL,
      held_instruments = NULL,
      every_instrument = FALSE,
      ratio = NULL,
      cancel_resting_first = NULL
    ) {
      self$product <- product
      self$held_instruments <- held_instruments
      self$every_instrument <- every_instrument
      self$ratio <- ratio
      self$cancel_resting_first <- cancel_resting_first
    },

    #' @description
    #' Builds the `position` quantity UBI reads, holding every setting that is set.
    #' @return A named list with the single key `position`, whose value holds each of `product`, `ratio` and `cancel_resting_first` that is not `NULL`, the instruments as a list of their `instrument_ids`, and `every_instrument` when it is `TRUE`.
    #' @examples
    #' \dontrun{
    #' part <- OrderPart$new(
    #'   trigger = TimeAt$new("15:15"),
    #'   side = "close",
    #'   quantity = PositionQuantity$new(
    #'     product = "intraday",
    #'     every_instrument = TRUE
    #'   )
    #' )
    #' print(part$document())
    #'
    #' part <- OrderPart$new(
    #'   trigger = PriceCrosses$new(level = 990.0, direction = "at_or_below"),
    #'   side = "close",
    #'   quantity = PositionQuantity$new(ratio = 2)
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$product)) {
        settings[["product"]] <- self$product
      }
      if (!is.null(self$held_instruments)) {
        instrument_ids <- list()
        for (instrument in self$held_instruments) {
          instrument_ids[[length(instrument_ids) + 1]] <-
            instrument$instrument_id
        }
        settings[["instrument_ids"]] <- instrument_ids
      }
      if (isTRUE(self$every_instrument)) {
        settings[["every_instrument"]] <- TRUE
      }
      if (!is.null(self$ratio)) {
        settings[["ratio"]] <- self$ratio
      }
      if (!is.null(self$cancel_resting_first)) {
        settings[["cancel_resting_first"]] <- self$cancel_resting_first
      }
      list(
        position = settings
      )
    }
  )
)
