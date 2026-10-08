#' Measure how closely the NIFTYBEES fund follows its largest holdings.
#'
#' The program describes NIFTYBEES by its ten largest holdings with approximate weights, links them to the fund itself, and prints over three months and a year the fund's return minus the holdings' return, the tracking error between the two, and today's moves of the fund and of the holdings side by side. The weights are an illustration rather than the fund's published portfolio, so the numbers show how the measures work rather than how good the fund is.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exchange_traded_fund_constituents/exchange_traded_fund_constituents/niftybees_tracking_report.R

library(tradeR)

WEIGHTS <- c(
  HDFCBANK = 13.0,
  ICICIBANK = 9.0,
  RELIANCE = 8.5,
  INFY = 5.0,
  BHARTIARTL = 4.5,
  LT = 4.0,
  ITC = 3.5,
  TCS = 3.0,
  SBIN = 3.0,
  AXISBANK = 3.0
)

RANGES_IN_DAYS <- c(
  90,
  365
)

#' A tracking report on NIFTYBEES against a basket of its largest holdings.
#'
#' @field holdings The `ExchangeTradedFundConstituents` linked to NIFTYBEES.
NiftybeesTrackingReport <- R6::R6Class(
  "NiftybeesTrackingReport",
  public = list(
    holdings = NULL,

    #' @description
    #' Looks the fund and its holdings up in UBI and builds the basket.
    #' @return A new `NiftybeesTrackingReport` object.
    #' @details Errors: signals an `InstrumentError` subclass when UBI does not know one of the instruments.
    initialize = function() {
      members <- list()
      for (symbol in names(WEIGHTS)) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        members[[length(members) + 1]] <- BasketMember$new(
          share,
          weight = WEIGHTS[[symbol]]
        )
      }
      fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
      self$holdings <- ExchangeTradedFundConstituents$new(
        name = "NIFTYBEES top ten",
        members = members,
        fund = fund
      )
    },

    #' @description
    #' Prints the tracking measures for each range and today's moves.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for a holding's candles, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      fund <- self$holdings$fund
      cat(
        sprintf("%s against %d holdings\n", fund$symbol, self$holdings$size)
      )
      for (days in RANGES_IN_DAYS) {
        difference <- self$holdings$tracking_difference(days = days)
        error <- fund$tracking_error(benchmark = self$holdings, days = days)
        cat(
          sprintf(
            "%d days: tracking difference %+.2f%%, tracking error %.2f%%\n",
            days,
            difference * 100,
            error * 100
          )
        )
      }
      cat(sprintf("Fund's last price: %s\n", toString(fund$last_price)))
      cat(
        sprintf(
          "Holdings today: %+.2f%%\n",
          self$holdings$day_change_percent
        )
      )
      premium <- self$holdings$premium_or_discount
      premium_text <- "NULL"
      if (!is.null(premium)) {
        premium_text <- as.character(premium)
      }
      cat(sprintf("Premium to indicative value: %s\n", premium_text))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  NiftybeesTrackingReport$new()$run()
}
