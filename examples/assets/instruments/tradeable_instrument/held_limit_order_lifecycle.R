#' Follow a held limit order from placement through a price change to its cancellation.
#'
#' UBI's order engine holds a plain day limit order instead of sending it to a broker, and sends it only once the other side of the book reaches its price. The program bids for one Vodafone Idea share 3 per cent below the market, finds the order among the engine's parents, lowers its price to 4 per cent below, reads it back, and cancels it, checking at the end that nothing is left open. The order is far enough from the market that it is never sent.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/tradeable_instrument/held_limit_order_lifecycle.R

library(tradeR)

#' One held limit order, followed from start to finish.
#'
#' @field share The `Equity` the order is placed in.
#' @field parent_id The character id the engine gave the held order, or `NULL` before it is placed.
HeldLimitOrderLifecycle <- R6::R6Class(
  "HeldLimitOrderLifecycle",
  public = list(
    share = NULL,
    parent_id = NULL,

    #' @description
    #' Looks Vodafone Idea up in UBI.
    #' @return A new `HeldLimitOrderLifecycle` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$parent_id <- NULL
    },

    #' @description
    #' Bids for one share 3 per cent below the last price and keeps the parent id.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order or could not be reached.
    place = function() {
      price <- round(self$share$last_price * 0.97, 2)
      answer <- self$share$buy_at_limit_price(
        price = price,
        quantity = 1,
        product = "cnc"
      )
      self$parent_id <- answer[["parent_id"]]
      cat(sprintf(
        "Placed at %s: %s, parent %s\n",
        format(price),
        answer[["outcome"]],
        self$parent_id
      ))
      invisible(NULL)
    },

    #' @description
    #' Prints the held order as the engine keeps it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the parent.
    show = function() {
      parent <- self$share$parent(self$parent_id)
      cat(sprintf(
        "  state %s, type %s\n",
        parent[["state"]],
        parent[["synthetic_type"]]
      ))
      body_text <- jsonlite::toJSON(
        parent[["body"]],
        auto_unbox = TRUE,
        null = "null"
      )
      cat("  body ", body_text, "\n", sep = "")
      invisible(NULL)
    },

    #' @description
    #' Moves the held order's price to 4 per cent below the last price.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the change.
    lower_price = function() {
      new_price <- round(self$share$last_price * 0.96, 2)
      changed <- self$share$modify_order(
        parent_id = self$parent_id,
        price = new_price
      )
      cat(sprintf(
        "Lowered to %s: %s\n",
        format(new_price),
        changed[["outcome"]]
      ))
      invisible(NULL)
    },

    #' @description
    #' Cancels the held order and checks that no parent of this program is still open.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the cancel.
    cancel = function() {
      cancelled <- self$share$cancel_parent(self$parent_id)
      cat(sprintf("Cancelled: %s\n", cancelled[["state"]]))
      parents <- self$share$parents
      still_open <- FALSE
      if (!is.null(parents)) {
        still_open <- self$parent_id %in% parents$parent_order_id
      }
      cat(sprintf("Still open: %s\n", still_open))
      invisible(NULL)
    },

    #' @description
    #' Places, shows, changes and cancels the order, cancelling it even when a step fails.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      self$place()
      tryCatch(
        {
          self$show()
          self$lower_price()
          self$show()
        },
        finally = self$cancel()
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  HeldLimitOrderLifecycle$new()$run()
}
