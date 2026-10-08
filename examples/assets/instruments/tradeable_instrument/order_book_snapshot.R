#' Print a snapshot of a share's order book and the trading figures around it.
#'
#' The program builds Infosys as a TradeableInstrument and prints the five visible levels on each side of its order book, the spread in rupees and in ticks, the mid price, today's volume weighted average price, the size and time of the last trade and the volume so far. Each figure is read from UBI when it is asked for, so the snapshot takes a moment and its parts may be a moment apart.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/tradeable_instrument/order_book_snapshot.R

library(tradeR)

#' A printed snapshot of one tradeable instrument's order book.
#'
#' @field share The `TradeableInstrument` whose book is printed.
OrderBookSnapshot <- R6::R6Class(
  "OrderBookSnapshot",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up in UBI.
    #' @param symbol The character NSE symbol of the share.
    #' @return A new `OrderBookSnapshot` object.
    #' @details Errors: signals `TradeableInstrumentError` when the symbol names an index, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function(symbol = "INFY") {
      self$share <- TradeableInstrument$new(
        exchange = "nse",
        segment = "equities",
        symbol = symbol
      )
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one, and a book level as one line of JSON.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      if (is.list(value)) {
        return(jsonlite::toJSON(value, auto_unbox = TRUE, null = "null"))
      }
      format(value)
    },

    #' @description
    #' Prints the bids and the offers side by side, best first.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    print_book = function() {
      bids <- self$share$bids
      offers <- self$share$offers
      cat(sprintf(
        "%10s %10s | %-10s %-10s\n",
        "Bid qty",
        "Bid",
        "Offer",
        "Offer qty"
      ))
      for (level in seq_len(5)) {
        bid_text <- sprintf("%10s %10s", "", "")
        if (level <= length(bids)) {
          bid <- bids[[level]]
          bid_text <- sprintf(
            "%10s %10.2f",
            format(bid[["quantity"]]),
            bid[["price"]]
          )
        }
        offer_text <- ""
        if (level <= length(offers)) {
          offer <- offers[[level]]
          offer_text <- sprintf(
            "%-10.2f %-10s",
            offer[["price"]],
            format(offer[["quantity"]])
          )
        }
        cat(sprintf("%s | %s\n", bid_text, offer_text))
      }
      invisible(NULL)
    },

    #' @description
    #' Prints the spread, the mid price and the day's trading figures.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    print_figures = function() {
      spread <- self$share$bid_offer_spread
      if (is.null(spread)) {
        cat("Spread: one side of the book is empty\n")
      } else {
        ticks <- round(spread / as.numeric(self$share$tick_size))
        cat(sprintf(
          "Spread: %.2f rupees, %d ticks\n",
          spread,
          as.integer(ticks)
        ))
      }
      cat("Best bid:", self$display_text(self$share$best_bid), "\n")
      cat("Best offer:", self$display_text(self$share$best_offer), "\n")
      cat("Mid price:", self$display_text(self$share$mid_price), "\n")
      cat(
        "Average price today:",
        self$display_text(self$share$volume_weighted_average_price),
        "\n"
      )
      cat(
        "Last trade:",
        self$display_text(self$share$last_quantity),
        "at",
        self$display_text(self$share$last_trade_time),
        "\n"
      )
      cat(
        "Volume today:",
        self$display_text(self$share$total_traded_volume),
        "\n"
      )
      invisible(NULL)
    },

    #' @description
    #' Prints the whole snapshot.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      cat(
        self$share$format(),
        "last",
        self$display_text(self$share$last_price),
        "\n"
      )
      self$print_book()
      self$print_figures()
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OrderBookSnapshot$new()$run()
}
