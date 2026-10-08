#' Compare what each holding cost with what it is worth now.
#'
#' The program describes three holdings as basket members, each with a quantity and the average price it was bought at, and prints for each one its label, its cost, its value at the last price and the profit, using nothing but the member and its instrument.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/basket_member/basket_member/holding_cost_report.R

library(tradeR)

QUANTITIES <- c(
  IDEA = 100,
  INFY = 5,
  TCS = 2
)

AVERAGE_PRICES <- c(
  IDEA = 12.5,
  INFY = 1450.0,
  TCS = 3100.0
)

#' A cost and value report on a few holdings described as basket members.
#'
#' @field members The list of `BasketMember` objects reported on.
HoldingCostReport <- R6::R6Class(
  "HoldingCostReport",
  public = list(
    members = NULL,

    #' @description
    #' Looks every share up in UBI and describes each holding as a member.
    #' @return A new `HoldingCostReport` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares.
    initialize = function() {
      self$members <- list()
      for (symbol in names(QUANTITIES)) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        member <- BasketMember$new(
          share,
          quantity = QUANTITIES[[symbol]],
          average_price = AVERAGE_PRICES[[symbol]]
        )
        self$members[[length(self$members) + 1]] <- member
      }
    },

    #' @description
    #' Writes an amount in rupees with two decimals and commas between thousands, in a column of the given width.
    #' @param amount The numeric amount.
    #' @param width The integer width of the column.
    #' @param signed A logical that is `TRUE` to always show the sign.
    #' @return A character value.
    amount_text = function(amount, width, signed) {
      flag <- ""
      if (signed) {
        flag <- "+"
      }
      formatC(
        amount,
        format = "f",
        digits = 2,
        big.mark = ",",
        width = width,
        flag = flag
      )
    },

    #' @description
    #' Prints one line per holding and a total.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not give a last price.
    run = function() {
      total_profit <- 0.0
      for (member in self$members) {
        cost <- member$quantity * member$average_price
        value <- member$quantity * member$instrument$last_price
        profit <- value - cost
        total_profit <- total_profit + profit
        cat(
          sprintf(
            "%-10s cost %s  value %s  profit %s\n",
            member$label,
            self$amount_text(cost, 10, FALSE),
            self$amount_text(value, 10, FALSE),
            self$amount_text(profit, 10, TRUE)
          )
        )
      }
      cat(
        sprintf(
          "Total profit: %s\n",
          self$amount_text(total_profit, 0, TRUE)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  HoldingCostReport$new()$run()
}
