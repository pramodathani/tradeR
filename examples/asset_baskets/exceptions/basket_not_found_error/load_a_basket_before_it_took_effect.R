#' Load a basket as of a day before any version took effect, catching AssetBasketError.
#'
#' Every stored basket version has an effective date, and a basket asked for as of an earlier day is not found. The program asks for the NIFTY basket as of 1 January 1990, catches the BasketNotFoundError through its base class AssetBasketError, and then reads the basket's version history, which is `NULL` when no version is stored at all.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exceptions/basket_not_found_error/load_a_basket_before_it_took_effect.R

library(tradeR)

#' A load of a basket as of a day before it took effect.
#'
#' @field store The `BasketStore` to load from.
#' @field name The character name of the basket.
#' @field as_of The character day to load the basket as of.
EarlyBasketLoad <- R6::R6Class(
  "EarlyBasketLoad",
  public = list(
    store = NULL,
    name = NULL,
    as_of = NULL,

    #' @description
    #' Creates the store and the load to try.
    #' @return A new `EarlyBasketLoad` object.
    #' @details Errors: signals a plain error when the shared client is not configured.
    initialize = function() {
      self$store <- BasketStore$new()
      self$name <- "NIFTY"
      self$as_of <- "1990-01-01"
    },

    #' @description
    #' Loads the basket and prints its history when it is not found.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a mongolite error when MongoDB could not be reached.
    run = function() {
      basket <- tryCatch(
        self$store$load(self$name, as_of = self$as_of),
        AssetBasketError = function(error) error
      )
      if (inherits(basket, "AssetBasketError")) {
        cat(
          sprintf(
            "%s: %s\n",
            ErrorCatalogue$name_of(basket),
            conditionMessage(basket)
          )
        )
        history <- self$store$history(self$name)
        if (is.null(history)) {
          cat(sprintf("No version of '%s' is stored at all.\n", self$name))
        } else {
          print(history, row.names = FALSE)
        }
        return(invisible(NULL))
      }
      cat(sprintf("Loaded %s\n", basket$format()))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  EarlyBasketLoad$new()$run()
}
