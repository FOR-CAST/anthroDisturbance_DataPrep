# [EDIT-6] qs/GoogleDrive removed: identical to potentialResourcesNT_DataPrep/R/wrapTerra.R (.rds + Zenodo)
unwrapTerraList <- function(terraList, generalPath){
  # Updated to using rds instead
  updatePath <- FALSE
  if (all(!is.list(terraList),
          !file.exists(file.path(generalPath, "theList.rds")))) {
    message(paste0("The terraList file provided seems to be a link to the archive. The contents will be",
                   " downloaded and extracted before recovering."))
    terraList <- prepInputs(url = terraList,
               archive = "disturbanceList.zip",
               targetFile = "theList.rds",
               fun = "readRDS")
    updatePath <- TRUE
  } else {
    if (all(!is.list(terraList),
            file.exists(file.path(generalPath, "theList.rds")))){

      # When the path to the object is being passed
      terraList <- readRDS(file.path(generalPath, "theList.rds"))
      updatePath <- TRUE
    } else {
      # When the object is directly being passed
      updatePath <- TRUE
    }
  }
  listNames <- lapply(1:length(names(terraList)), function(index1){
    obj <- lapply(1:length(names(terraList[[index1]])), function(index2){
      message(paste0("Recovering ", names(terraList[[index1]][[index2]])))
      if (updatePath){
        print(paste0("terraList was a link. Fixing paths for ", index2))
        # [EDIT-7] gsub(pattern = dirname(.)) is a regex: dirname is "." for the flat Zenodo
        # zip, which matches every character and repeats generalPath. Use basename instead.
        terraList[[index1]][[index2]] <- file.path(generalPath,
                                                   basename(terraList[[index1]][[index2]]))
      }
      obj2 <- readRDS(terraList[[index1]][[index2]])
      return(terra::vect(obj2))
    })
    names(obj) <- names(terraList[[index1]])
    return(obj)
  })
  names(listNames) <- names(terraList)
  return(listNames)
}
