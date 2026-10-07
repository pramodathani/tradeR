PerformanceFixtureCandles <- R6::R6Class(
  "PerformanceFixtureCandles",
  inherit = PerformanceMeasures,
  public = list(
    file_name = NULL,
    calls = 0,

    initialize = function(file_name = "performance_candles.csv") {
      self$file_name <- file_name
    },

    prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      self$calls <- self$calls + 1
      frame <- utils::read.csv(
        testthat::test_path("fixtures", self$file_name),
        stringsAsFactors = FALSE
      )
      frame$datetime <- TimeConverter$new()$moments(frame$datetime)
      frame
    }
  )
)

ParityMovingAverageCross <- R6::R6Class(
  "ParityMovingAverageCross",
  inherit = BacktestStrategy,
  public = list(
    initialize_strategy = function() {
      self$indicator(
        "fast_average",
        talib::SMA(self$data$Close, timePeriod = 10)
      )
      self$indicator(
        "slow_average",
        talib::SMA(self$data$Close, timePeriod = 30)
      )
    },

    next_candle = function() {
      fast <- self$indicators$fast_average
      slow <- self$indicators$slow_average
      if (self$crossover(fast, slow)) {
        self$position$close()
        self$buy()
      } else if (self$crossover(slow, fast)) {
        self$position$close()
        self$sell()
      }
    }
  )
)

ParityBracket <- R6::R6Class(
  "ParityBracket",
  inherit = BacktestStrategy,
  public = list(
    initialize_strategy = function() {
      self$indicator(
        "fast_average",
        talib::SMA(self$data$Close, timePeriod = 5)
      )
      self$indicator(
        "slow_average",
        talib::SMA(self$data$Close, timePeriod = 20)
      )
    },

    next_candle = function() {
      close <- utils::tail(self$data$Close, 1)
      fast <- self$indicators$fast_average
      slow <- self$indicators$slow_average
      if (self$crossover(fast, slow) && self$position$size == 0) {
        self$buy(
          size = 0.5,
          sl = close * 0.97,
          tp = close * 1.04,
          tag = "bracket"
        )
      } else if (self$crossover(slow, fast) && self$position$size == 0) {
        self$sell(
          size = 0.5,
          sl = close * 1.03,
          tp = close * 0.96
        )
      }
    }
  )
)

ParityStopAndLimit <- R6::R6Class(
  "ParityStopAndLimit",
  inherit = BacktestStrategy,
  public = list(
    initialize_strategy = function() {
      invisible(NULL)
    },

    next_candle = function() {
      close <- utils::tail(self$data$Close, 1)
      if (self$position$size == 0 && length(self$orders) == 0) {
        if (nrow(self$data) %% 2 == 0) {
          self$buy(size = 7, stop = close * 1.01)
        } else {
          self$buy(size = 7, limit = close * 0.99)
        }
      } else if (self$position$size != 0) {
        if (self$position$pl_pct > 3) {
          self$position$close(0.5)
        } else if (self$position$pl_pct < -3) {
          self$position$close()
        }
        for (trade in self$trades) {
          if (is.null(trade$sl)) {
            trade$sl <- close * 0.9
          }
        }
      }
    }
  )
)

ParityBuyOnce <- R6::R6Class(
  "ParityBuyOnce",
  inherit = BacktestStrategy,
  public = list(
    initialize_strategy = function() {
      invisible(NULL)
    },

    next_candle = function() {
      if (nrow(self$data) == 2) {
        self$buy(size = 10)
      }
      if (nrow(self$data) == 4) {
        self$position$close()
      }
    }
  )
)

ParityTinyCandles <- R6::R6Class(
  "ParityTinyCandles",
  public = list(
    frame = function() {
      data.frame(
        datetime = as.POSIXct(
          c(
            "2026-01-05",
            "2026-01-06",
            "2026-01-07",
            "2026-01-08",
            "2026-01-09",
            "2026-01-12"
          ),
          tz = "Asia/Kolkata"
        ),
        Open = c(
          100,
          102,
          104,
          103,
          107,
          108
        ),
        High = c(
          101,
          105,
          106,
          104,
          109,
          110
        ),
        Low = c(
          99,
          101,
          102,
          100,
          105,
          106
        ),
        Close = c(
          100.5,
          104,
          103,
          103.5,
          108,
          109
        ),
        Volume = c(
          1000,
          1100,
          1200,
          1300,
          1400,
          1500
        )
      )
    }
  )
)
