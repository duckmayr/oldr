## This is the main workhorse function, called in a loop by the user-facing
## function.
install_newest_usable_version <- function(package) {
    # First we need to know what R version we have
    installed_r_version <- extract_match("\\d+\\.\\d+\\.\\d+", R.version.string)
    available_packages <- available.packages()
    if ( package %in% rownames(available_packages) ) {
        # We should be able to install if this is the case,
        # but we double-check
        current_version_info <- available.packages()[package, ]
        current_version <- current_version_info["Version"]
        current_depends <- current_version_info["Depends"]
        install_this_version <- compare_r_versions(installed_r_version,
                                                   current_depends)
        # If so, we install the latest available version
        if ( install_this_version ) {
            install.packages(package)
            return(invisible())
        }
    }
    # If not, we find all previously available versions
    url_base <- "https://cloud.r-project.org/src/contrib/"
    download_method <- get_download_method()
    archive_tmp <- tempfile()
    download.file(paste0(url_base, "Meta/archive.rds"), archive_tmp,
                  quiet = TRUE, method = download_method)
    archive_meta <- readRDS(archive_tmp)
    unlink(archive_tmp)
    archive_meta <- archive_meta[[package]]
    archive_meta <- archive_meta[order(archive_meta[ , "mtime"]), ]
    versions <- rev(rownames(archive_meta))
    # And one by one, in reverse chronological order of release,
    # see if a version can be installed, and if so, install it.
    for ( version in versions ) {
        version_no_pattern <- sprintf("(?<=%s_)[\\d\\.-]+(?=\\.tar)", package)
        version_no <- extract_match(version_no_pattern, version)
        version_url <- paste0(url_base, "Archive/", version)
        temp <- tempfile()
        download.file(version_url, temp, quiet = TRUE, method = download_method)
        desc_filename <- paste0(package, "/DESCRIPTION")
        untar(temp, files = desc_filename, exdir = tempdir())
        this_desc <- readLines(paste0(tempdir(), "/", desc_filename))
        this_depends <- this_desc[grepl("Depends:", this_desc)]
        # We just make sure that there's no surprises in the DESCRIPTION file
        if ( length(this_depends) > 1 ) {
            warning(paste("Version", version_no, "skipped due to error",
                          "parsing DESCRIPTION file."), call. = FALSE)
            unlink(temp)
            next()
        }
        this_depends <- extract_r_version_number(this_depends)
        # If this package version requires an R version less than or equal
        # to the version of R installed, or does not have an R version
        # requirement, we install it, unlink the temp file, and exit
        if ( compare_r_versions(installed_r_version, this_depends) ) {
            install.packages(temp, repos = NULL)
            unlink(temp)
            return(invisible())
        }
        # Otherwise, we unlink the temp file and continue with the loop
        unlink(temp)
    }
    # If we get to the end and haven't installed anything, throw a warning
    warning(paste("Package", package, "unvailable for R version",
                  installed_r_version), call. = FALSE)
    return(invisible())
}


#' Install the Newest Usable Version of R packages
#'
#' Looks through the CRAN archives for the newest published version of
#' R packages that are compatible with the version of R installed.
#'
#' @param package_name A character vector of names of packages to install
#'
#' @export
install.compatible.packages <- function(package_name) {
    for ( package in package_name ) {
        install_newest_usable_version(package)
    }
    return(invisible())
}
