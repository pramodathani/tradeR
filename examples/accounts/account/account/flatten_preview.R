#' Preview what the account-wide kill switch would cancel and close.
#'
#' The program asks UBI for a dry run of `Account$flatten()`, which lists the open orders it would cancel and the positions it would close without sending anything, and prints a count of each followed by the details.
#'
#' Typical usage example:
#'
#'   Rscript examples/accounts/account/account/flatten_preview.R

library(tradeR)

#' A dry run of flattening the whole trading account.
#'
#' @field trading_account The `Account` the preview is asked for.
FlattenPreview <- R6::R6Class(
  "FlattenPreview",
  public = list(
    trading_account = NULL,

    #' @description
    #' Creates the preview over the account UBI trades for.
    #' @return A new `FlattenPreview` object.
    initialize = function() {
      self$trading_account <- Account$new()
    },

    #' @description
    #' Prints a heading with a count, then one line per item.
    #' @param heading A character heading, such as `"Orders to cancel"`.
    #' @param items A list of the items UBI reported, each printed as one line of JSON.
    #' @return `NULL`, invisibly.
    print_items = function(heading, items) {
      cat(sprintf("%s: %d\n", heading, length(items)))
      for (item in items) {
        cat(
          "  ",
          jsonlite::toJSON(item, auto_unbox = TRUE, null = "null"),
          "\n",
          sep = ""
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Asks UBI for the dry run and prints what it would do.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    run = function() {
      preview <- self$trading_account$flatten(
        confirm = "FLATTEN",
        dry_run = TRUE
      )
      self$print_items("Orders to cancel", preview[["would_cancel"]])
      self$print_items("Positions to close", preview[["would_close"]])
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  FlattenPreview$new()$run()
}
