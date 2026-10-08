#' Build the candidate objects of a multi-instrument order and show what each overrides.
#'
#' The program builds three order candidates over Vodafone Idea and Yes Bank, one taking every field from the template and two overriding the side, the quantity, the price or the tag, and prints the object UBI would read for each, naming the fields it overrides. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/order_candidate/order_candidate/print_candidate_documents.R

library(tradeR)

#' A report of the candidate objects a multi-instrument order would send.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field second_share The `Equity` for Yes Bank on the NSE.
#' @field candidates The list of `OrderCandidate` the report prints.
CandidateDocumentReport <- R6::R6Class(
  "CandidateDocumentReport",
  public = list(
    share = NULL,
    second_share = NULL,
    candidates = NULL,

    #' @description
    #' Looks up the two shares and builds the candidates.
    #' @return A new `CandidateDocumentReport` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
      self$candidates <- list(
        OrderCandidate$new(self$share),
        OrderCandidate$new(
          self$second_share,
          transaction_type = "sell",
          quantity = 2,
          price = 21.0
        ),
        OrderCandidate$new(
          self$share,
          order_type = "market",
          tag = "exitleg"
        )
      )
    },

    #' @description
    #' Writes a value UBI returned as text for printing, the way Python's f-strings print it.
    #'
    #' A list is written as one line of JSON, `NULL` as `"NULL"` and anything else with `format()`, so a missing field still prints rather than emptying the whole line.
    #' @param value Any value, such as a character, a number, a named list or `NULL`.
    #' @return A character value.
    text_of = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      if (is.list(value)) {
        json <- jsonlite::toJSON(
          value,
          auto_unbox = TRUE,
          null = "null"
        )
        return(as.character(json))
      }
      paste(format(value), collapse = ", ")
    },

    #' @description
    #' Lists the template fields a candidate object overrides.
    #' @param document The named list candidate object built by `OrderCandidate$document()`.
    #' @return A character vector of field names, every key except `instrument_id`.
    overridden_fields = function(document) {
      fields <- character()
      for (field in names(document)) {
        if (field != "instrument_id") {
          fields <- c(fields, field)
        }
      }
      fields
    },

    #' @description
    #' Prints each candidate's instrument, object and overridden fields.
    #' @return `NULL`, invisibly.
    run = function() {
      for (number in seq_along(self$candidates)) {
        candidate <- self$candidates[[number]]
        document <- candidate$document()
        fields <- self$overridden_fields(document)
        cat(sprintf(
          "Candidate %d: %s\n",
          number,
          candidate$instrument$symbol
        ))
        cat(sprintf("  object: %s\n", self$text_of(document)))
        if (length(fields) > 0) {
          cat(sprintf("  overrides: %s\n", paste(fields, collapse = ", ")))
        } else {
          cat("  overrides nothing, so every field comes from the template\n")
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CandidateDocumentReport$new()$run()
}
