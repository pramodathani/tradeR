#' Keep only the index options among several options, catching InstrumentError.
#'
#' The program builds an IndexOption at the middle strike of the soonest expiry of NIFTY, MCXBULLDEX and GOLDM options. The gold option raises IndexOptionError because gold is not an index, and one handler for the base class InstrumentError catches it along with any other instrument error.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/index_option_error/keep_only_index_options.R

library(tradeR)

#' A filter that keeps only options written on an index.
#'
#' @field lookups The list of (character exchange, character segment, character underlying symbol, `Date` expiry, numeric strike) lists to try.
IndexOptionFilter <- R6::R6Class(
  "IndexOptionFilter",
  public = list(
    lookups = NULL,

    #' @description
    #' Creates the filter with no lookups yet.
    #' @return A new `IndexOptionFilter` object.
    initialize = function() {
      self$lookups <- list()
    },

    #' @description
    #' Records a lookup at the middle strike of the soonest expiry of one underlying.
    #' @param family_class The option family class, such as `EquityIndexOption`, whose discovery methods to read.
    #' @param exchange The character exchange the options trade on.
    #' @param segment The character UBI segment of the options.
    #' @param underlying_symbol The character symbol the options are written on.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    add_middle_strike = function(
      family_class,
      exchange,
      segment,
      underlying_symbol
    ) {
      expiry_date <- family_class$expiries(exchange, underlying_symbol)[1]
      strike_prices <- family_class$strikes(
        exchange,
        underlying_symbol,
        expiry_date
      )
      strike_price <- strike_prices[length(strike_prices) %/% 2 + 1]
      self$lookups[[length(self$lookups) + 1]] <- list(
        exchange,
        segment,
        underlying_symbol,
        expiry_date,
        strike_price
      )
      invisible(NULL)
    },

    #' @description
    #' Builds every lookup as an index option and prints which ones are kept.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      self$add_middle_strike(
        EquityIndexOption,
        "nse",
        "equity_index_options",
        "NIFTY"
      )
      self$add_middle_strike(
        CommodityIndexOption,
        "mcx",
        "commodity_index_options",
        "MCXBULLDEX"
      )
      self$add_middle_strike(
        CommodityOption,
        "mcx",
        "commodity_options",
        "GOLDM"
      )
      for (lookup in self$lookups) {
        exchange <- lookup[[1]]
        segment <- lookup[[2]]
        underlying_symbol <- lookup[[3]]
        expiry_date <- lookup[[4]]
        strike_price <- lookup[[5]]
        label <- sprintf(
          "%s %s %s CE",
          underlying_symbol,
          format(expiry_date),
          format(strike_price)
        )
        line <- tryCatch(
          {
            option <- IndexOption$new(
              exchange = exchange,
              segment = segment,
              underlying_symbol = underlying_symbol,
              expiry_date = expiry_date,
              strike_price = strike_price,
              option_type = "CE"
            )
            sprintf("Kept %s: lot size %s", label, format(option$lot_size))
          },
          InstrumentError = function(error) {
            sprintf(
              "Dropped %s: %s: %s",
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
  IndexOptionFilter$new()$run()
}
