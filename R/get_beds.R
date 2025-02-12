get_beds <- function(path, aligner, mergecg) {
  if (aligner == 'biscuit') {
    pattern = ifelse(mergecg, "*_mergecg.bed.gz$", "*.bed.gz$")
  } else {
    pattern = "*.cov.gz$"
  }
  list.files(path, pattern = pattern, full.name = TRUE)
}

#' Get a vector of bedfiles based on experiment type, aligner and dataset name.
#' If only one match is found, the vector is returned, else matching datasets
#' are displayed
#'
#' @param experiment_type The experiment type (eg: "sc", or "bulk")
#' @param aligner_name The aligner name ("biscuit", "bismark", "bsbolt")
#' @param dataset_name The name of the dataset
#' @param mergecg Whether to return BISCUIT mergecg BEDs or not
#'
#' @importFrom RcppTOML parseTOML
#' @export
search_beds <- function(
  experiment_type = NULL,
  aligner_name = NULL,
  dataset_name = NULL,
  mergecg = TRUE
) {

  matching_type <- iscream_datasets
  matching_aligner <- iscream_datasets
  matching_name <- iscream_datasets

  if (!is.null(experiment_type)) {
    matching_type <- iscream_datasets[exp_type == experiment_type]
  }
  if (!is.null(aligner_name)) {
    matching_aligner <- iscream_datasets[aligner == aligner_name]
  }
  if (!is.null(dataset_name)) {
    matching_name <- iscream_datasets[dataset == dataset_name]
  }

  matching <- merge(matching_type, matching_aligner) |> merge(matching_name)
  matching_exists <- matching[exists == TRUE]

  if (nrow(matching_exists) == 1) {
    aligner <- matching_exists$aligner
    message("Found matching beds from")
    message(paste(capture.output(matching_exists), collapse = '\n'))
    return(get_beds(matching_exists$dataset_path, aligner, mergecg))
  } else if (nrow(matching_exists) == 0) {
    stop('No matching datasets found - see `iscream_datasets` for more information')
  }

  matching_exists
}

