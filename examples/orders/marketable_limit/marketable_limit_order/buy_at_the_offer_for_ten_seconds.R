#' Buy one share with a marketable limit that takes no buffer and gives up after ten seconds, then sell it back.
#'
#' The program previews, then places, a marketable limit to buy one Vodafone Idea share intraday at the best offer itself, with no ticks of buffer, which UBI moves after the offer until it fills and cancels after ten seconds if it has not. It prints the parent as it ends and the price the buy filled at, and sells the share back.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/marketable_limit/marketable_limit_order/buy_at_the_offer_for_ten_seconds.R

library(tradeR)

#' A one-share intraday buy sent as a limit at the best offer that follows the offer for ten seconds.
#'
#' @field trading_account The `Account`, used to read the engine's answer when it comes late.
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field quantity_before The integer intraday quantity of Vodafone Idea held before the program bought its share.
#' @field order The `MarketableLimitOrder` the program places, or `NULL` before `run()` builds it.
BuyAtTheOffer <- R6::R6Class(
  "BuyAtTheOffer",
  public = list(
    trading_account = NULL,
    share = NULL,
    quantity_before = NULL,
    order = NULL,

    #' @description
    #' Looks up the share the program trades.
    #' @return A new `BuyAtTheOffer` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$trading_account <- Account$new()
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$quantity_before <- 0L
      self$order <- NULL
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
    #' Gives a price a percentage away from an instrument's last price, rounded to its tick size.
    #' @param instrument The `TradeableInstrument` to price.
    #' @param percent The numeric percentage to move from the last price, negative for a price below the market.
    #' @return The numeric price in rupees.
    #' @details Errors: signals `ValueError` when UBI has no last price for the instrument.
    price_from_market = function(instrument, percent) {
      last_price <- instrument$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", instrument$format())
        )
      }
      tick_size <- 0.05
      if (!is.null(instrument$tick_size)) {
        tick_size <- as.numeric(instrument$tick_size)
      }
      ticks <- round(last_price * (1 + percent / 100) / tick_size)
      round(ticks * tick_size, 2)
    },

    #' @description
    #' Builds a one-share market buy sent as a limit at the best offer for ten seconds.
    #' @param dry_run A logical that is `TRUE` to build the order as a dry run, which UBI only checks and plans.
    #' @return The `MarketableLimitOrder`, not yet placed.
    build_order = function(dry_run) {
      MarketableLimitOrder$new(
        self$share,
        transaction_type = "buy",
        product = "mis",
        order_type = "market",
        quantity = 1,
        buffer_ticks = 0,
        fill_within_seconds = 10,
        dry_run = dry_run
      )
    },

    #' @description
    #' Places the order, reading the engine's stored answer when the engine answers too late.
    #'
    #' A refusal with HTTP 409 means the order could not be priced, because nobody was offering the share or no fresh quote had arrived, and nothing was sent.
    #' @return The named list answer of the placement, whose `parent_id` is also kept on the order, or `NULL` when UBI refused to price it.
    #' @details Errors: signals `OrderOutcomeUnknownError` when the engine's answer could not be read within thirty seconds, and `UnifiedBrokerInterfaceError` when UBI refused the order or could not be reached.
    place_order = function() {
      tryCatch(
        self$order$place(),
        ConflictError = function(error) {
          cat(sprintf(
            "UBI could not price the buy, so nothing was sent: %s\n",
            conditionMessage(error)
          ))
          NULL
        },
        OrderOutcomeUnknownError = function(error) {
          self$read_late_answer(error)
        }
      )
    },

    #' @description
    #' Reads the order engine's stored answer to a placement it answered too late, and keeps its parent id.
    #' @param error The `OrderOutcomeUnknownError` the placement raised.
    #' @return The named list answer the placement would have given.
    #' @details Errors: signals `OrderOutcomeUnknownError` when the engine's answer could not be read within thirty seconds.
    read_late_answer = function(error) {
      intent_id <- error$detail[["intent_id"]]
      cat(sprintf(
        "The engine answered late, so intent %s is read.\n",
        self$text_of(intent_id)
      ))
      for (attempt in 0:14) {
        Sys.sleep(2)
        stored <- tryCatch(
          self$trading_account$intent(intent_id),
          NotFoundError = function(not_found_error) {
            NULL
          }
        )
        if (is.null(stored)) {
          next
        }
        answer <- stored[["response"]]
        self$order$parent_id <- answer[["parent_id"]]
        return(answer)
      }
      stop(error)
    },

    #' @description
    #' Waits up to twenty seconds for the parent to end, then prints its state and each leg.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI could not read the parent.
    wait_for_parent = function() {
      finished_states <- c(
        "completed",
        "cancelled",
        "rejected",
        "failed"
      )
      parent <- self$order$parent
      for (attempt in 0:19) {
        if (parent[["state"]] %in% finished_states) {
          break
        }
        Sys.sleep(1)
        parent <- self$order$parent
      }
      cat(sprintf("Parent state: %s\n", self$text_of(parent[["state"]])))
      for (leg in parent[["legs"]]) {
        cat(sprintf(
          "  leg %s: %s %s at %s, %s, filled %s at %s\n",
          self$text_of(leg[["role"]]),
          self$text_of(leg[["transaction_type"]]),
          self$text_of(leg[["quantity"]]),
          self$text_of(leg[["price"]]),
          self$text_of(leg[["state"]]),
          self$text_of(leg[["filled_quantity"]]),
          self$text_of(leg[["average_price"]])
        ))
      }
      invisible(NULL)
    },

    #' @description
    #' Gives the net intraday quantity of Vodafone Idea held now.
    #' @return The integer quantity, positive when long, negative when short and 0 when nothing is held.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI could not read the positions.
    held_quantity = function() {
      positions <- self$share$net_positions
      if (is.null(positions)) {
        return(0L)
      }
      total <- 0L
      for (index in seq_len(nrow(positions))) {
        if (identical(positions[["product"]][[index]], "intraday")) {
          total <- total + as.integer(positions[["quantity"]][[index]])
        }
      }
      total
    },

    #' @description
    #' Sells back the share this program bought, if the position shows that it was bought, trying up to five times.
    #'
    #' The sell is sent with `reduce_position`, whose quantity reference UBI sizes and routes against the broker that actually holds the position, so the account is left as it was found rather than long at one broker and short at another. It is a limit half a percent below the last price, because brokers refuse market orders sent through an API.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI could not be reached.
    close_position = function() {
      for (attempt in 0:4) {
        if (self$held_quantity() <= self$quantity_before) {
          cat(sprintf(
            "Back to %d intraday, as before.\n",
            self$held_quantity()
          ))
          return(invisible(NULL))
        }
        answer <- tryCatch(
          self$share$reduce_position(
            quantity = 1,
            product = "mis",
            price = self$price_from_market(self$share, -0.5)
          ),
          OrderRejectedError = function(error) {
            cat(sprintf(
              "A broker refused the sell, so it is sent again: %s\n",
              conditionMessage(error)
            ))
            Sys.sleep(2)
            "refused"
          },
          OrderOutcomeUnknownError = function(error) {
            cat("The engine answered the sell late, so the position is read again.\n")
            Sys.sleep(10)
            "late"
          }
        )
        if (identical(answer, "refused") || identical(answer, "late")) {
          next
        }
        cat(sprintf(
          "Reducing the position with sell %s\n",
          self$text_of(answer[["order_id"]])
        ))
        Sys.sleep(4)
      }
      cat("The position could still be open, so check it by hand.\n")
      invisible(NULL)
    },

    #' @description
    #' Previews the buy, places it, waits for it to end, and sells back whatever it bought.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share, and `UnifiedBrokerInterfaceError` when UBI refused a request or could not be reached.
    run = function() {
      preview <- self$build_order(dry_run = TRUE)$place()
      pricing <- preview[["plan"]][["order"]][["slots"]][["pricing"]]
      lifetime <- preview[["plan"]][["order"]][["slots"]][["lifetime"]]
      cat(sprintf(
        "A dry run says UBI would price the buy with %s\n",
        self$text_of(pricing)
      ))
      cat(sprintf("and end it with %s\n", self$text_of(lifetime)))
      self$quantity_before <- self$held_quantity()
      self$order <- self$build_order(dry_run = FALSE)
      tryCatch(
        {
          answer <- self$place_order()
          if (!is.null(answer)) {
            cat(sprintf(
              "Placed a %s order: outcome %s, parent %s\n",
              self$order$SYNTHETIC_TYPE,
              self$text_of(answer[["outcome"]]),
              self$text_of(self$order$parent_id)
            ))
            self$wait_for_parent()
          }
        },
        finally = self$close_position()
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BuyAtTheOffer$new()$run()
}
