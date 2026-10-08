#' Build the watched objects of an exposure hedge from a set of weights.
#'
#' The program turns a table of weights for Vodafone Idea and Yes Bank, such as betas against the market, into exposure watches and prints the object UBI would read for each, then the watch list of an exposure hedge built from them. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/exposure_watch/exposure_watch/print_watch_documents.R

library(tradeR)

#' A report of the watched objects built from a table of weights.
#'
#' @field weights The named numeric vector of NSE symbol to the exposure one share of it carries.
#' @field watches The list of `ExposureWatch` built from the weights.
WatchDocumentReport <- R6::R6Class(
  "WatchDocumentReport",
  public = list(
    weights = NULL,
    watches = NULL,

    #' @description
    #' Builds one watch per weighted share.
    #' @return A new `WatchDocumentReport` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$weights <- c(
        IDEA = 1.3,
        YESBANK = 0.9
      )
      self$watches <- list()
      for (symbol in names(self$weights)) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        watch <- ExposureWatch$new(
          share,
          exposure_per_unit = self$weights[[symbol]]
        )
        self$watches[[length(self$watches) + 1]] <- watch
      }
    },

    #' @description
    #' Prints each watch's object and the watch list of a hedge built from them.
    #' @return `NULL`, invisibly.
    run = function() {
      for (watch in self$watches) {
        cat(
          watch$instrument$symbol, ": ",
          jsonlite::toJSON(watch$document(), auto_unbox = TRUE, null = "null"),
          "\n",
          sep = ""
        )
      }
      hedge <- ExposureHedgeOrder$new(
        self$watches[[1]]$instrument,
        watched = self$watches,
        lower_band = -50,
        upper_band = 50,
        product = "mis"
      )
      cat(sprintf(
        "Hedge watches %d instruments\n",
        length(hedge$synthetic[["watched"]])
      ))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  WatchDocumentReport$new()$run()
}
