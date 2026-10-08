#' Survey which kinds of instrument UBI can quote, catching UnifiedBrokerInterfaceError.
#'
#' The program asks a share, a bond, a mutual fund scheme and a commodity for their last price. The share is quoted, while the other three signal ServiceUnavailableError because no broker that serves quotes carries them. One handler for the base class UnifiedBrokerInterfaceError catches each refusal, and the program prints a line per instrument.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/service_unavailable_error/survey_quote_coverage.R

library(tradeR)

#' A survey of which instruments UBI can give a last price for.
#'
#' @field surveyed_instruments A list of the `Instrument` objects to ask.
QuoteCoverageSurvey <- R6::R6Class(
  "QuoteCoverageSurvey",
  public = list(
    surveyed_instruments = NULL,

    #' @description
    #' Creates the survey with one instrument of each kind.
    #' @return A new `QuoteCoverageSurvey` object.
    #' @details Errors: signals an `InstrumentError` subclass when UBI does not know one of the instruments, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    initialize = function() {
      self$surveyed_instruments <- list(
        Equity$new(exchange = "nse", symbol = "IDEA"),
        FixedIncome$new(exchange = "nse", symbol = "IN000126C010"),
        MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG"),
        Commodity$new(exchange = "mcx", symbol = "GOLD")
      )
    },

    #' @description
    #' Asks one instrument for its last price and describes the answer.
    #' @param instrument The `Instrument` to ask.
    #' @return A character line with the last price, or the reason there is none.
    describe = function(instrument) {
      label <- sprintf("%s %s", class(instrument)[[1]], instrument$symbol)
      last_price <- tryCatch(
        instrument$last_price,
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(last_price, "UnifiedBrokerInterfaceError")) {
        return(
          sprintf(
            "%s: no quote, %s (%s)",
            label,
            ErrorCatalogue$name_of(last_price),
            toString(last_price$status_code)
          )
        )
      }
      sprintf("%s: %s", label, toString(last_price))
    },

    #' @description
    #' Asks every instrument and prints one line for each.
    #' @return `NULL`, invisibly.
    run = function() {
      for (instrument in self$surveyed_instruments) {
        cat(self$describe(instrument), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  QuoteCoverageSurvey$new()$run()
}
