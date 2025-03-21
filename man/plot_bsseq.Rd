% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_bsseq.R
\name{plot_bsseq}
\alias{plot_bsseq}
\title{Plot iscream::query_all against bsseq::read.bismark and biscuiteer::readBiscuit}
\usage{
plot_bsseq(
  benchmark,
  files_or_regions = "files",
  other_max_count = 10,
  linewidth = 0.6,
  dot_size = 0.5,
  alpha = 0.8,
  outfile = NULL
)
}
\arguments{
\item{benchmark}{The color to use for iscream::bsseq}

\item{files_or_regions}{Whether to plot files or region counts as x-axis.}

\item{other_max_count}{The count to fix either file or regions at - the opposite of the files_or_regions arg}

\item{linewidth}{The alpha level for the points}

\item{dot_size}{The size for the runtime geom_points}

\item{alpha}{The alpha level for the points}

\item{outfile}{Optional file to write the plot to}
}
\description{
Plot iscream::query_all against bsseq::read.bismark and biscuiteer::readBiscuit
}
