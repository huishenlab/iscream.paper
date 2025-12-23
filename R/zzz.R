.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Parsing up TOML config")
  config_file <- getOption("iscream.paper.config")
  extdata <- system.file("extdata", package = "iscream.paper")
  if (is.null(config_file)) {
    config_file <- list.files(
      extdata,
      pattern = "config.toml",
      full.names = TRUE
    )
  }
  iscream_run_conf <<- get_config(config_file)
  iscream_datasets <<- setup_datasets(iscream_run_conf)

  aligners <- unique(iscream_datasets$aligner)
  exp_types <- unique(iscream_datasets$exp_type)
  datasets <- unique(iscream_datasets$dataset)

  packageStartupMessage("Checking dataset existence")
  config_file <- getOption("iscream.paper.config")
  iscream_datasets[, exists := dir.exists(dataset_path)][]

  non_existent <- which(!iscream_datasets$exists)

  packageStartupMessage(paste0(
    "Got dataset config from '",
    config_file,
    "' and may be found in the `iscream_run_conf` object"
  ))
  packageStartupMessage(paste(
    "Experiment types:",
    paste(exp_types, collapse = ", ")
  ))
  packageStartupMessage(paste("Aligners:", paste(aligners, collapse = ", ")))
  packageStartupMessage(paste("Datasets:", paste(datasets, collapse = ", ")))
  if (length(non_existent) > 0) {
    packageStartupMessage(paste(
      "The following dataset directories do not exist:",
      paste(iscream_datasets$dataset_path[non_existent], collapse = ", ")
    ))
  }
  packageStartupMessage("See `iscream_datasets` for available datasets")

  package_colors <<- scale_color_manual(
    values = c(
      "BSseq" = "#0072b2",
      "biscuiteer" = "#e69f00",
      "iscream" = "black",
      "iscream sparse" = "coral4",
      "Rsamtools" = "#009e73",
      "bedtoolsr" = "#D55E00"
    ),
    drop = FALSE
  )

  packageStartupMessage("Setting up result dirs")
  dir.create("data/results/benchmarks", recursive = TRUE)
  dir.create("data/results/figures")
}
