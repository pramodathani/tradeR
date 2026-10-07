#' One order waiting in a backtest's order queue
#'
#' @description
#' The R counterpart of `backtesting.Order` from the Python `backtesting` package (version 0.6.5). A strategy creates one with `BacktestStrategy$buy()` or `BacktestStrategy$sell()`, and a trade creates one when it is closed or given a stop-loss or take-profit price. The broker fills or drops it on a later candle.
#'
#' An order with neither `limit` nor `stop` is a market order, filled at the next candle's open, or at the current candle's close when the backtest runs with `trade_on_close = TRUE`. An order with `stop` waits until the price reaches the stop and then becomes a market or limit order. An order with `limit` fills only at the limit price or better.
#'
#' A stop-loss or take-profit order that belongs to a trade is called contingent; it closes that trade when filled and is cancelled when the trade closes another way.
#'
#' @examples
#' \dontrun{
#' LimitBuyer <- R6::R6Class(
#'   "LimitBuyer",
#'   inherit = BacktestStrategy,
#'   public = list(
#'     initialize_strategy = function() {
#'       invisible(NULL)
#'     },
#'     next_candle = function() {
#'       if (length(self$orders) == 0 && self$position$size == 0) {
#'         latest_close <- tail(self$data$Close, 1)
#'         order <- self$buy(limit = latest_close * 0.98)
#'         cat(sprintf("Waiting to buy at %.2f\n", order$limit))
#'       }
#'     }
#'   )
#' )
#' }
#' @export
BacktestOrder <- R6::R6Class(
  "BacktestOrder",
  public = list(
    #' @field size The numeric size: a positive number buys and a negative number sells. A size between -1 and 1 is a fraction of the available margin, and any other size is a whole number of units.
    size = NULL,

    #' @field limit The numeric limit price, or `NULL` for a market or stop-market order.
    limit = NULL,

    #' @field stop The numeric stop price, or `NULL` when the order has no stop or its stop has already been reached.
    stop = NULL,

    #' @field sl The numeric stop-loss price to give the trade this order opens, or `NULL`.
    sl = NULL,

    #' @field tp The numeric take-profit price to give the trade this order opens, or `NULL`.
    tp = NULL,

    #' @field parent_trade The `BacktestTrade` this order closes, or `NULL` for an order that opens a trade.
    parent_trade = NULL,

    #' @field tag Any value the strategy attached to the order to recognise it later, or `NULL`.
    tag = NULL,

    #' @description
    #' Creates an order without placing it in the queue; `BacktestBroker$new_order()` does both.
    #' @param broker The `BacktestBroker` that holds the order queue.
    #' @param size The numeric size, positive to buy and negative to sell, never zero.
    #' @param limit The numeric limit price, or `NULL`.
    #' @param stop The numeric stop price, or `NULL`.
    #' @param sl The numeric stop-loss price for the trade the order opens, or `NULL`.
    #' @param tp The numeric take-profit price for the trade the order opens, or `NULL`.
    #' @param parent_trade The `BacktestTrade` the order closes, or `NULL`.
    #' @param tag Any value to recognise the order by, or `NULL`.
    #' @return A new `BacktestOrder` object.
    #' @details Errors: signals `ValueError` when `size` is zero.
    initialize = function(
      broker,
      size,
      limit = NULL,
      stop = NULL,
      sl = NULL,
      tp = NULL,
      parent_trade = NULL,
      tag = NULL
    ) {
      if (size == 0) {
        ErrorCatalogue$raise("ValueError", "An order size cannot be zero")
      }
      private$broker <- broker
      self$size <- size
      self$limit <- limit
      self$stop <- stop
      self$sl <- sl
      self$tp <- tp
      self$parent_trade <- parent_trade
      self$tag <- tag
    },

    #' @description
    #' Removes the order from the queue, and from its trade when it is the trade's stop-loss or take-profit order.
    #' @return `NULL`, invisibly.
    cancel = function() {
      private$broker$remove_order(self)
      trade <- self$parent_trade
      if (!is.null(trade)) {
        if (identical(self, trade$sl_order)) {
          trade$sl_order <- NULL
        } else if (identical(self, trade$tp_order)) {
          trade$tp_order <- NULL
        }
      }
      invisible(NULL)
    },

    #' @description
    #' Describes the order in one line, as Python's `repr` does.
    #' @param ... Ignored; present for compatibility with `format()`.
    #' @return A character value such as `"<Order size=-10, stop=95, contingent=TRUE>"`.
    format = function(...) {
      parts <- sprintf("size=%s", format(self$size))
      if (!is.null(self$limit)) {
        parts <- c(
          parts,
          sprintf("limit=%s", format(round(self$limit, 5)))
        )
      }
      if (!is.null(self$stop)) {
        parts <- c(
          parts,
          sprintf("stop=%s", format(round(self$stop, 5)))
        )
      }
      if (!is.null(self$sl)) {
        parts <- c(
          parts,
          sprintf("sl=%s", format(round(self$sl, 5)))
        )
      }
      if (!is.null(self$tp)) {
        parts <- c(
          parts,
          sprintf("tp=%s", format(round(self$tp, 5)))
        )
      }
      parts <- c(
        parts,
        sprintf("contingent=%s", self$is_contingent)
      )
      if (!is.null(self$tag)) {
        parts <- c(
          parts,
          sprintf("tag=%s", format(self$tag))
        )
      }
      sprintf("<Order %s>", paste(parts, collapse = ", "))
    },

    #' @description
    #' Prints the one-line description of the order.
    #' @param ... Ignored; present for compatibility with `print()`.
    #' @return The order, invisibly.
    print = function(...) {
      cat(self$format(), "\n", sep = "")
      invisible(self)
    }
  ),
  active = list(
    #' @field is_long A logical that is `TRUE` when the order buys.
    is_long = function(value) {
      if (!missing(value)) {
        stop("is_long is read-only", call. = FALSE)
      }
      self$size > 0
    },

    #' @field is_short A logical that is `TRUE` when the order sells.
    is_short = function(value) {
      if (!missing(value)) {
        stop("is_short is read-only", call. = FALSE)
      }
      self$size < 0
    },

    #' @field is_contingent A logical that is `TRUE` when the order is the stop-loss or take-profit order of an open trade.
    is_contingent = function(value) {
      if (!missing(value)) {
        stop("is_contingent is read-only", call. = FALSE)
      }
      trade <- self$parent_trade
      if (is.null(trade)) {
        return(FALSE)
      }
      identical(self, trade$sl_order) || identical(self, trade$tp_order)
    }
  ),
  private = list(
    broker = NULL
  )
)
