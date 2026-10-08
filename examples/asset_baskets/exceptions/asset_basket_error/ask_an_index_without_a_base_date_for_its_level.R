#' Ask an index basket with no base date for its level and handle the AssetBasketError.
#'
#' An Index basket's level is its base value moved by its members' prices since its base date, so an index built without a base date has no level and signals AssetBasketError. The program builds an equally weighted index of three shares without a base date, catches the error, and prints the index's weights instead.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exceptions/asset_basket_error/ask_an_index_without_a_base_date_for_its_level.R

library(tradeR)

#' An equally weighted index of three shares with no base date.
#'
#' @field telecom_index The `Index` of the three shares.
IndexLevelCheck <- R6::R6Class(
  "IndexLevelCheck",
  public = list(
    telecom_index = NULL,

    #' @description
    #' Builds the index from IDEA, BHARTIARTL and INDUSTOWER.
    #' @return A new `IndexLevelCheck` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    initialize = function() {
      symbols <- c(
        "IDEA",
        "BHARTIARTL",
        "INDUSTOWER"
      )
      members <- list()
      for (symbol in symbols) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        members[[length(members) + 1]] <- BasketMember$new(share)
      }
      self$telecom_index <- Index$new(
        name = "Telecom example",
        members = members,
        weighting = "equal"
      )
    },

    #' @description
    #' Asks for the level and prints the weights when there is none.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      level <- tryCatch(
        self$telecom_index$level,
        AssetBasketError = function(error) error
      )
      if (inherits(level, "AssetBasketError")) {
        cat(sprintf("AssetBasketError: %s\n", conditionMessage(level)))
        cat("Weights:\n")
        print(self$telecom_index$weights)
        return(invisible(NULL))
      }
      cat(sprintf("Level: %s\n", level))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexLevelCheck$new()$run()
}
