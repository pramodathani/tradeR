#' Compare the risk in the daily returns of a share, an index and a basket.
#'
#' The program reads a year of daily returns for Infosys, the NIFTY 50 index and an equal-weighted watchlist of three IT shares, and prints for each the annualised return and volatility, the skewness and excess kurtosis, and the fifth percentile daily return as a simple historical value at risk.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/price_statistics/price_statistics/return_risk_report.R

library(tradeR)

#' A table of return and risk measures for several candle sources.
#'
#' @field sources A named list mapping a character label to the instrument or basket whose returns are measured.
#' @field days The integer number of days to count back from today.
#' @field TRADING_DAYS_IN_A_YEAR The integer number of trading days used to annualise, 252.
ReturnRiskReport <- R6::R6Class(
  "ReturnRiskReport",
  public = list(
    TRADING_DAYS_IN_A_YEAR = 252,
    sources = NULL,
    days = NULL,

    #' @description
    #' Creates the report over a share, an index and a watchlist.
    #' @param days The integer number of days to count back from today.
    #' @return A new `ReturnRiskReport` object.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the instruments.
    initialize = function(days = 365) {
      infosys <- Equity$new(exchange = "nse", symbol = "INFY")
      information_technology <- Watchlist$new(
        name = "information technology",
        instruments = list(
          infosys,
          Equity$new(exchange = "nse", symbol = "TCS"),
          Equity$new(exchange = "nse", symbol = "WIPRO")
        )
      )
      self$sources <- list(
        "Infosys" = infosys,
        "NIFTY 50" = EquityIndex$new(exchange = "nse", symbol = "NIFTY"),
        "IT watchlist" = information_technology
      )
      self$days <- days
    },

    #' @description
    #' Measures one source's returns.
    #' @param source The instrument or basket whose returns are measured.
    #' @return A named list of numeric measures with the names `annual_return`, `annual_volatility`, `skewness`, `kurtosis` and `value_at_risk`.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    measure = function(source) {
      daily_mean <- source$returns_mean(days = self$days)
      daily_deviation <- source$returns_standard_deviation(days = self$days)
      list(
        annual_return = daily_mean * self$TRADING_DAYS_IN_A_YEAR,
        annual_volatility = daily_deviation * sqrt(self$TRADING_DAYS_IN_A_YEAR),
        skewness = source$returns_skewness(days = self$days),
        kurtosis = source$returns_kurtosis(days = self$days),
        value_at_risk = source$returns_quantile(
          quantile = 0.05,
          days = self$days
        )
      )
    },

    #' @description
    #' Prints one line of measures for each source.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat(
        sprintf(
          "%-14s%9s%12s%10s%10s%9s\n",
          "Source",
          "Return",
          "Volatility",
          "Skewness",
          "Kurtosis",
          "5% day"
        )
      )
      for (label in names(self$sources)) {
        measures <- self$measure(self$sources[[label]])
        cat(
          sprintf(
            "%-14s%8.1f%%%11.1f%%%10.2f%10.2f%8.2f%%\n",
            label,
            measures[["annual_return"]] * 100,
            measures[["annual_volatility"]] * 100,
            measures[["skewness"]],
            measures[["kurtosis"]],
            measures[["value_at_risk"]] * 100
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ReturnRiskReport$new()$run()
}
