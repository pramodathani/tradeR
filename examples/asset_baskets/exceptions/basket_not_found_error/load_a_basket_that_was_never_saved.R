#' Load a basket that was never saved and handle the BasketNotFoundError.
#'
#' The program asks the basket store in MongoDB for a basket name nobody has saved, catches BasketNotFoundError, and prints the names that are stored instead.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exceptions/basket_not_found_error/load_a_basket_that_was_never_saved.R

library(tradeR)

#' A load of a basket name that was never saved.
#'
#' @field store The `BasketStore` to load from.
#' @field name The character basket name, which nobody has saved.
MissingBasketLoad <- R6::R6Class(
  "MissingBasketLoad",
  public = list(
    store = NULL,
    name = NULL,

    #' @description
    #' Creates the store and the name to load.
    #' @return A new `MissingBasketLoad` object.
    #' @details Errors: signals a plain error when the shared client is not configured.
    initialize = function() {
      self$store <- BasketStore$new()
      self$name <- "Never saved example basket"
    },

    #' @description
    #' Loads the basket and prints the stored names when it is not found.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a mongolite error when MongoDB could not be reached, and an `AssetBasketError` subclass when the stored basket could not be rebuilt.
    run = function() {
      basket <- tryCatch(
        self$store$load(self$name),
        BasketNotFoundError = function(error) error
      )
      if (inherits(basket, "BasketNotFoundError")) {
        cat(sprintf("BasketNotFoundError: %s\n", conditionMessage(basket)))
        stored_names <- self$store$names()
        if (length(stored_names) == 0) {
          cat("No basket is stored at all.\n")
        } else {
          cat(
            sprintf(
              "Stored baskets: %s\n",
              jsonlite::toJSON(stored_names)
            )
          )
        }
        return(invisible(NULL))
      }
      cat(sprintf("Loaded %s\n", basket$format()))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MissingBasketLoad$new()$run()
}
