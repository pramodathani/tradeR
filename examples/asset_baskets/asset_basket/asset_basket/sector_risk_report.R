#' Measure how the members of a basket of bank shares move together over a year.
#'
#' The program builds an equally weighted basket of five bank shares and prints, over the last year of day candles, the correlation of their returns, each member's share of the basket's risk, the diversification ratio, what each member added to the basket's return, and the basket's own Sharpe ratio and maximum drawdown.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/asset_basket/asset_basket/sector_risk_report.R

library(tradeR)

SYMBOLS <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)

DAYS <- 365

RISK_FREE_RATE <- 0.065

#' A year's risk report on an equally weighted basket of bank shares.
#'
#' @field basket The `AssetBasket` being measured.
SectorRiskReport <- R6::R6Class(
  "SectorRiskReport",
  public = list(
    basket = NULL,

    #' @description
    #' Looks every share up in UBI and builds the basket.
    #' @return A new `SectorRiskReport` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares.
    initialize = function() {
      members <- list()
      for (symbol in SYMBOLS) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        members[[length(members) + 1]] <- BasketMember$new(share)
      }
      self$basket <- AssetBasket$new(name = "banks", members = members)
    },

    #' @description
    #' Prints every measure over the last year.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for a member's candles, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      cat("Correlation of daily returns:\n")
      print(round(self$basket$correlation_matrix(days = DAYS), 2))
      cat("\n")
      cat("Share of the basket's risk:\n")
      print(round(self$basket$risk_contributions(days = DAYS), 3))
      cat("\n")
      ratio <- self$basket$diversification_ratio(days = DAYS)
      cat(sprintf("Diversification ratio: %.2f\n", ratio))
      cat("\n")
      cat("What each member added to the return:\n")
      print(round(self$basket$return_contributions(days = DAYS), 4))
      cat("\n")
      sharpe <- self$basket$sharpe_ratio(
        risk_free_rate = RISK_FREE_RATE,
        days = DAYS
      )
      drawdown <- self$basket$maximum_drawdown(days = DAYS)
      cat(sprintf("Sharpe ratio: %.2f\n", sharpe))
      cat(sprintf("Maximum drawdown: %.2f%%\n", drawdown * 100))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SectorRiskReport$new()$run()
}
