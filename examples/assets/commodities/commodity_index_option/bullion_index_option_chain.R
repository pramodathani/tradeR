#' Print the size and shape of the bullion index option chain on the mcx.
#'
#' The program lists the MCXBULLDEX option expiries and, for each, counts the calls and puts listed and the range of strikes they cover.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_index_option/bullion_index_option_chain.R

library(tradeR)

#' The option chains on one commodity index, one line per expiry and type.
#'
#' @field underlying_symbol The character mcx symbol of the index, such as `"MCXBULLDEX"`.
BullionIndexOptionChain <- R6::R6Class(
  "BullionIndexOptionChain",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the index whose chains to describe.
    #' @param underlying_symbol The character mcx symbol of the index.
    #' @return A new `BullionIndexOptionChain` object.
    initialize = function(underlying_symbol = "MCXBULLDEX") {
      self$underlying_symbol <- underlying_symbol
    },

    #' @description
    #' Reads each expiry's chain and prints its summary.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiries <- CommodityIndexOption$expiries(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        cat(sprintf("No options are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      option_types <- c(
        "CE",
        "PE"
      )
      for (expiry_index in seq_along(expiries)) {
        expiry_date <- expiries[[expiry_index]]
        chain <- CommodityIndexOption$chain(
          exchange = "mcx",
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date
        )
        if (is.null(chain)) {
          cat(sprintf("%s: empty\n", format(expiry_date)))
          next
        }
        for (option_type in option_types) {
          rows <- chain[chain$option_type == option_type, , drop = FALSE]
          if (nrow(rows) == 0) {
            next
          }
          lowest <- min(rows$strike_price)
          highest <- max(rows$strike_price)
          cat(
            sprintf(
              "%s %s: %d strikes from %s to %s\n",
              format(expiry_date),
              option_type,
              nrow(rows),
              lowest,
              highest
            )
          )
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BullionIndexOptionChain$new()$run()
}
