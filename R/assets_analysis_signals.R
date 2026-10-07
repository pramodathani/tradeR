#' Crossover and crossunder detection between two columns of a frame
#'
#' @description
#' The methods work on a frame the caller already has, such as the result of `simple_moving_average()`, so they do not fetch candles. The class is a link in the chain of analysis classes that `Instrument` inherits.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' frame <- infosys$simple_moving_average(window = 20, days = 365)
#' crossings <- infosys$is_cross_over(frame, "close", "sma_20")
#' }
#' @export
Signals <- R6::R6Class(
  "Signals",
  inherit = CandlestickPatterns,
  public = list(
    #' @description
    #' Marks the rows where the first column rises above the second.
    #'
    #' A row is marked when, on the previous row, the first column was at or below the second, and on this row it is above the second. The first row is never marked, and a row where either comparison meets a missing value is not marked.
    #' @param data The `data.frame` holding both columns, which is not changed.
    #' @param first_column The character name of the column that crosses.
    #' @param second_column The character name of the column that is crossed.
    #' @return A `data.frame` copy of `data` with fresh row names and an added logical `cross_over` column.
    #' @details Errors: signals `KeyError` when `data` has no column named `first_column` or `second_column`.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' fast_frame <- infosys$simple_moving_average(window = 50, days = 1095)
    #' slow_frame <- infosys$simple_moving_average(window = 200, days = 1095)
    #' fast_frame$sma_200 <- slow_frame$sma_200
    #' crossings <- infosys$is_cross_over(fast_frame, "sma_50", "sma_200")
    #' golden_crosses <- crossings[crossings$cross_over, ]
    #' if (nrow(golden_crosses) == 0) {
    #'   print("No golden cross in the last three years.")
    #' }
    #' for (position in seq_len(nrow(golden_crosses))) {
    #'   print(format(golden_crosses$datetime[[position]], "%Y-%m-%d"))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' average_frame <- nifty$simple_moving_average(window = 20, days = 365)
    #' crossings <- nifty$is_cross_over(average_frame, "close", "sma_20")
    #' crossing_count <- sum(crossings$cross_over)
    #' print(sprintf("Crossings above the 20-day average: %d", crossing_count))
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' macd_frame <- reliance$moving_average_convergence_divergence(
    #'   days = 365
    #' )
    #' crossings <- reliance$is_cross_over(
    #'   macd_frame,
    #'   "macd_12_26_9",
    #'   "macd_12_26_9_signal"
    #' )
    #' bullish_crossings <- crossings[crossings$cross_over, ]
    #' if (nrow(bullish_crossings) == 0) {
    #'   print("The MACD line did not cross above its signal line.")
    #' } else {
    #'   latest <- bullish_crossings$datetime[[nrow(bullish_crossings)]]
    #'   latest_date <- format(latest, "%Y-%m-%d")
    #'   print(sprintf("Latest bullish MACD crossing: %s", latest_date))
    #' }
    #' }
    is_cross_over = function(data, first_column, second_column) {
      private$check_columns(data, first_column, second_column)
      rownames(data) <- NULL
      first_values <- data[[first_column]]
      second_values <- data[[second_column]]
      previous_first <- private$previous_values(first_values)
      previous_second <- private$previous_values(second_values)
      was_at_or_below <- previous_first <= previous_second
      is_above <- first_values > second_values
      crossed <- was_at_or_below & is_above
      data[["cross_over"]] <- !is.na(crossed) & crossed
      data
    },

    #' @description
    #' Marks the rows where the first column falls below the second.
    #'
    #' A row is marked when, on the previous row, the first column was at or above the second, and on this row it is below the second. The first row is never marked, and a row where either comparison meets a missing value is not marked.
    #' @param data The `data.frame` holding both columns, which is not changed.
    #' @param first_column The character name of the column that crosses.
    #' @param second_column The character name of the column that is crossed.
    #' @return A `data.frame` copy of `data` with fresh row names and an added logical `cross_under` column.
    #' @details Errors: signals `KeyError` when `data` has no column named `first_column` or `second_column`.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' average_frame <- infosys$exponential_moving_average(
    #'   window = 20,
    #'   days = 180
    #' )
    #' crossings <- infosys$is_cross_under(average_frame, "close", "ema_20")
    #' falls <- crossings[crossings$cross_under, ]
    #' if (nrow(falls) == 0) {
    #'   print("Infosys did not close below its 20-day average.")
    #' }
    #' for (position in seq_len(nrow(falls))) {
    #'   print(format(falls$datetime[[position]], "%Y-%m-%d"))
    #' }
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' strength_frame <- tcs$relative_strength_index(window = 14, days = 730)
    #' strength_frame$overbought_level <- 70
    #' crossings <- tcs$is_cross_under(
    #'   strength_frame,
    #'   "rsi_14",
    #'   "overbought_level"
    #' )
    #' exits <- crossings[crossings$cross_under, ]
    #' print(sprintf("RSI fell below 70 on %d days in two years.", nrow(exits)))
    #' columns <- c(
    #'   "datetime",
    #'   "close",
    #'   "rsi_14"
    #' )
    #' print(tail(exits[, columns], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' fast_frame <- nifty$simple_moving_average(window = 50, days = 1825)
    #' slow_frame <- nifty$simple_moving_average(window = 200, days = 1825)
    #' fast_frame$sma_200 <- slow_frame$sma_200
    #' crossings <- nifty$is_cross_under(fast_frame, "sma_50", "sma_200")
    #' death_cross_count <- sum(crossings$cross_under)
    #' print(sprintf("Death crosses in five years: %d", death_cross_count))
    #' }
    is_cross_under = function(data, first_column, second_column) {
      private$check_columns(data, first_column, second_column)
      rownames(data) <- NULL
      first_values <- data[[first_column]]
      second_values <- data[[second_column]]
      previous_first <- private$previous_values(first_values)
      previous_second <- private$previous_values(second_values)
      was_at_or_above <- previous_first >= previous_second
      is_below <- first_values < second_values
      crossed <- was_at_or_above & is_below
      data[["cross_under"]] <- !is.na(crossed) & crossed
      data
    }
  ),
  private = list(
    # @description
    # Checks that a frame has both columns a crossing test compares.
    # @param data The `data.frame` to check.
    # @param first_column The character name of the first column.
    # @param second_column The character name of the second column.
    # @return `NULL`, invisibly, when both columns are present.
    # @details Errors: signals `KeyError` naming the first column that `data` lacks, as Python does.
    check_columns = function(data, first_column, second_column) {
      columns <- c(
        first_column,
        second_column
      )
      for (column in columns) {
        if (!(column %in% names(data))) {
          ErrorCatalogue$raise(
            "KeyError",
            sprintf("data has no column named '%s'", column)
          )
        }
      }
      invisible(NULL)
    },

    # @description
    # Shifts a vector down by one place, as pandas `shift()` does.
    # @param values A vector, such as a numeric column.
    # @return A vector of the same length whose first element is `NA` and whose other elements are the elements of `values` before them.
    previous_values = function(values) {
      count <- length(values)
      previous <- rep(NA, count)
      if (count > 1) {
        previous[2:count] <- values[1:(count - 1)]
      }
      previous
    }
  )
)
