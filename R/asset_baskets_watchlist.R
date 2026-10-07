#' A group of instruments followed together, each counting equally
#'
#' @description
#' `Watchlist` weights every member equally, so its day move is the plain average of its members' and its candles are an equal-weighted index of them. It exists to be looked at: `rank_by()` sorts the members by any column of `ohlc`, and the inherited `top_gainers()`, `top_losers()` and `breadth` say what moved.
#'
#' The generator carries `Watchlist$KIND`, the kind stored with the watchlist, `"watchlist"`.
#'
#' @examples
#' \dontrun{
#' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
#' icici_bank <- Equity$new(exchange = "nse", symbol = "ICICIBANK")
#' axis_bank <- Equity$new(exchange = "nse", symbol = "AXISBANK")
#' followed <- Watchlist$new(
#'   name = "banks",
#'   instruments = list(
#'     hdfc_bank,
#'     icici_bank,
#'     axis_bank
#'   )
#' )
#' table <- followed$rank_by("change_percent")
#' movers <- followed$top_gainers(count = 2)
#' }
#' @export
Watchlist <- R6::R6Class(
  "Watchlist",
  inherit = AssetBasket,
  public = list(
    #' @field KIND The character kind stored with the watchlist, `"watchlist"`.
    KIND = "watchlist",

    #' @description
    #' Initialises the watchlist with its instruments.
    #' @param name The character name of the watchlist.
    #' @param instruments A list of at least one `Instrument`, each different.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share the one every instrument uses.
    #' @return A new `Watchlist` object.
    #' @details Errors: signals `BasketMemberError` when `instruments` is empty or names an instrument twice.
    initialize = function(name, instruments, unified_broker_interface = NULL) {
      members <- list()
      for (instrument in instruments) {
        members[[length(members) + 1]] <- BasketMember$new(instrument)
      }
      super$initialize(
        name = name,
        members = members,
        unified_broker_interface = unified_broker_interface
      )
    },

    #' @description
    #' Adds an instrument to the watchlist in memory, which `BasketStore$save()` then stores.
    #' @param instrument The `Instrument` to add.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when the instrument is already in the watchlist.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK"
    #' )
    #' banks <- list()
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   banks[[length(banks) + 1]] <- share
    #' }
    #' followed <- Watchlist$new(name = "banks", instruments = banks)
    #' followed$add(Equity$new(exchange = "nse", symbol = "SBIN"))
    #' print(followed$labels)
    #'
    #' tryCatch(
    #'   followed$add(Equity$new(exchange = "nse", symbol = "HDFCBANK")),
    #'   BasketMemberError = function(error) print(conditionMessage(error))
    #' )
    #' }
    add = function(instrument) {
      self$add_member(BasketMember$new(instrument))
      invisible(NULL)
    },

    #' @description
    #' Sorts the members by a column of their day's prices.
    #' @param column The character name of an `ohlc` column, such as `"change_percent"` or `"last_price"`.
    #' @param ascending A logical that is `TRUE` to put the smallest value first.
    #' @return A `data.frame` of `ohlc` rows in the chosen order, with members that have no value for the column last.
    #' @details Errors: signals a plain error when `column` is not a column of `ohlc`, where Python raises `KeyError`; and a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK"
    #' )
    #' banks <- list()
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   banks[[length(banks) + 1]] <- share
    #' }
    #' followed <- Watchlist$new(name = "banks", instruments = banks)
    #' print(followed$rank_by("change_percent")[, c("label", "change_percent")])
    #'
    #' ranked <- followed$rank_by("last_price", ascending = TRUE)
    #' print(ranked[, c("label", "last_price")])
    #' }
    rank_by = function(column = "change_percent", ascending = FALSE) {
      frame <- self$ohlc
      if (!(column %in% names(frame))) {
        ErrorCatalogue$raise("KeyError", sprintf("Not a column of ohlc: '%s'", column))
      }
      sorted_order <- order(
        frame[[column]],
        decreasing = !ascending,
        na.last = TRUE,
        method = "radix"
      )
      frame <- frame[sorted_order, , drop = FALSE]
      rownames(frame) <- NULL
      frame
    }
  )
)

Watchlist$KIND <- "watchlist"
