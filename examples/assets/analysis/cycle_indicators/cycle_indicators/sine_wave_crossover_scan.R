#' Scan a few shares and a basket for recent Hilbert sine wave crossovers.
#'
#' The program reads a year of daily candles for each candle source, finds every session in the last month on which the lead sine crossed the sine, and prints the most recent crossing with its direction, together with the phase of the dominant cycle and the two phasor components today.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/cycle_indicators/cycle_indicators/sine_wave_crossover_scan.R

library(tradeR)

#' A scan for sine wave crossovers, the Hilbert transform's turning signals.
#'
#' @field sources A named list mapping a label to the instrument or basket to scan.
#' @field days The integer number of days of candles to read.
#' @field recent_sessions The integer number of recent sessions searched for a crossing.
SineWaveCrossoverScan <- R6::R6Class(
  "SineWaveCrossoverScan",
  public = list(
    sources = NULL,
    days = NULL,
    recent_sessions = NULL,

    #' @description
    #' Creates the scan over three IT shares and a watchlist of them.
    #' @param days The integer number of days of candles to read.
    #' @param recent_sessions The integer number of recent sessions searched for a crossing.
    #' @return A new `SineWaveCrossoverScan` object.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the shares.
    initialize = function(days = 365, recent_sessions = 22) {
      symbols <- c(
        "INFY",
        "TCS",
        "WIPRO"
      )
      self$sources <- list()
      shares <- list()
      for (symbol in symbols) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        self$sources[[symbol]] <- share
        shares[[length(shares) + 1]] <- share
      }
      self$sources[["IT watchlist"]] <- Watchlist$new(
        name = "information technology",
        instruments = shares
      )
      self$days <- days
      self$recent_sessions <- recent_sessions
    },

    #' @description
    #' Finds the most recent crossing of the lead sine over or under the sine. A comparison with a missing value counts as not above, as it does in Python.
    #' @param candles A `data.frame` with `datetime`, `sine` and `lead_sine` columns.
    #' @return A character value naming the date and direction of the last crossing, or saying there was none.
    last_crossing = function(candles) {
      crossing <- "no crossing in the period"
      first_position <- max(2, nrow(candles) - self$recent_sessions + 1)
      for (position in seq_len(nrow(candles))) {
        if (position < first_position) {
          next
        }
        before <- isTRUE(
          candles$lead_sine[position - 1] > candles$sine[position - 1]
        )
        after <- isTRUE(candles$lead_sine[position] > candles$sine[position])
        day <- format(candles$datetime[position], "%Y-%m-%d")
        if (after && !before) {
          crossing <- sprintf("turned up on %s", day)
        }
        if (before && !after) {
          crossing <- sprintf("turned down on %s", day)
        }
      }
      crossing
    },

    #' @description
    #' Prints each source's last crossing, cycle phase and phasor components.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      for (label in names(self$sources)) {
        source <- self$sources[[label]]
        sine_wave <- source$hilbert_transform_sine_wave(days = self$days)
        if (is.null(sine_wave)) {
          cat(sprintf("%s: no candles\n", label))
          next
        }
        phase <- source$hilbert_transform_dominant_cycle_phase(days = self$days)
        phasor <- source$hilbert_transform_phasor_components(days = self$days)
        cat(
          sprintf(
            "%-13s %-26s phase %7.1f degrees  in-phase %+.3f  quadrature %+.3f\n",
            label,
            self$last_crossing(sine_wave),
            phase$ht_dcphase[nrow(phase)],
            phasor$inphase[nrow(phasor)],
            phasor$quadrature[nrow(phasor)]
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SineWaveCrossoverScan$new()$run()
}
