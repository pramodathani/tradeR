#' Build a basket from a document naming a kind the store does not know, and handle the AssetBasketError.
#'
#' `BasketStore$build()` turns a stored document into the basket class its `kind` names, such as `index` or `watchlist`. The program gives it a document whose kind is `collection`, catches the AssetBasketError, and builds the same members as a watchlist instead. Nothing is saved to MongoDB.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exceptions/asset_basket_error/build_a_basket_of_an_unknown_kind.R

library(tradeR)

#' A basket document whose kind the store does not know.
#'
#' @field store The `BasketStore` that builds the basket.
#' @field document The named list basket document to build.
UnknownKindBuild <- R6::R6Class(
  "UnknownKindBuild",
  public = list(
    store = NULL,
    document = NULL,

    #' @description
    #' Creates the store and the document.
    #' @return A new `UnknownKindBuild` object.
    #' @details Errors: signals a plain error when the shared client is not configured.
    initialize = function() {
      self$store <- BasketStore$new()
      self$document <- list(
        name = "Telecom example",
        kind = "collection",
        members = list(
          list(
            exchange = "nse",
            segment = "equities",
            symbol = "IDEA"
          ),
          list(
            exchange = "nse",
            segment = "equities",
            symbol = "BHARTIARTL"
          )
        )
      )
    },

    #' @description
    #' Builds the document, falling back to a watchlist when its kind is unknown.
    #' @return The `AssetBasket` built.
    #' @details Errors: signals `BasketMemberError` when UBI could not find one of the members, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    build = function() {
      basket <- tryCatch(
        self$store$build(self$document),
        AssetBasketError = function(error) error
      )
      if (!inherits(basket, "AssetBasketError")) {
        return(basket)
      }
      cat(sprintf("AssetBasketError: %s\n", conditionMessage(basket)))
      self$document[["kind"]] <- "watchlist"
      self$store$build(self$document)
    },

    #' @description
    #' Builds the basket and prints its class and members.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when UBI could not find one of the members, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      basket <- self$build()
      cat(sprintf("Built %s\n", basket$format()))
      for (label in basket$labels) {
        cat(sprintf("  %s\n", label))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  UnknownKindBuild$new()$run()
}
