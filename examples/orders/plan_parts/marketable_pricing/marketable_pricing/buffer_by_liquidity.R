#' Choose a marketable buffer by how liquid the instrument is, and compare what each buffer allows in rupees.
#'
#' A marketable limit is sent a few ticks past the other side of the book, so a buffer that is too small misses the fill in a thin market and one too large allows a bad fill. The program reads Vodafone Idea's tick size and prints, for a liquid, an ordinary and a thin market, the buffer chosen, its `MarketablePricing` object and how far in rupees past the touch it reaches. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/marketable_pricing/marketable_pricing/buffer_by_liquidity.R

library(tradeR)

#' Marketable buffers for three kinds of market.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field buffers The named list of a character kind of market to the integer buffer in ticks chosen for it.
BufferByLiquidity <- R6::R6Class(
  "BufferByLiquidity",
  public = list(
    share = NULL,
    buffers = NULL,

    #' @description
    #' Looks up the share and sets the buffers.
    #' @return A new `BufferByLiquidity` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$buffers <- list(
        liquid = 1,
        ordinary = 2,
        thin = 6
      )
    },

    #' @description
    #' Prints each buffer's object and its reach in rupees.
    #' @return `NULL`, invisibly.
    run = function() {
      tick_size <- 0.05
      if (!is.null(self$share$tick_size)) {
        tick_size <- as.numeric(self$share$tick_size)
      }
      cat(sprintf("Tick size of %s: %s\n", self$share$symbol, tick_size))
      for (market in names(self$buffers)) {
        buffer_ticks <- self$buffers[[market]]
        pricing <- MarketablePricing$new(buffer_ticks = buffer_ticks)
        reach <- round(buffer_ticks * tick_size, 2)
        document <- jsonlite::toJSON(
          pricing$document(),
          auto_unbox = TRUE,
          null = "null",
          digits = NA
        )
        cat(
          sprintf(
            "%-9s %s reaches %s rupees past the touch\n",
            market,
            document,
            reach
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BufferByLiquidity$new()$run()
}
