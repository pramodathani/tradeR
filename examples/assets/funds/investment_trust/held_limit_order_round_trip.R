#' Place a held limit order for one EMBASSY unit and cancel it straight away.
#'
#' The program bids for one unit of the trust, for delivery, at a limit 3 per cent below the last price, rounded to the tick. UBI's order engine holds such an order rather than sending it, and answers with a `parent_id`. The program lists the trust's open parents to show the order is there, then cancels it, whatever happens in between, and confirms it is gone.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/funds/investment_trust/held_limit_order_round_trip.R

library(tradeR)

#' One held limit order placed and cancelled on an investment trust.
#'
#' @field trust The `InvestmentTrust` the order is placed on.
#' @field discount The numeric fraction below the last price the bid is placed at.
HeldLimitOrderRoundTrip <- R6::R6Class(
  "HeldLimitOrderRoundTrip",
  public = list(
    trust = NULL,
    discount = NULL,

    #' @description
    #' Looks EMBASSY up in UBI.
    #' @return A new `HeldLimitOrderRoundTrip` object.
    #' @details Errors: signals `InvestmentTrustError` when UBI has no such trust, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    initialize = function() {
      self$trust <- InvestmentTrust$new(exchange = "nse", symbol = "EMBASSY")
      self$discount <- 0.03
    },

    #' @description
    #' Places the bid, lists the open parents, cancels the bid whatever happens and lists them again.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      last_price <- self$trust$last_price
      tick_size <- as.numeric(self$trust$tick_size)
      ticks <- round(last_price * (1 - self$discount) / tick_size)
      limit_price <- round(ticks * tick_size, 2)
      cat(
        sprintf(
          "Last price %s, bidding %s for one unit\n",
          last_price,
          limit_price
        )
      )
      answer <- self$trust$buy_at_limit_price(
        price = limit_price,
        quantity = 1,
        product = "cnc",
        tag = "exampletrust"
      )
      parent_id <- answer[["parent_id"]]
      cat(
        sprintf("Outcome: %s, parent: %s\n", answer[["outcome"]], parent_id)
      )
      tryCatch(
        private$print_parents("Open parents after placing"),
        finally = {
          cancelled <- self$trust$cancel_parent(parent_id)
          cat(sprintf("Cancelled: state %s\n", cancelled[["state"]]))
        }
      )
      private$print_parents("Open parents after cancelling")
      invisible(NULL)
    }
  ),
  private = list(
    # Prints the trust's open parents under a heading.
    # @param heading The character line to print first.
    # @return `NULL`, invisibly.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    print_parents = function(heading) {
      cat(heading, "\n", sep = "")
      parents <- self$trust$parents
      if (is.null(parents)) {
        cat("  none\n")
        return(invisible(NULL))
      }
      columns <- c(
        "parent_order_id",
        "synthetic_type",
        "state"
      )
      print(parents[, columns, drop = FALSE])
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  HeldLimitOrderRoundTrip$new()$run()
}
