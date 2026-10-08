#' Cancel an order engine parent that does not exist and handle the NotFoundError.
#'
#' A parent id that was mistyped, or that belongs to a parent the engine has long forgotten, is unknown to UBI's order engine. The program asks to cancel such a parent on the IDEA share, catches NotFoundError, and prints UBI's explanation. Nothing is placed or cancelled.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/not_found_error/cancel_a_parent_that_does_not_exist.R

library(tradeR)

#' A cancel request for a parent the order engine does not hold.
#'
#' @field share The `Equity` the cancel is sent through.
#' @field parent_id The character parent id, which no parent has.
UnknownParentCancel <- R6::R6Class(
  "UnknownParentCancel",
  public = list(
    share = NULL,
    parent_id = NULL,

    #' @description
    #' Creates the request for the IDEA share.
    #' @return A new `UnknownParentCancel` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$parent_id <- "00000000-0000-0000-0000-000000000000"
    },

    #' @description
    #' Sends the cancel and prints why it was refused.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI failed for a reason other than an unknown parent.
    run = function() {
      answer <- tryCatch(
        self$share$cancel_parent(self$parent_id),
        NotFoundError = function(error) error
      )
      if (inherits(answer, "NotFoundError")) {
        cat(
          sprintf(
            "NotFoundError (%s): %s\n",
            answer$status_code,
            conditionMessage(answer)
          )
        )
        return(invisible(NULL))
      }
      cat(
        "Unexpectedly cancelled: ",
        jsonlite::toJSON(answer, auto_unbox = TRUE, null = "null"),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  UnknownParentCancel$new()$run()
}
