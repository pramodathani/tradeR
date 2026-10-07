#' The errors the asset basket classes signal
#'
#' @description
#' Each name is an error class and each value is its parent class. `AssetBasketError` is the root.
#'
#' @format A named character vector, one entry per error class:
#' \describe{
#'   \item{`AssetBasketError`}{A failure in building, reading, storing or trading an asset basket.}
#'   \item{`BasketNotFoundError`}{No stored basket has the requested name, or none is in effect on the requested date.}
#'   \item{`BasketMemberError`}{A basket's members are unusable, such as an instrument UBI cannot find, an instrument named twice, or weights given for only some members.}
#'   \item{`BasketCsvImportError`}{A CSV file could not be turned into a basket, such as one without a `symbol` column.}
#' }
#' @keywords internal
ASSET_BASKETS_ERROR_PARENTS <- c(
  AssetBasketError = "error",
  BasketNotFoundError = "AssetBasketError",
  BasketMemberError = "AssetBasketError",
  BasketCsvImportError = "AssetBasketError"
)
