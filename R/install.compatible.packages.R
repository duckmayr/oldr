## This is the main workhorse function, called in a loop by the user-facing
## function.
install_newest_usable_version <- function(package, R_version, lib) {
    # First we check if package is available for R_version
    download_method <- get_download_method()
    available_packages <- available.packages(method = download_method)
    if ( package %in% rownames(available_packages) ) {
        # We should be able to install if this is the case,
        # but we double-check
        current_version_info <- available.packages()[package, ]
        current_depends <- current_version_info["Depends"]
        current_depends <- extract_r_version_number(current_depends)
        install_this_version <- compare_r_versions(R_version,
                                                   current_depends)
        # If so, we install the latest available version
        if ( install_this_version ) {
            install.packages(pkgs = package, lib = lib)
            return(invisible())
        }
    }
    # If not, we find all previously available versions
    url_base <- "https://cloud.r-project.org/src/contrib/"
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
        if ( compare_r_versions(R_version, this_depends) ) {
            install.packages(pkgs = temp, lib = lib, repos = NULL)
            unlink(temp)
            return(invisible())
        }
        # Otherwise, we unlink the temp file and continue with the loop
        unlink(temp)
    }
    # If we get to the end and haven't installed anything, throw a warning
    warning(paste("Package", package, "unvailable for R version",
                  R_version), call. = FALSE)
    return(invisible())
}


#' Install the Newest Usable Version of R packages
#'
#' Looks through the CRAN archives for the newest published version of
#' R packages that are compatible with the version of R installed.
#'
#' @param package_name A character vector of names of packages to install
#' @param R_version A character vector giving the R version(s) to attempt
#'   installation for. The default, "installed_version", will attempt
#'   installation for the version of R from which the function was called.
#'   Any entry that does not contain a version number (e.g. "3.4.3") will
#'   be ignored.
#' @param lib A character vector giving the directories to install the packages
#'   to (see \code{\link[utils]{install.packages}}). The vector should be
#'   either length one or of the same length as R_version; the first element
#'   will be used for installing packages for the first R version supplied,
#'   the second for the second version, etc.; if only one lib is supplied,
#'   all packages for all versions will be installed in that directory,
#'   so if installation is done for multiple R versions, the only surviving
#'   installations will be for the last supplied element of R_version.
#'   The default is the first element of \code{\link[base]{.libPaths}}().
#'
#' @export
install.compatible.packages <- function(package_name,
                                        R_version = "installed_version",
                                        lib = .libPaths()[1]) {
    version_pattern <- "\\d+\\.\\d+\\.\\d+"
    R_version[grepl("installed_version", R_version)] <- R.version.string
    R_version <- extract_match(version_pattern, R_version)
    if ( length(R_version) < 1 ) {
        stop("Provide a valid character vector for R_version.", call. = FALSE)
    }
    if ( length(lib) == 1 ) {
        lib <- rep(lib, length(R_version))
    }
    if ( length(lib) != length(R_version) ) {
        message("R_version and lib are not of the same length.")
        message("Recycle the lib vector to be of the same length as R_version?")
        if ( menu(c("Yes", "No")) == 1 ) {
            lib <- rep(lib, length.out = length(R_version))
        } else {
            stop("Provide a lib vector of appropriate length.", call. = FALSE)
        }
    }
    for ( i in 1:length(R_version) ) {
        for ( package in package_name ) {
            install_newest_usable_version(package, R_version[i], lib[i])
        }
    }
    return(invisible())
}
