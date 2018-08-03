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
    if ( length(y) == 0 | is.na(y) ) {
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
