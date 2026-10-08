#' Turn a weighted index into whole shares for a sum of money and preview the orders.
#'
#' The program builds an index of four bank shares with stated weights, turns it into a portfolio of whole shares for one lakh rupees at last prices, prints the quantities, what they cost and how much money is left over, and asks UBI to build the market orders as a dry run, so nothing is sent to a broker.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/index/index/index_to_portfolio_orders.R

library(tradeR)

WEIGHTS <- c(
  HDFCBANK = 40,
  ICICIBANK = 30,
  AXISBANK = 15,
  SBIN = 15
)

CAPITAL <- 100000

#' A weighted bank index bought, on paper, for a fixed sum.
#'
#' @field bank_index The `Index` of bank shares.
IndexToPortfolioOrders <- R6::R6Class(
  "IndexToPortfolioOrders",
  public = list(
    bank_index = NULL,

    #' @description
    #' Looks the shares up in UBI and builds the index.
    #' @return A new `IndexToPortfolioOrders` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares.
    initialize = function() {
      members <- list()
      for (symbol in names(WEIGHTS)) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        members[[length(members) + 1]] <- BasketMember$new(
          share,
          weight = WEIGHTS[[symbol]]
        )
      }
      self$bank_index <- Index$new(name = "banks", members = members)
    },

    #' @description
    #' Prints the portfolio for the capital and UBI's dry-run orders for it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when a member has no last price, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      holdings <- self$bank_index$to_portfolio(capital = CAPITAL)
      print(holdings$quantities)
      spent <- holdings$value
      cat(
        sprintf(
          "Spent Rs %s of Rs %s, Rs %s left\n",
          formatC(spent, format = "f", digits = 2, big.mark = ","),
          formatC(CAPITAL, format = "d", big.mark = ","),
          formatC(CAPITAL - spent, format = "f", digits = 2, big.mark = ",")
        )
      )
      orders <- holdings$place_orders(product = "cnc", dry_run = TRUE)
      columns <- c(
        "label",
        "transaction_type",
        "quantity",
        "status"
      )
      print(orders[, columns])
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexToPortfolioOrders$new()$run()
}
