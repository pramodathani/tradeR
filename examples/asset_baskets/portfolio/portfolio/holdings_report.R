#' Report the account's long-term holdings as one portfolio.
#'
#' The program builds a portfolio from the holdings UBI reports across every broker and prints each holding's quantity, value and weight, then the portfolio's total value, what was paid for it, its unrealised profit, and today's profit and move. It only reads; nothing is traded.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/portfolio/portfolio/holdings_report.R

library(tradeR)

#' A report on the account's holdings, read as a portfolio.
#'
#' @field held The `Portfolio` of the holdings, or `NULL` when the account holds nothing.
HoldingsReport <- R6::R6Class(
  "HoldingsReport",
  public = list(
    held = NULL,

    #' @description
    #' Reads the holdings from UBI and builds the portfolio.
    #' @return A new `HoldingsReport` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    initialize = function() {
      held <- tryCatch(
        Portfolio$from_holdings(),
        BasketMemberError = function(error) error
      )
      if (inherits(held, "BasketMemberError")) {
        cat(sprintf("No portfolio: %s\n", conditionMessage(held)))
        held <- NULL
      }
      self$held <- held
    },

    #' @description
    #' Prints each holding's quantity, value and weight.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when a holding has no last price.
    print_table = function() {
      table <- data.frame(
        quantity = self$held$quantities,
        value = self$held$values,
        weight = self$held$weights
      )
      print(round(table, 3))
      invisible(NULL)
    },

    #' @description
    #' Prints the portfolio's value, cost, unrealised profit and today's result.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    print_totals = function() {
      cat(sprintf("Value:             %s\n", self$rounded(self$held$value)))
      cat(
        sprintf(
          "Invested:          %s\n",
          self$rounded(self$held$invested_value)
        )
      )
      cat(
        sprintf(
          "Unrealised profit: %s\n",
          self$rounded(self$held$unrealized_pnl)
        )
      )
      cat(sprintf("Today's profit:    %s\n", self$rounded(self$held$day_pnl)))
      cat(
        sprintf(
          "Today's move (%%):  %s\n",
          self$rounded(self$held$day_change_percent)
        )
      )
      invisible(NULL)
    },

    #' @description
    #' Rounds an amount to two decimal places for printing, writing `NULL` for an amount that is unknown.
    #' @param amount The numeric amount, or `NULL` when it is unknown.
    #' @return A character value of the amount rounded to two decimal places, or `"NULL"`.
    rounded = function(amount) {
      if (is.null(amount)) {
        return("NULL")
      }
      as.character(round(amount, 2))
    },

    #' @description
    #' Prints the table and the totals, or nothing more when there are no holdings.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      if (is.null(self$held)) {
        return(invisible(NULL))
      }
      cat(sprintf("%d holdings\n", self$held$size))
      self$print_table()
      self$print_totals()
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  HoldingsReport$new()$run()
}
