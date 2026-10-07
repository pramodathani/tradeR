#' One trade opened by a filled order in a backtest
#'
#' @description
#' The R counterpart of `backtesting.Trade` from the Python `backtesting` package (version 0.6.5). A trade records the size, entry price and entry candle of a filled order, and gains an exit price and exit candle when it is closed. A strategy reads its open trades through `BacktestStrategy$trades` and its finished ones through `BacktestStrategy$closed_trades`.
#'
#' Assigning a price to `sl` or `tp` places a contingent stop-loss or take-profit order that closes the trade, and assigning `NULL` cancels it.
#'
#' Candle numbers count from 1, as R rows do, where Python counts from 0.
#'
#' @examples
#' \dontrun{
#' TrailingStop <- R6::R6Class(
#'   "TrailingStop",
#'   inherit = BacktestStrategy,
#'   public = list(
#'     initialize_strategy = function() {
#'       invisible(NULL)
#'     },
#'     next_candle = function() {
#'       latest_close <- tail(self$data$Close, 1)
#'       if (self$position$size == 0) {
#'         self$buy()
#'       }
#'       for (trade in self$trades) {
#'         trade$sl <- latest_close * 0.95
#'       }
#'     }
#'   )
#' )
#' }
#' @export
BacktestTrade <- R6::R6Class(
  "BacktestTrade",
  public = list(
    #' @field size The numeric number of units: positive for a long trade and negative for a short one.
    size = NULL,

    #' @field entry_price The numeric price the trade was opened at.
    entry_price = NULL,

    #' @field exit_price The numeric price the trade was closed at, or `NULL` while it is open.
    exit_price = NULL,

    #' @field entry_bar The integer candle number the trade was opened on, counting from 1.
    entry_bar = NULL,

    #' @field exit_bar The integer candle number the trade was closed on, counting from 1, or `NULL` while it is open.
    exit_bar = NULL,

    #' @field sl_order The contingent stop-loss `BacktestOrder`, or `NULL`.
    sl_order = NULL,

    #' @field tp_order The contingent take-profit `BacktestOrder`, or `NULL`.
    tp_order = NULL,

    #' @field tag Any value copied from the order that opened the trade, or `NULL`.
    tag = NULL,

    #' @field commissions The numeric commission paid on opening and closing the trade, filled in when it closes and zero until then.
    commissions = 0,

    #' @description
    #' Creates a trade; `BacktestBroker` does this when an order fills.
    #' @param broker The `BacktestBroker` the trade belongs to.
    #' @param size The numeric number of units, positive for long and negative for short.
    #' @param entry_price The numeric price the trade opened at.
    #' @param entry_bar The integer candle number the trade opened on.
    #' @param tag Any value to recognise the trade by, or `NULL`.
    #' @return A new `BacktestTrade` object.
    initialize = function(broker, size, entry_price, entry_bar, tag) {
      private$broker <- broker
      self$size <- size
      self$entry_price <- entry_price
      self$entry_bar <- entry_bar
      self$tag <- tag
      self$commissions <- 0
    },

    #' @description
    #' Places a market order that closes all or part of the trade on the next fill.
    #' @param portion The numeric fraction of the trade to close, above 0 and at most 1.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when `portion` is not above 0 and at most 1.
    close = function(portion = 1.0) {
      if (!(portion > 0 && portion <= 1)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "portion must be a fraction between 0 and 1: portion=%s",
            format(portion)
          )
        )
      }
      units <- max(1, round(abs(self$size) * portion))
      order <- BacktestOrder$new(
        private$broker,
        -sign(self$size) * units,
        parent_trade = self,
        tag = self$tag
      )
      private$broker$insert_order_first(order)
      invisible(NULL)
    },

    #' @description
    #' Describes the trade in one line, as Python's `repr` does.
    #' @param ... Ignored; present for compatibility with `format()`.
    #' @return A character value such as `"<Trade size=10 time=31-45 price=980-1012 pl=320>"`.
    format = function(...) {
      exit_bar <- ""
      if (!is.null(self$exit_bar)) {
        exit_bar <- format(self$exit_bar)
      }
      exit_price <- ""
      if (!is.null(self$exit_price)) {
        exit_price <- format(self$exit_price)
      }
      text <- sprintf(
        "<Trade size=%s time=%s-%s price=%s-%s pl=%.0f",
        format(self$size),
        format(self$entry_bar),
        exit_bar,
        format(self$entry_price),
        exit_price,
        self$pl
      )
      if (!is.null(self$tag)) {
        text <- sprintf("%s tag=%s", text, format(self$tag))
      }
      sprintf("%s>", text)
    },

    #' @description
    #' Prints the one-line description of the trade.
    #' @param ... Ignored; present for compatibility with `print()`.
    #' @return The trade, invisibly.
    print = function(...) {
      cat(self$format(), "\n", sep = "")
      invisible(self)
    }
  ),
  active = list(
    #' @field entry_time The `POSIXct` time of the candle the trade opened on.
    entry_time = function(value) {
      if (!missing(value)) {
        stop("entry_time is read-only", call. = FALSE)
      }
      private$broker$candles$datetime[[self$entry_bar]]
    },

    #' @field exit_time The `POSIXct` time of the candle the trade closed on, or `NULL` while it is open.
    exit_time = function(value) {
      if (!missing(value)) {
        stop("exit_time is read-only", call. = FALSE)
      }
      if (is.null(self$exit_bar)) {
        return(NULL)
      }
      private$broker$candles$datetime[[self$exit_bar]]
    },

    #' @field is_long A logical that is `TRUE` for a long trade.
    is_long = function(value) {
      if (!missing(value)) {
        stop("is_long is read-only", call. = FALSE)
      }
      self$size > 0
    },

    #' @field is_short A logical that is `TRUE` for a short trade.
    is_short = function(value) {
      if (!missing(value)) {
        stop("is_short is read-only", call. = FALSE)
      }
      !self$is_long
    },

    #' @field pl The numeric profit, positive, or loss, negative, in cash, at the exit price or else the latest close. Commissions count only once the trade has closed.
    pl = function(value) {
      if (!missing(value)) {
        stop("pl is read-only", call. = FALSE)
      }
      price <- private$current_price()
      self$size * (price - self$entry_price) - self$commissions
    },

    #' @field pl_pct The numeric profit or loss as a fraction of the entry value, such as 0.05 for five percent, after any commissions recorded.
    pl_pct = function(value) {
      if (!missing(value)) {
        stop("pl_pct is read-only", call. = FALSE)
      }
      price <- private$current_price()
      gross_fraction <- sign(self$size) * (price / self$entry_price - 1)
      commission_fraction <- self$commissions /
        (abs(self$size) * self$entry_price)
      gross_fraction - commission_fraction
    },

    #' @field value The numeric value of the trade in cash, its number of units times the exit price or else the latest close.
    value = function(value) {
      if (!missing(value)) {
        stop("value is read-only", call. = FALSE)
      }
      abs(self$size) * private$current_price()
    },

    #' @field sl The numeric stop-loss price, or `NULL` when there is none. Assigning a price places or replaces the stop-loss order, and assigning `NULL` cancels it.
    sl = function(value) {
      if (missing(value)) {
        if (is.null(self$sl_order)) {
          return(NULL)
        }
        return(self$sl_order$stop)
      }
      private$set_contingent("sl", value)
    },

    #' @field tp The numeric take-profit price, or `NULL` when there is none. Assigning a price places or replaces the take-profit order, and assigning `NULL` cancels it.
    tp = function(value) {
      if (missing(value)) {
        if (is.null(self$tp_order)) {
          return(NULL)
        }
        return(self$tp_order$limit)
      }
      private$set_contingent("tp", value)
    }
  ),
  private = list(
    broker = NULL,

    #' Gives the price the trade is valued at.
    #' @return The numeric exit price, or the latest close while the trade is open.
    current_price = function() {
      if (!is.null(self$exit_price)) {
        return(self$exit_price)
      }
      private$broker$last_price
    },

    #' Places, replaces or cancels the stop-loss or take-profit order.
    #' @param kind The character `"sl"` or `"tp"`.
    #' @param price The numeric price, or `NULL` to cancel.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when `price` is not above zero and finite.
    set_contingent = function(kind, price) {
      if (!is.null(price) && !(price > 0 && is.finite(price))) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("Make sure 0 < price < inf! price: %s", format(price))
        )
      }
      if (kind == "sl") {
        existing <- self$sl_order
      } else {
        existing <- self$tp_order
      }
      if (!is.null(existing)) {
        existing$cancel()
      }
      if (is.null(price)) {
        return(invisible(NULL))
      }
      if (kind == "sl") {
        self$sl_order <- private$broker$new_order(
          -self$size,
          stop = price,
          tag = self$tag,
          trade = self
        )
      } else {
        self$tp_order <- private$broker$new_order(
          -self$size,
          limit = price,
          tag = self$tag,
          trade = self
        )
      }
      invisible(NULL)
    }
  )
)
