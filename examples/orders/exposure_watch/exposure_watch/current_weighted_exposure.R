#' Work out the weighted exposure an exposure hedge would see in the account now.
#'
#' The program builds exposure watches over Vodafone Idea and Yes Bank, reads the net position held in each, and adds up quantity times exposure per unit the way UBI's exposure hedge does, printing each part and the total. It only reads positions and places no order.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/exposure_watch/exposure_watch/current_weighted_exposure.R

library(tradeR)

#' The account's weighted exposure over a set of watched shares.
#'
#' @field watches The list of `ExposureWatch` whose positions are added up.
CurrentWeightedExposure <- R6::R6Class(
  "CurrentWeightedExposure",
  public = list(
    watches = NULL,

    #' @description
    #' Builds the watches over Vodafone Idea and Yes Bank.
    #' @return A new `CurrentWeightedExposure` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$watches <- list(
        ExposureWatch$new(
          Equity$new(exchange = "nse", symbol = "IDEA"),
          exposure_per_unit = 1.0
        ),
        ExposureWatch$new(
          Equity$new(exchange = "nse", symbol = "YESBANK"),
          exposure_per_unit = 0.5
        )
      )
    },

    #' @description
    #' Adds up the net quantity held in a watched instrument across every product.
    #' @param watch The `ExposureWatch` to read.
    #' @return The numeric net quantity, positive when long and negative when short.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the positions.
    net_quantity = function(watch) {
      positions <- watch$instrument$net_positions
      if (is.null(positions)) {
        return(0)
      }
      total <- 0
      for (index in seq_len(nrow(positions))) {
        total <- total + as.integer(positions[["quantity"]][[index]])
      }
      total
    },

    #' @description
    #' Prints each watched share's exposure and the total.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the positions.
    run = function() {
      total <- 0.0
      for (watch in self$watches) {
        document <- watch$document()
        per_unit <- document[["exposure_per_unit"]]
        if (is.null(per_unit)) {
          per_unit <- 1.0
        }
        quantity <- self$net_quantity(watch)
        exposure <- quantity * per_unit
        total <- total + exposure
        cat(sprintf(
          "%s: %s held x %s = %s\n",
          watch$instrument$symbol,
          quantity,
          per_unit,
          exposure
        ))
      }
      cat(sprintf("Total weighted exposure: %s\n", total))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CurrentWeightedExposure$new()$run()
}
