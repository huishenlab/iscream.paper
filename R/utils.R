#' Join two benhmarks from sc and bulk
#'
#' @param sc The sc benchmark data.table
#' @param bulk The sc benchmark data.table
#' @importFrom data.table := copy
#'
#' @export
join_exp_types <- function(sc, bulk) {
  s <- copy(sc)
  b <- copy(bulk)
  s[, exp_type := 'single-cell']
  b[, exp_type := 'bulk']
  rbind(s, b, fill = TRUE)
}

#' Join two benhmarks from sc and bulk
#'
#' @param sc The sc benchmark data.table
#' @param bulk The sc benchmark data.table
#' @importFrom data.table rbindlist := fread
#'
#' @export
read_sc <- function() {
  dt <- list(
    fread(iscream_run_conf$results$bsseq$sc$data),
    fread(iscream_run_conf$results$query_all$sc$data),
    fread(iscream_run_conf$results$biscuiteer$sc$data)
  ) |> rbindlist(use.names = TRUE)
  dt[, thread_count := as.factor(thread_count)][]
}


#' Read bulk benchmarks
#'
#' @param sc The sc benchmark data.table
#' @param bulk The sc benchmark data.table
#' @importFrom data.table rbindlist := fread
#'
#' @export
read_bulk <- function() {
  dt <- list(
    fread(iscream_run_conf$results$bsseq$bulk$data),
    fread(iscream_run_conf$results$query_all$bulk$data),
    fread(iscream_run_conf$results$biscuiteer$bulk$data)
  ) |> rbindlist(use.names = TRUE)
  dt[, thread_count := as.factor(thread_count)][]
}



