#' Look several ids up in UBI, catching UnifiedBrokerInterfaceError for the ones it does not know.
#'
#' The program asks UBI about a broker order id, an order engine parent id and an intent id, all of which are made up, as a program reconciling its own records against UBI might. Each lookup signals NotFoundError, which is caught through the base class UnifiedBrokerInterfaceError and reported with its status code. Nothing is placed, and cancelling an order that does not exist changes nothing.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/not_found_error/look_up_orders_by_id.R

library(tradeR)

#' A reconciliation of made-up order ids against UBI.
#'
#' @field share The `Equity` the order lookups are sent through.
#' @field trading_account The `Account` the intent lookup is sent through.
OrderIdReconciliation <- R6::R6Class(
  "OrderIdReconciliation",
  public = list(
    share = NULL,
    trading_account = NULL,

    #' @description
    #' Creates the reconciliation for the IDEA share and the account.
    #' @return A new `OrderIdReconciliation` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$trading_account <- Account$new()
    },

    #' @description
    #' Cancels a broker order id that no broker holds.
    #' @return The named list UBI answers with, which it never does for this id.
    #' @details Errors: always signals `NotFoundError`, a `UnifiedBrokerInterfaceError` subclass.
    cancel_unknown_order = function() {
      self$share$cancel_order(order_id = "999999999999999")
    },

    #' @description
    #' Reads a parent id the order engine does not hold.
    #' @return The named list UBI answers with, which it never does for this id.
    #' @details Errors: always signals `NotFoundError`, a `UnifiedBrokerInterfaceError` subclass.
    read_unknown_parent = function() {
      self$share$parent("00000000-0000-0000-0000-000000000000")
    },

    #' @description
    #' Reads an intent id the order engine never answered.
    #' @return The named list UBI answers with, which it never does for this id.
    #' @details Errors: always signals `NotFoundError`, a `UnifiedBrokerInterfaceError` subclass.
    read_unknown_intent = function() {
      self$trading_account$intent("00000000000000000000000000000000")
    },

    #' @description
    #' Runs one lookup and prints what UBI said.
    #' @param label The character description of the lookup.
    #' @param lookup A function with no arguments that sends the lookup.
    #' @return `NULL`, invisibly.
    check = function(label, lookup) {
      answer <- tryCatch(
        lookup(),
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(answer, "UnifiedBrokerInterfaceError")) {
        cat(
          sprintf(
            "%s: %s (%s): %s\n",
            label,
            ErrorCatalogue$name_of(answer),
            toString(answer$status_code),
            conditionMessage(answer)
          )
        )
        return(invisible(NULL))
      }
      cat(
        label,
        ": found ",
        jsonlite::toJSON(answer, auto_unbox = TRUE, null = "null"),
        "\n",
        sep = ""
      )
      invisible(NULL)
    },

    #' @description
    #' Runs the three lookups.
    #' @return `NULL`, invisibly.
    run = function() {
      self$check("broker order", self$cancel_unknown_order)
      self$check("engine parent", self$read_unknown_parent)
      self$check("engine intent", self$read_unknown_intent)
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OrderIdReconciliation$new()$run()
}
