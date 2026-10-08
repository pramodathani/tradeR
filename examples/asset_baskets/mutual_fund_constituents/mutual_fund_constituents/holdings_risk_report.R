#' Measure a mutual fund's risk through its holdings, since the fund itself has no prices in UBI.
#'
#' The program shows that the scheme has no candles of its own, then describes it by a few of its disclosed holdings with illustrative weights and prints the holdings' performance summary over a year against the NIFTY index, and the correlation between the holdings.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/mutual_fund_constituents/mutual_fund_constituents/holdings_risk_report.R

library(tradeR)

WEIGHTS <- c(
  HDFCBANK = 9.0,
  ICICIBANK = 7.5,
  INFY = 6.0,
  RELIANCE = 5.5
)

DAYS <- 365

RISK_FREE_RATE <- 0.065

#' A year's risk report on a scheme, measured through its holdings.
#'
#' @field holdings The `MutualFundConstituents` of the scheme.
#' @field nifty The `EquityIndex` for NIFTY, the benchmark.
HoldingsRiskReport <- R6::R6Class(
  "HoldingsRiskReport",
  public = list(
    holdings = NULL,
    nifty = NULL,

    #' @description
    #' Looks the scheme, its holdings and the benchmark up in UBI.
    #' @return A new `HoldingsRiskReport` object.
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
      scheme <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
      self$holdings <- MutualFundConstituents$new(
        name = "ABSLFTTIDG",
        members = members,
        fund = scheme,
        unmapped_weight = 0.1
      )
      self$nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    },

    #' @description
    #' Prints the scheme's own lack of candles and the holdings' measures. The summary is a named list in R rather than a pandas Series, so it is printed one measure per line, with `NULL` for a measure that cannot be calculated.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for a holding's candles, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      cat("The scheme's own candles:\n")
      print(self$holdings$fund$prices(days = DAYS))
      summary <- self$holdings$performance_summary(
        benchmark = self$nifty,
        risk_free_rate = RISK_FREE_RATE,
        days = DAYS
      )
      cat("The holdings over a year against NIFTY:\n")
      for (measure in names(summary)) {
        value <- summary[[measure]]
        value_text <- "NULL"
        if (!is.null(value)) {
          value_text <- format(round(value, 4))
        }
        cat(sprintf("%-28s %s\n", measure, value_text))
      }
      cat("\n")
      print(round(self$holdings$correlation_matrix(days = DAYS), 2))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  HoldingsRiskReport$new()$run()
}
