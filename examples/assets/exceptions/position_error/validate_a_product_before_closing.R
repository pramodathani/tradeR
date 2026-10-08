#' Check which products `liquidate_position` accepts, catching InstrumentError.
#'
#' The program asks `liquidate_position` to close an IDEA position under each of `cover`, `margin_trading` and `bracket`, three products UBI reports positions under but cannot send orders for. Each is refused with PositionError before anything is read or sent, which one handler for the base class InstrumentError catches, so no order is placed whatever the account holds.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/position_error/validate_a_product_before_closing.R

library(tradeR)

#' A check that the products UBI cannot send orders under are refused.
#'
#' @field share The `Equity` whose position is named.
#' @field products The character vector of products to try.
ProductValidation <- R6::R6Class(
  "ProductValidation",
  public = list(
    share = NULL,
    products = NULL,

    #' @description
    #' Creates the check for the IDEA share.
    #' @return A new `ProductValidation` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$products <- c(
        "cover",
        "margin_trading",
        "bracket"
      )
    },

    #' @description
    #' Tries every product and prints the refusal for each.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      for (product in self$products) {
        line <- tryCatch(
          {
            answer <- self$share$liquidate_position(product = product)
            sprintf(
              "%s: unexpectedly sent %s",
              product,
              jsonlite::toJSON(answer, auto_unbox = TRUE, null = "null")
            )
          },
          InstrumentError = function(error) {
            sprintf("%s: refused with %s", product, class(error)[[1]])
          }
        )
        cat(line, "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ProductValidation$new()$run()
}
