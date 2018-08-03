extract_match <- function(pattern, string, perl = TRUE) {
    # Extracts instances of pattern in string
    return(regmatches(string, regexpr(pattern, string, perl = perl)))
}

extract_r_version_number <- function(x) {
    # Gets the R version number from a Depends field
    pattern <- "(?<=R \\(>= )\\d+\\.\\d+\\.\\d+"
    return(extract_match(pattern, x))
}

compare_r_versions <- function(x, y) {
    # Returns TRUE if R version x >= R version y,
    # where x and y are given as strings, e.g., "3.4.0"
    if ( length(y) == 0 ) {
        return(TRUE)
    }
    if ( is.na(y) ) {
        return(TRUE)
    }
    x <- c(sapply(strsplit(x, "\\."), as.numeric))
    y <- c(sapply(strsplit(y, "\\."), as.numeric))
    if ( y[1] > x[1] ) {
        return(FALSE)
    } else if ( x[1] > y[1] ) {
        return(TRUE)
    }
    if ( y[2] > x[2] ) {
        return(FALSE)
    } else if ( x[2] > y[2] ) {
        return(TRUE)
    }
    if ( y[3] > x[3] ) {
        return(FALSE)
    }
    return(TRUE)
}

get_download_method <- function() {
    R_version <- extract_match("\\d+\\.\\d+\\.\\d+", R.version.string)
    has_libcurl <- capabilities()
    if ( "libcurl" %in% names(has_libcurl) ) {
        if ( has_libcurl["libcurl"] ) {
            has_libcurl <- TRUE
        } else {
            has_libcurl <- FALSE
        }
    } else {
        has_libcurl <- FALSE
    }
    if ( compare_r_versions(R_version, "3.3.0") ) {
        return("auto")
    }
    else if ( has_libcurl ) {
        return("libcurl")
    } else if ( .Platform$OS.type == "windows" ) {
        return("wininet")
    } else if ( Sys.which("wget")[1] != "" ) {
        return("wget")
    } else if ( Sys.which("curl")[1] != "" ) {
        return("curl")
    } else {
        stop(paste0("No available method for downloading from https://\n",
                    "Please install, for example, wget or curl."))
    }
}
