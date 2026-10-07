#' A standalone HTML page showing one backtest
#'
#' @description
#' Stands in for `Backtest.plot()` of the Python `backtesting` package, which draws an interactive Bokeh chart. Bokeh has no R counterpart without new dependencies, so this class writes a plain HTML file instead, with no scripts and nothing fetched from the internet: a line chart of the closes with a green mark at each trade's entry and a red mark at its exit, a line chart of the equity, the statistics as a table, and the list of trades.
#'
#' @examples
#' \dontrun{
#' statistics <- backtest$run()
#' BacktestPlot$new(backtest$candles, statistics)$write(file.path(tempdir(), "backtest.html"))
#' }
#' @export
BacktestPlot <- R6::R6Class(
  "BacktestPlot",
  public = list(
    #' @field candles The `data.frame` of candles with `datetime` and `Close` columns.
    candles = NULL,

    #' @field results The named list of statistics from `Backtest$run()`.
    results = NULL,

    #' @description
    #' Collects what the page shows.
    #' @param candles The `data.frame` of candles with `datetime` and `Close` columns.
    #' @param results The named list of statistics from `Backtest$run()`.
    #' @return A new `BacktestPlot` object.
    initialize = function(candles, results) {
      self$candles <- candles
      self$results <- results
    },

    #' @description
    #' Builds the page and writes it to a file, without opening it.
    #' @param filename The character path of the HTML file to write.
    #' @return The character `filename`, invisibly.
    write = function(filename) {
      writeLines(self$html(), filename, useBytes = TRUE)
      invisible(filename)
    },

    #' @description
    #' Builds the page.
    #' @return A character value holding the whole HTML document.
    html = function() {
      strategy_name <- "Backtest"
      if (!is.null(self$results[["_strategy"]])) {
        strategy_name <- self$results[["_strategy"]]$format()
      }
      trades <- self$results[["_trades"]]
      closes <- self$candles$Close
      equity <- self$results[["_equity_curve"]]$Equity
      price_chart <- private$line_chart(
        closes,
        "Close",
        trades$EntryBar,
        trades$ExitBar
      )
      equity_chart <- private$line_chart(
        equity,
        "Equity",
        integer(0),
        integer(0)
      )
      parts <- c(
        "<!doctype html>",
        "<html lang=\"en\"><head><meta charset=\"utf-8\">",
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
        sprintf("<title>%s backtest</title>", private$escape(strategy_name)),
        "<style>",
        ":root { --background: #ffffff; --text: #202124; --muted: #6b7280; --line: #5f6368; --accent: #ff5722; --entry: #2e7d32; --exit: #c62828; --rule: #e0e0e0; }",
        "@media (prefers-color-scheme: dark) { :root { --background: #1e2129; --text: #e8eaed; --muted: #9aa0a6; --line: #9aa0a6; --accent: #ff8a65; --entry: #81c784; --exit: #e57373; --rule: #3c4048; } }",
        "body { background: var(--background); color: var(--text); font-family: Roboto, sans-serif; margin: 0 auto; max-width: 960px; padding: 16px; }",
        "svg { width: 100%; height: auto; display: block; }",
        "table { border-collapse: collapse; font-size: 13px; margin-bottom: 24px; }",
        "td, th { border-bottom: 1px solid var(--rule); padding: 4px 12px 4px 0; text-align: left; }",
        ".scroll { overflow-x: auto; }",
        "h2 { font-size: 15px; color: var(--muted); }",
        "</style></head><body>",
        sprintf("<h1>%s</h1>", private$escape(strategy_name)),
        "<h2>Close, with entries in green and exits in red</h2>",
        price_chart,
        "<h2>Equity</h2>",
        equity_chart,
        "<h2>Statistics</h2>",
        private$statistics_table(),
        "<h2>Trades</h2>",
        "<div class=\"scroll\">",
        private$trades_table(trades),
        "</div>",
        "</body></html>"
      )
      paste(parts, collapse = "\n")
    }
  ),
  private = list(
    # Escapes the characters HTML gives a meaning to.
    # @param text A character vector.
    # @return The character vector with `&`, `<` and `>` escaped.
    escape = function(text) {
      text <- gsub("&", "&amp;", text, fixed = TRUE)
      text <- gsub("<", "&lt;", text, fixed = TRUE)
      gsub(">", "&gt;", text, fixed = TRUE)
    },

    # Draws a line chart as inline SVG, with optional entry and exit marks.
    # @param values A numeric vector, one value per candle.
    # @param label A character label for the chart.
    # @param entry_bars An integer vector of candle numbers to mark as entries.
    # @param exit_bars An integer vector of candle numbers to mark as exits.
    # @return A character value holding the `<svg>` element.
    line_chart = function(values, label, entry_bars, exit_bars) {
      width <- 900
      height <- 260
      margin <- 10
      count <- length(values)
      lowest <- min(values, na.rm = TRUE)
      highest <- max(values, na.rm = TRUE)
      if (highest == lowest) {
        highest <- lowest + 1
      }
      x_positions <- margin + (seq_len(count) - 1) / max(1, count - 1) *
        (width - 2 * margin)
      y_positions <- height - margin - (values - lowest) / (highest - lowest) *
        (height - 2 * margin)
      points <- sprintf(
        "%.1f,%.1f",
        x_positions,
        y_positions
      )
      parts <- c(
        sprintf(
          "<svg viewBox=\"0 0 %d %d\" role=\"img\" aria-label=\"%s\">",
          width,
          height,
          label
        ),
        sprintf(
          "<polyline fill=\"none\" stroke=\"var(--accent)\" stroke-width=\"1.5\" points=\"%s\"/>",
          paste(points, collapse = " ")
        )
      )
      for (bar in entry_bars) {
        parts <- c(
          parts,
          sprintf(
            "<circle cx=\"%.1f\" cy=\"%.1f\" r=\"4\" fill=\"var(--entry)\"/>",
            x_positions[[bar]],
            y_positions[[bar]]
          )
        )
      }
      for (bar in exit_bars) {
        parts <- c(
          parts,
          sprintf(
            "<circle cx=\"%.1f\" cy=\"%.1f\" r=\"4\" fill=\"var(--exit)\"/>",
            x_positions[[bar]],
            y_positions[[bar]]
          )
        )
      }
      parts <- c(
        parts,
        sprintf(
          "<text x=\"%d\" y=\"20\" fill=\"var(--muted)\" font-size=\"12\">high %s, low %s</text>",
          margin,
          format(signif(highest, 6)),
          format(signif(lowest, 6))
        ),
        "</svg>"
      )
      paste(parts, collapse = "\n")
    },

    # Lays out the statistics, without the strategy, equity curve and trades, as an HTML table.
    # @return A character value holding the `<table>` element.
    statistics_table = function() {
      rows <- c()
      for (name in names(self$results)) {
        if (startsWith(name, "_")) {
          next
        }
        value <- self$results[[name]]
        if (is.numeric(value) && !inherits(value, "difftime")) {
          text <- format(signif(value, 6))
        } else {
          text <- format(value)
        }
        rows <- c(
          rows,
          sprintf(
            "<tr><th>%s</th><td>%s</td></tr>",
            private$escape(name),
            private$escape(text)
          )
        )
      }
      paste(
        c(
          "<table>",
          rows,
          "</table>"
        ),
        collapse = "\n"
      )
    },

    # Lays out the trades as an HTML table.
    # @param trades The `data.frame` of trades from the statistics.
    # @return A character value holding the `<table>` element.
    trades_table = function(trades) {
      columns <- c(
        "Size",
        "EntryTime",
        "EntryPrice",
        "ExitTime",
        "ExitPrice",
        "PnL",
        "ReturnPct"
      )
      header <- sprintf(
        "<tr>%s</tr>",
        paste(sprintf("<th>%s</th>", columns), collapse = "")
      )
      rows <- c()
      for (index in seq_len(nrow(trades))) {
        cells <- c()
        for (column in columns) {
          value <- trades[[column]][index]
          if (is.numeric(value)) {
            text <- format(signif(value, 6))
          } else {
            text <- format(value)
          }
          cells <- c(
            cells,
            sprintf("<td>%s</td>", private$escape(text))
          )
        }
        rows <- c(
          rows,
          sprintf("<tr>%s</tr>", paste(cells, collapse = ""))
        )
      }
      paste(
        c(
          "<table>",
          header,
          rows,
          "</table>"
        ),
        collapse = "\n"
      )
    }
  )
)
