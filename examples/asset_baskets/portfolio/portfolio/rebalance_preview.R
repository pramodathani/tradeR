#' Work out what it would take to move a portfolio to an index's weights, without trading.
#'
#' The program describes a lopsided portfolio of three IT shares, builds an equally weighted index of four IT shares as the target, and prints the portfolio's current weights, the trades `rebalance_trades()` works out for the portfolio's own value and for a larger sum of money, and the money each set of trades would move. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/portfolio/portfolio/rebalance_preview.R

library(tradeR)

HELD_QUANTITIES <- c(
  INFY = 40,
  TCS = 5,
  WIPRO = 30
)

TARGET_SYMBOLS <- c(
  "INFY",
  "TCS",
  "HCLTECH",
  "WIPRO"
)

LARGER_CAPITAL <- 200000

#' A preview of the trades that would bring a portfolio to an index's weights.
#'
#' @field held The `Portfolio` as it is held now.
#' @field target The `Index` whose weights are the goal.
RebalancePreview <- R6::R6Class(
  "RebalancePreview",
  public = list(
    held = NULL,
    target = NULL,

    #' @description
    #' Looks the shares up in UBI and builds the portfolio and the target.
    #' @return A new `RebalancePreview` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares.
    initialize = function() {
      shares <- list()
      for (symbol in TARGET_SYMBOLS) {
        shares[[symbol]] <- Equity$new(exchange = "nse", symbol = symbol)
      }
      held_members <- list()
      for (symbol in names(HELD_QUANTITIES)) {
        held_members[[length(held_members) + 1]] <- BasketMember$new(
          shares[[symbol]],
          quantity = HELD_QUANTITIES[[symbol]]
        )
      }
      self$held <- Portfolio$new(
        name = "IT shares held",
        members = held_members
      )
      target_members <- list()
      for (symbol in TARGET_SYMBOLS) {
        target_members[[length(target_members) + 1]] <- BasketMember$new(
          shares[[symbol]]
        )
      }
      self$target <- Index$new(
        name = "IT equal weight",
        members = target_members,
        weighting = "equal"
      )
    },

    #' @description
    #' Prints the trades for one amount of capital and the money they move.
    #' @param heading The character heading to print first.
    #' @param capital The numeric rupees to spread across the target, or `NULL` for the portfolio's value.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when an instrument has no last price.
    print_trades = function(heading, capital) {
      trades <- self$held$rebalance_trades(
        target = self$target,
        capital = capital
      )
      cat(heading, "\n", sep = "")
      columns <- c(
        "label",
        "current_quantity",
        "target_quantity",
        "transaction_type"
      )
      print(trades[, columns])
      turnover <- sum(abs(trades$trade_quantity) * trades$last_price)
      cat(
        sprintf(
          "Money moved: Rs %s\n",
          formatC(turnover, format = "f", digits = 2, big.mark = ",")
        )
      )
      cat("\n")
      invisible(NULL)
    },

    #' @description
    #' Prints the current weights and both previews.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when an instrument has no last price, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      cat(
        sprintf(
          "Portfolio value: Rs %s\n",
          formatC(self$held$value, format = "f", digits = 2, big.mark = ",")
        )
      )
      print(round(self$held$weights, 3))
      cat("\n")
      self$print_trades("Trades at the portfolio's own value:", NULL)
      self$print_trades(
        sprintf(
          "Trades for Rs %s:",
          formatC(LARGER_CAPITAL, format = "d", big.mark = ",")
        ),
        LARGER_CAPITAL
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RebalancePreview$new()$run()
}
