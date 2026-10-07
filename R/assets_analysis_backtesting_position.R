#' The sum of a backtest's open trades
#'
#' @description
#' The R counterpart of `backtesting.Position` from the Python `backtesting` package (version 0.6.5). A strategy reads it through `BacktestStrategy$position` to learn how many units it holds and how much they have made, and calls `close()` to close every open trade.
#'
#' Python's `if not self.position:` becomes `if (self$position$size == 0)`, because an R object cannot stand for a logical value.
#'
#' @examples
#' \dontrun{
#' TakeProfitAtFivePercent <- R6::R6Class(
#'   "TakeProfitAtFivePercent",
#'   inherit = BacktestStrategy,
#'   public = list(
#'     initialize_strategy = function() {
#'       invisible(NULL)
#'     },
#'     next_candle = function() {
#'       if (self$position$size == 0) {
#'         self$buy()
#'       } else if (self$position$pl_pct > 5) {
#'         self$position$close()
#'       }
#'     }
#'   )
#' )
#' }
#' @export
BacktestPosition <- R6::R6Class(
  "BacktestPosition",
  public = list(
    #' @description
    #' Creates the position of a broker; `BacktestBroker` does this once.
    #' @param broker The `BacktestBroker` whose open trades make up the position.
    #' @return A new `BacktestPosition` object.
    initialize = function(broker) {
      private$broker <- broker
    },

    #' @description
    #' Places orders that close all or part of every open trade on the next fill.
    #' @param portion The numeric fraction of each trade to close, above 0 and at most 1.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when `portion` is not above 0 and at most 1.
    close = function(portion = 1.0) {
      for (trade in private$broker$trades) {
        trade$close(portion)
      }
      invisible(NULL)
    },

    #' @description
    #' Describes the position in one line, as Python's `repr` does.
    #' @param ... Ignored; present for compatibility with `format()`.
    #' @return A character value such as `"<Position: 10 (1 trades)>"`.
    format = function(...) {
      sprintf(
        "<Position: %s (%d trades)>",
        format(self$size),
        length(private$broker$trades)
      )
    },

    #' @description
    #' Prints the one-line description of the position.
    #' @param ... Ignored; present for compatibility with `print()`.
    #' @return The position, invisibly.
    print = function(...) {
      cat(self$format(), "\n", sep = "")
      invisible(self)
    }
  ),
  active = list(
    #' @field size The numeric number of units held: positive when long, negative when short and zero when flat.
    size = function(value) {
      if (!missing(value)) {
        stop("size is read-only", call. = FALSE)
      }
      total <- 0
      for (trade in private$broker$trades) {
        total <- total + trade$size
      }
      total
    },

    #' @field pl The numeric profit or loss of the open trades in cash.
    pl = function(value) {
      if (!missing(value)) {
        stop("pl is read-only", call. = FALSE)
      }
      total <- 0
      for (trade in private$broker$trades) {
        total <- total + trade$pl
      }
      total
    },

    #' @field pl_pct The numeric profit or loss of the open trades in percent of what they cost, such as 5 for five percent, or 0 when flat.
    pl_pct = function(value) {
      if (!missing(value)) {
        stop("pl_pct is read-only", call. = FALSE)
      }
      total_invested <- 0
      for (trade in private$broker$trades) {
        total_invested <- total_invested + trade$entry_price * abs(trade$size)
      }
      if (total_invested == 0) {
        return(0)
      }
      self$pl / total_invested * 100
    },

    #' @field is_long A logical that is `TRUE` when the position is long.
    is_long = function(value) {
      if (!missing(value)) {
        stop("is_long is read-only", call. = FALSE)
      }
      self$size > 0
    },

    #' @field is_short A logical that is `TRUE` when the position is short.
    is_short = function(value) {
      if (!missing(value)) {
        stop("is_short is read-only", call. = FALSE)
      }
      self$size < 0
    }
  ),
  private = list(
    broker = NULL
  )
)
