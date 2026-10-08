#' Print the expiry calendar of Nifty options and Reliance futures.
#'
#' The program lists the live expiries of each underlying, builds one contract for each expiry, and prints how many days it has left, whether it is a weekly or a monthly expiry, and the expiry it would roll to. These are the members every Derivative shares, whatever its family.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/derivative/expiry_calendar.R

library(tradeR)

#' A calendar of the next few expiries of an index option and a stock future.
#'
#' @field expiry_count The integer number of expiries to show for each underlying.
ExpiryCalendar <- R6::R6Class(
  "ExpiryCalendar",
  public = list(
    expiry_count = NULL,

    #' @description
    #' Stores how many expiries to show.
    #' @param expiry_count The integer number of expiries to show for each underlying.
    #' @return A new `ExpiryCalendar` object.
    initialize = function(expiry_count = 4) {
      self$expiry_count <- expiry_count
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      format(value)
    },

    #' @description
    #' Prints one line about one contract.
    #' @param contract The `Derivative` to describe.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    print_contract = function(contract) {
      cat(sprintf(
        "  %s  %4d days  %-8s rolls to %s\n",
        format(contract$expiry_date),
        contract$days_to_expiry,
        contract$expiry_kind,
        self$display_text(contract$next_expiry)
      ))
      invisible(NULL)
    },

    #' @description
    #' Prints the calendar of Nifty options, building one option from each expiry's chain.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    nifty_options = function() {
      cat("NIFTY options:\n")
      expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      expiries <- head(expiries, self$expiry_count)
      for (expiry_index in seq_along(expiries)) {
        expiry_date <- expiries[[expiry_index]]
        chain <- EquityIndexOption$chain(
          exchange = "nse",
          underlying_symbol = "NIFTY",
          expiry_date = expiry_date
        )
        option <- IndexOption$new(instrument_id = chain$instrument_id[[1]])
        self$print_contract(option)
      }
      invisible(NULL)
    },

    #' @description
    #' Prints the calendar of Reliance futures.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    reliance_futures = function() {
      cat("RELIANCE futures:\n")
      expiries <- EquityFutures$expiries(
        exchange = "nse",
        underlying_symbol = "RELIANCE"
      )
      expiries <- head(expiries, self$expiry_count)
      for (expiry_index in seq_along(expiries)) {
        expiry_date <- expiries[[expiry_index]]
        future <- EquityFutures$new(
          exchange = "nse",
          underlying_symbol = "RELIANCE",
          expiry_date = expiry_date
        )
        self$print_contract(future)
      }
      invisible(NULL)
    },

    #' @description
    #' Prints both calendars.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      self$nifty_options()
      self$reliance_futures()
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ExpiryCalendar$new()$run()
}
