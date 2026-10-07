#' The errors the instrument classes signal
#'
#' @description
#' Each name is an error class and each value is its parent class. `InstrumentError` is the root, and every other class is a flat sibling under it, so catch the contract's own error or `InstrumentError` for any instrument problem.
#'
#' @format A named character vector, one entry per error class:
#' \describe{
#'   \item{`InstrumentError`}{An instrument UBI does not know, or one that cannot be used as asked.}
#'   \item{`TradeableInstrumentError`}{An instrument asked for as tradeable that cannot be traded, such as an index.}
#'   \item{`NonTradeableInstrumentError`}{An instrument asked for as non-tradeable that can in fact be traded.}
#'   \item{`DerivativeError`}{An instrument asked for as a derivative that is neither a future nor an option, has no expiry date, or sits in a segment with no known underlying segment.}
#'   \item{`FuturesError`}{An instrument asked for as a futures contract that is not one, or a futures discovery call made on a class that names no segment.}
#'   \item{`OptionError`}{An instrument asked for as an option that is not one or lacks a strike price or option type, or an option discovery call made on a class that names no segment.}
#'   \item{`IndexFuturesError`}{A futures contract asked for as an index future whose segment is not an index futures segment.}
#'   \item{`IndexOptionError`}{An option asked for as an index option whose segment is not an index options segment.}
#'   \item{`UnderlyingError`}{A futures or option contract whose underlying cannot be found: none was given, UBI links it to none, and its family's default finds none.}
#'   \item{`PositionError`}{A position that cannot be changed as asked, or one that is not held at all.}
#'   \item{`HoldingError`}{A holding that cannot be changed as asked, or one that is not held at all.}
#'   \item{`EquityError`}{An equity share UBI does not know, or one that is not in the equities segment.}
#'   \item{`EquityFuturesError`}{An equity futures contract UBI does not know, or one that is not in the equity futures segment.}
#'   \item{`EquityOptionError`}{An equity option UBI does not know, or one that is not in the equity options segment.}
#'   \item{`EquityIndexError`}{An equity index UBI does not know, or one that is not in the equity indices segment.}
#'   \item{`EquityIndexFuturesError`}{An equity index futures contract UBI does not know, or one that is not in the equity index futures segment.}
#'   \item{`EquityIndexOptionError`}{An equity index option UBI does not know, or one that is not in the equity index options segment.}
#'   \item{`FixedIncomeError`}{A bond UBI does not know, or one that is not in the fixed income segment.}
#'   \item{`FixedIncomeFuturesError`}{A bond futures contract UBI does not know, or one that is not in the fixed income futures segment.}
#'   \item{`FixedIncomeOptionError`}{A bond option UBI does not know, or one that is not in the fixed income options segment.}
#'   \item{`FixedIncomeIndexError`}{A fixed income index UBI does not know, or one that is not in the fixed income indices segment.}
#'   \item{`FixedIncomeIndexFuturesError`}{A fixed income index futures contract UBI does not know, or one that is not in the fixed income index futures segment.}
#'   \item{`FixedIncomeIndexOptionError`}{A fixed income index option UBI does not know, which is true of every one of them today, or one that is not in the fixed income index options segment.}
#'   \item{`CommodityError`}{A commodity UBI does not know, or one that is not in the commodities segment.}
#'   \item{`CommodityFuturesError`}{A commodity futures contract UBI does not know, or one that is not in the commodity futures segment.}
#'   \item{`CommodityOptionError`}{A commodity option UBI does not know, or one that is not in the commodity options segment.}
#'   \item{`CommodityIndexError`}{A commodity index UBI does not know, or one that is not in the commodity indices segment.}
#'   \item{`CommodityIndexFuturesError`}{A commodity index futures contract UBI does not know, or one that is not in the commodity index futures segment.}
#'   \item{`CommodityIndexOptionError`}{A commodity index option UBI does not know, or one that is not in the commodity index options segment.}
#'   \item{`CurrencyError`}{A currency pair UBI does not know, or one that is not in the currencies segment.}
#'   \item{`CurrencyFuturesError`}{A currency futures contract UBI does not know, or one that is not in the currency futures segment.}
#'   \item{`CurrencyOptionError`}{A currency option UBI does not know, or one that is not in the currency options segment.}
#'   \item{`CurrencyIndexError`}{A currency index UBI does not know, which is true of every one of them today, or one that is not in the currency indices segment.}
#'   \item{`CurrencyIndexFuturesError`}{A currency index futures contract UBI does not know, which is true of every one of them today, or one that is not in the currency index futures segment.}
#'   \item{`CurrencyIndexOptionError`}{A currency index option UBI does not know, which is true of every one of them today, or one that is not in the currency index options segment.}
#'   \item{`ExchangeTradedFundError`}{An exchange traded fund UBI does not know, or one that is not in the exchange traded funds segment.}
#'   \item{`InvestmentTrustError`}{An investment trust UBI does not know, or one that is not in the investment trusts segment.}
#'   \item{`MutualFundError`}{A mutual fund scheme UBI does not know, or one that is not in the mutual funds segment.}
#' }
#' @keywords internal
ASSETS_ERROR_PARENTS <- c(
  InstrumentError = "error",
  TradeableInstrumentError = "InstrumentError",
  NonTradeableInstrumentError = "InstrumentError",
  DerivativeError = "InstrumentError",
  FuturesError = "InstrumentError",
  OptionError = "InstrumentError",
  IndexFuturesError = "InstrumentError",
  IndexOptionError = "InstrumentError",
  UnderlyingError = "InstrumentError",
  PositionError = "InstrumentError",
  HoldingError = "InstrumentError",
  EquityError = "InstrumentError",
  EquityFuturesError = "InstrumentError",
  EquityOptionError = "InstrumentError",
  EquityIndexError = "InstrumentError",
  EquityIndexFuturesError = "InstrumentError",
  EquityIndexOptionError = "InstrumentError",
  FixedIncomeError = "InstrumentError",
  FixedIncomeFuturesError = "InstrumentError",
  FixedIncomeOptionError = "InstrumentError",
  FixedIncomeIndexError = "InstrumentError",
  FixedIncomeIndexFuturesError = "InstrumentError",
  FixedIncomeIndexOptionError = "InstrumentError",
  CommodityError = "InstrumentError",
  CommodityFuturesError = "InstrumentError",
  CommodityOptionError = "InstrumentError",
  CommodityIndexError = "InstrumentError",
  CommodityIndexFuturesError = "InstrumentError",
  CommodityIndexOptionError = "InstrumentError",
  CurrencyError = "InstrumentError",
  CurrencyFuturesError = "InstrumentError",
  CurrencyOptionError = "InstrumentError",
  CurrencyIndexError = "InstrumentError",
  CurrencyIndexFuturesError = "InstrumentError",
  CurrencyIndexOptionError = "InstrumentError",
  ExchangeTradedFundError = "InstrumentError",
  InvestmentTrustError = "InstrumentError",
  MutualFundError = "InstrumentError"
)
