#' Work out how many Nifty futures lots would hedge a share portfolio.
#'
#' A portfolio of shares loses money when the market falls, and selling index futures of the same value offsets that. The program values a small hypothetical portfolio at live prices, builds the next month's Nifty future, and prints how many lots, rounded down, bring the hedge closest to the portfolio's value without going over, and what fraction is left unhedged. It places no orders.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/index_futures/portfolio_hedge_ratio.R

library(tradeR)

#' A hedge of a share portfolio with Nifty futures.
#'
#' @field share_counts A named list mapping each character share symbol to the integer number of shares held.
PortfolioHedgeRatio <- R6::R6Class(
  "PortfolioHedgeRatio",
  public = list(
    share_counts = NULL,

    #' @description
    #' Stores the hypothetical portfolio.
    #' @return A new `PortfolioHedgeRatio` object.
    initialize = function() {
      self$share_counts <- list(
        RELIANCE = 400,
        INFY = 500,
        HDFCBANK = 600,
        TCS = 200
      )
    },

    #' @description
    #' Values the portfolio at the shares' last prices.
    #' @return The numeric value in rupees.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    portfolio_value = function() {
      total <- 0
      for (symbol in names(self$share_counts)) {
        share_count <- self$share_counts[[symbol]]
        share <- Equity$new(exchange = "nse", symbol = symbol)
        total <- total + share_count * share$last_price
      }
      total
    },

    #' @description
    #' Prints the portfolio's value and the hedge.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      value <- self$portfolio_value()
      expiries <- EquityIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      future <- EquityIndexFutures$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiries[[2]]
      )
      lot_value <- future$contract_value
      lots <- as.integer(value %/% lot_value)
      hedged <- lots * lot_value
      unhedged_percent <- (value - hedged) / value * 100
      cat(sprintf(
        "Portfolio worth Rs %s\n",
        formatC(value, format = "f", digits = 0, big.mark = ",")
      ))
      cat(sprintf(
        "%s one lot of %s worth Rs %s\n",
        future$format(),
        format(future$lot_size),
        formatC(lot_value, format = "f", digits = 0, big.mark = ",")
      ))
      cat(sprintf(
        "Sell %d lots to hedge Rs %s\n",
        lots,
        formatC(hedged, format = "f", digits = 0, big.mark = ",")
      ))
      cat(sprintf("Unhedged: %.1f%% of the portfolio\n", unhedged_percent))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  PortfolioHedgeRatio$new()$run()
}
