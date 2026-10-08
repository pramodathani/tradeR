#' Tell which of several instrument ids are contracts, catching InstrumentError.
#'
#' The program collects the UBI ids of a share, a futures contract and an option, then builds a Derivative from each id. The share raises DerivativeError, which one handler for the base class InstrumentError catches, and the two contracts print their expiry dates.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/derivative_error/classify_instrument_ids.R

library(tradeR)

#' A classifier of UBI instrument ids into contracts and other instruments.
#'
#' @field instrument_ids The named list of character UBI instrument ids to classify, named by a character label.
InstrumentIdClassifier <- R6::R6Class(
  "InstrumentIdClassifier",
  public = list(
    instrument_ids = NULL,

    #' @description
    #' Creates the classifier with no ids yet.
    #' @return A new `InstrumentIdClassifier` object.
    initialize = function() {
      self$instrument_ids <- list()
    },

    #' @description
    #' Reads the ids of one share, the nearest NIFTY future and one NIFTY option from UBI.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    collect_instrument_ids = function() {
      share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$instrument_ids[["IDEA share"]] <- share$instrument_id
      futures_frame <- EquityIndexFutures$contracts(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      self$instrument_ids[["NIFTY future"]] <- futures_frame$instrument_id[[1]]
      expiry_date <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )[1]
      chain <- EquityIndexOption$chain(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiry_date
      )
      middle_row <- nrow(chain) %/% 2 + 1
      self$instrument_ids[["NIFTY option"]] <- chain$instrument_id[[middle_row]]
      invisible(NULL)
    },

    #' @description
    #' Builds a Derivative from every id and prints whether it is a contract.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      self$collect_instrument_ids()
      for (label in names(self$instrument_ids)) {
        instrument_id <- self$instrument_ids[[label]]
        line <- tryCatch(
          {
            contract <- Derivative$new(instrument_id = instrument_id)
            sprintf(
              "%s: a contract of shape %s, expiring %s",
              label,
              contract$shape,
              format(contract$expiry_date)
            )
          },
          InstrumentError = function(error) {
            sprintf(
              "%s: not a contract (%s: %s)",
              label,
              class(error)[[1]],
              conditionMessage(error)
            )
          }
        )
        cat(line, "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  InstrumentIdClassifier$new()$run()
}
