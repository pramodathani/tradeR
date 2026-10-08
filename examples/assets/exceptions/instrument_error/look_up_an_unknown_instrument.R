#' Look up an instrument UBI does not know and handle the InstrumentError.
#'
#' The program asks the general Instrument class for a share whose symbol is misspelt, catches InstrumentError, and prints the message together with the UBI failure it was raised from, which carries the HTTP status code and the body UBI answered with.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/instrument_error/look_up_an_unknown_instrument.R

library(tradeR)

#' A lookup of a share by a misspelt symbol.
#'
#' @field exchange The character exchange to look the share up on.
#' @field segment The character UBI segment to look the share up in.
#' @field symbol The character misspelt symbol, which UBI does not know.
UnknownInstrumentLookup <- R6::R6Class(
  "UnknownInstrumentLookup",
  public = list(
    exchange = NULL,
    segment = NULL,
    symbol = NULL,

    #' @description
    #' Creates the lookup with the misspelt symbol.
    #' @return A new `UnknownInstrumentLookup` object.
    initialize = function() {
      self$exchange <- "nse"
      self$segment <- "equities"
      self$symbol <- "RELIANCEINDUSTRIES"
    },

    #' @description
    #' Looks the symbol up and prints what UBI said about it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup for a reason other than an unknown instrument.
    run = function() {
      instrument <- tryCatch(
        Instrument$new(
          exchange = self$exchange,
          segment = self$segment,
          symbol = self$symbol
        ),
        InstrumentError = function(error) {
          cat(sprintf("InstrumentError: %s\n", conditionMessage(error)))
          cause <- error$parent
          if (!is.null(cause)) {
            cat(sprintf("Raised from %s\n", class(cause)[[1]]))
            cat(sprintf("HTTP status code: %s\n", format(cause$status_code)))
            cat(
              sprintf(
                "UBI answered: %s\n",
                jsonlite::toJSON(cause$detail, auto_unbox = TRUE, null = "null")
              )
            )
          }
          NULL
        }
      )
      if (is.null(instrument)) {
        return(invisible(NULL))
      }
      cat(sprintf("Unexpectedly found: %s\n", instrument$format()))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  UnknownInstrumentLookup$new()$run()
}
