#' Ask to reduce a position under a product UBI cannot close and handle the PositionError.
#'
#' UBI sends orders only under the cnc, mis and nrml products, so a position under a bracket order cannot be reduced through it. The program asks `reduce_position` to reduce an IDEA position under `bracket`, which is refused with PositionError before anything is read or sent, so no order is placed whatever the account holds.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/position_error/name_a_product_that_cannot_be_closed.R

library(tradeR)

#' An attempt to reduce a position held under a bracket order.
#'
#' @field share The `Equity` whose position to reduce.
#' @field product The character product named, which UBI cannot send orders under.
BracketPositionReduction <- R6::R6Class(
  "BracketPositionReduction",
  public = list(
    share = NULL,
    product = NULL,

    #' @description
    #' Creates the attempt for the IDEA share.
    #' @return A new `BracketPositionReduction` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$product <- "bracket"
    },

    #' @description
    #' Asks for the reduction and prints why it is refused.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      answer <- tryCatch(
        self$share$reduce_position(quantity = 1, product = self$product),
        PositionError = function(error) {
          cat(sprintf("PositionError: %s\n", conditionMessage(error)))
          cat(
            "Close such a position at the broker, or name cnc, mis or nrml.\n"
          )
          NULL
        }
      )
      if (is.null(answer)) {
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "Unexpectedly sent: %s\n",
          jsonlite::toJSON(answer, auto_unbox = TRUE, null = "null")
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BracketPositionReduction$new()$run()
}
