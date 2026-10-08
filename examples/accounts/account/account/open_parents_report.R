#' Report the synthetic and held orders the order engine is working across the whole account.
#'
#' The program reads the account's open parents once and prints how many there are of each synthetic order type and in each state.
#'
#' Typical usage example:
#'
#'   Rscript examples/accounts/account/account/open_parents_report.R

library(tradeR)

#' A report of the open parents in the whole trading account.
#'
#' @field trading_account The `Account` the report reads.
OpenParentsReport <- R6::R6Class(
  "OpenParentsReport",
  public = list(
    trading_account = NULL,

    #' @description
    #' Creates the report over the account UBI trades for.
    #' @return A new `OpenParentsReport` object.
    initialize = function() {
      self$trading_account <- Account$new()
    },

    #' @description
    #' Reads the open parents and prints a count by type and by state, most common first.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      parents <- self$trading_account$parents
      if (is.null(parents)) {
        cat("The order engine is not working any parent.\n")
        return(invisible(NULL))
      }
      cat(sprintf("Open parents: %d\n", nrow(parents)))
      print(sort(table(parents$synthetic_type), decreasing = TRUE))
      print(sort(table(parents$state), decreasing = TRUE))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OpenParentsReport$new()$run()
}
