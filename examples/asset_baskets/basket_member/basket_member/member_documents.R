#' Show how basket members are described when a basket is stored.
#'
#' The program builds one weighted member for a share, one for an exchange traded fund and one for an index, prints each member as it appears in R and then the fields `document()` gives it for MongoDB, which name the instrument by its UBI id beside its readable identity.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/basket_member/basket_member/member_documents.R

library(tradeR)

#' A printout of a few members and their stored form.
#'
#' @field members The list of `BasketMember` objects printed.
MemberDocuments <- R6::R6Class(
  "MemberDocuments",
  public = list(
    members = NULL,

    #' @description
    #' Looks the three instruments up in UBI and makes a weighted member of each.
    #' @return A new `MemberDocuments` object.
    #' @details Errors: signals an `InstrumentError` subclass when UBI does not know one of the instruments.
    initialize = function() {
      infosys <- Equity$new(exchange = "nse", symbol = "INFY")
      gold_fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES")
      nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      self$members <- list(
        BasketMember$new(infosys, weight = 0.5),
        BasketMember$new(gold_fund, weight = 0.3),
        BasketMember$new(nifty, weight = 0.2)
      )
    },

    #' @description
    #' Prints each member and its stored fields.
    #' @return `NULL`, invisibly.
    run = function() {
      fields <- c(
        "instrument_id",
        "segment",
        "symbol",
        "weight"
      )
      for (member in self$members) {
        print(member)
        document <- member$document()
        for (field in fields) {
          cat(sprintf("  %-14s %s\n", field, toString(document[[field]])))
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MemberDocuments$new()$run()
}
