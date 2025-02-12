#' Get the dataset configs
#'
#' @importFrom RcppTOML parseTOML
#' @export
get_config <- function(config_toml) {
  parseTOML(config_toml)
}
