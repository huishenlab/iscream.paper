extract_dataset <- function(dataset, aligner, exp_type, full_datasets) {
  path = full_datasets[[exp_type]][[aligner]][[dataset]]
  dataset_name = dataset
  data.table(
    exp_type = exp_type,
    aligner = aligner,
    dataset = dataset_name,
    dataset_path = path
  )
}

#' Get a table of the datasets provided in the config
#'
#' @param iscream_run_conf the RcppTOML struct containing the config
#' @importFrom data.table rbindlist
#' @export
setup_datasets <- function(iscream_run_conf) {
  datasets <- iscream_run_conf$datasets$wgbs
  exp_types <- names(datasets)
  aligners <- lapply(exp_types, function(exp_type) {
    names(datasets[[exp_type]])
  }) |> unlist() |> unique()

  lapply(exp_types, function(exp_type) {
    lapply(aligners, function(aligner) {
      lapply(names(datasets[[exp_type]][[aligner]]), extract_dataset, aligner, exp_type, datasets)
    })
  }) |> unlist(recursive = F) |> unlist(recursive = F) |> rbindlist()
}
