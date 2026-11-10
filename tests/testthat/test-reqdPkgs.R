# tests/testthat/test-reqdPkgs.R
# --- Helpers ---------------------------------------------------------------

# Package names declared in a module's reqdPkgs, without GitHub owner, branch or version
moduleReqdPkgs <- function(moduleFile) {
  findReqd <- function(e) {
    if (is.call(e)) {
      if (!is.null(names(e)) && "reqdPkgs" %in% names(e)) return(e[["reqdPkgs"]])
      for (a in as.list(e)[-1L]) {
        r <- findReqd(a)
        if (!is.null(r)) return(r)
      }
    }
    NULL
  }
  for (e in parse(moduleFile, keep.source = FALSE)) {
    reqd <- findReqd(e)
    if (!is.null(reqd)) break
  }
  pkgs <- unlist(eval(reqd, baseenv()))
  sub("@.*$", "", sub("^.*/", "", sub("[ (].*$", "", pkgs)))
}

# Packages the code in `files` calls as pkg::fun() (comments excluded), without base R's own
qualifiedPkgs <- function(files) {
  basePkgs <- c("base", "utils", "stats", "methods", "tools", "parallel", "grDevices", "graphics")
  pkgs <- unlist(lapply(files, function(f) {
    pd <- utils::getParseData(parse(f, keep.source = TRUE))
    pd$text[pd$token == "SYMBOL_PACKAGE"]
  }))
  setdiff(unique(pkgs), basePkgs)
}

# --- Tests -----------------------------------------------------------------

testthat::test_that("reqdPkgs declares googledrive, whose functions createDisturbanceList() calls", {
  testthat::skip_if_not_installed("googledrive")
  testthat::skip_if_not_installed("codetools")
  calls <- codetools::findGlobals(createDisturbanceList, merge = FALSE)$functions
  driveCalls <- intersect(calls, getNamespaceExports("googledrive"))
  testthat::expect_gt(length(driveCalls), 0L)
  reqd <- moduleReqdPkgs(testthat::test_path("..", "..", "anthroDisturbance_DataPrep.R"))
  testthat::expect_true("googledrive" %in% reqd,
                        info = paste("calls:", paste(driveCalls, collapse = ", ")))
})

testthat::test_that("reqdPkgs declares every package the module code calls with pkg::", {
  moduleDir <- testthat::test_path("..", "..")
  files <- c(file.path(moduleDir, "anthroDisturbance_DataPrep.R"),
             list.files(file.path(moduleDir, "R"), "[.]R$", full.names = TRUE))
  used <- qualifiedPkgs(files)
  reqd <- moduleReqdPkgs(file.path(moduleDir, "anthroDisturbance_DataPrep.R"))
  testthat::expect_equal(setdiff(used, reqd), character(0))
})
