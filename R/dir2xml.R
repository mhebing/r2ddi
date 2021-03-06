#' Import multiple files from one directory
#'
#' @param path_in Path to files
#' @param file_type Accepted filetypes ("dta", "sav", "csv", or "all" for the
#'                  for the previous three)
#' @param multicore Use multicore functionallity
#' @export
dir2xml <- function(path_in, path_out, file_type = "dta", multicore = TRUE, missing_codes = NULL, my_cores = 1) {


  main <- function() {
  # check if path_out exists, ddi2xml will fail otherwise
  if(!file_test("-d",path_out)) {
    message(paste0(path_out," is not a valid directory. Create the directory or check your file permissions."))
  } else {
    file_list <- .file_list(path_in, file_type)
    if(multicore)
      result_list <- mclapply(file_list, .process, path_in, path_out, missing_codes, mc.preschedule=FALSE, mc.cores = my_cores)
    else
      result_list <- lapply(file_list, .process, path_in, path_out, missing_codes)
    result_list
    }
  }

  .process <- function(x, path_in, path_out, missing_codes) {
    ddi <- stata2ddi(
      file.path(path_in, x),
      .filename_without_extension(x),
      keep_data = FALSE,
      missing_codes = missing_codes)
    ddi2xml(ddi, file.path(
      path_out, paste(.filename_without_extension(x), ".xml", sep="")
    ))
    x
  }

  .filename_without_extension <- function(x) {
    gsub("(.*)[.][a-z0-1]*", "\\1", x, ignore.case=T)
  }

  .file_list <- function(path_in, file_type) {
    fl <- list.files(path_in)
    ex <- regexpr(fl, pattern = .pattern(file_type), ignore.case = TRUE)
    fl[ex != -1]
  }

  .pattern <- function(file_type) {
    if(!(file_type %in% c("all", "csv", "sav", "dta"))) {
      cat("Invalid file type:", file_type, "\n")
      pattern <- NULL
    } else if(file_type == "all") {
      pattern <- ".(dta|csv|sav)$"
    } else {
      pattern <- paste(".", file_type, "$", sep = "")
    }
    pattern
  }

  main()
}

