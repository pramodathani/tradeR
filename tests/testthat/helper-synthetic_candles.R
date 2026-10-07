SyntheticCandles <- R6::R6Class(
  "SyntheticCandles",
  inherit = PerformanceMeasures,
  public = list(
    prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      index <- 1:120
      open <- 100 + 10 * sin(index / 5) + 0.1 * index
      close <- open + 2 * cos(index / 3)
      high <- pmax(open, close) + 1 + 0.5 * sin(index / 7)^2
      low <- pmin(open, close) - 1 - 0.5 * cos(index / 11)^2
      volume <- 1000 + (index * 37) %% 101 * 10
      start <- as.POSIXct("2026-01-01", tz = "Asia/Kolkata")
      data.frame(
        exchange = "nse",
        segment = "nse_equities",
        interval = "day",
        datetime = start + index * 86400,
        open = open,
        high = high,
        low = low,
        close = close,
        volume = volume
      )
    }
  )
)

EmptyCandles <- R6::R6Class(
  "EmptyCandles",
  inherit = PerformanceMeasures,
  public = list(
    prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      NULL
    }
  )
)
