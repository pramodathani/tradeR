#' tradeR: Indian market instruments as R objects
#'
#' @description
#' An Indian market instrument is an R6 object. Name a share, a futures contract or an option once, and from that one object get its candles, its live quote, its order book, its analysis methods, the orders placed in it, the positions held in it and the units of it held in a demat account.
#'
#' Every request goes to the Unified Broker Interface (UBI), a REST service on the same machine that speaks to ten Indian retail brokers. This package is a native R port of the Python library `tradingmachine`.
#'
#' This package places real orders with real money. There is no paper trading mode and no simulator, and `dry_run = TRUE` is the only rehearsal available.
#'
#' @keywords internal
#' @importFrom R6 R6Class
"_PACKAGE"
