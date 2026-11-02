## Run the module's unit tests, from the module root: Rscript tests/run-tests.R [file filter]
## The tests call the helpers in R/ directly, so this sources them and attaches the packages their
## unqualified calls come from (data.table, googledrive, reproducible, terra). Every test is
## skip_on_cran(), so NOT_CRAN is set here. Used by .github/workflows/test-module.yaml.
Sys.setenv(NOT_CRAN = "true")
suppressPackageStartupMessages({
  library(testthat)
  library(mockery)
  library(data.table)
  library(googledrive)
  library(reproducible)
  library(terra)
})
for (f in list.files("R", "[.]R$", full.names = TRUE)) {
  source(f)
}
args <- commandArgs(trailingOnly = TRUE)
testthat::test_dir(
  file.path("tests", "testthat"),
  filter = if (length(args)) args[[1L]] else NULL,
  reporter = "summary",
  stop_on_failure = TRUE
)
