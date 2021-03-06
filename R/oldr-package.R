#' oldr
#'
#' oldr provides a function to install the latest available version of an R
#' package for old versions of R.
#'
#' This package was created in response to a Stack Overflow question
#' \href{https://stackoverflow.com/questions/28766923/}{(available here)}
#' about the common problem of dealing with a package being unavailable
#' and requesting a programmatic way to install the latest version of a
#' package that is available for your version of R.
#'
#' The approach taken in this package was developed independently of,
#' but resembles, an approach taken in an answer to a similar question
#' \href{https://stackoverflow.com/a/16117078/8386140}{(available here)}.
#' However, this approach is slightly different in a few respects.
#' For example, only functions from base R are needed, specifically
#' only functions from the \code{base} and \code{utils} packages.
#' Additionally, (likely incomplete) pains are taken here to help ensure
#' back-compatibility for older versions of R that were not taken in the
#' other approach.
#'
#' It was inspired in part by the source code for the \code{install_version()}
#' function for the popular package \code{devtools} by Hadley Wickham.
#' However, importantly different approaches to some actions are taken
#' by this package, both to ensure dependence only on base R packages,
#' as well as to ensure it will work with older versions of the
#' \code{url()} function  from the \code{base} package and the
#' \code{download.files()} function from the \code{utils} package.
#' Of course, also this package also is not designed just for installation of a
#' specific version of R packages that the user would have to find the version
#' number and supply it, but is designed to find the newest \emph{compatible}
#' version of an R package for your version of R, then install that version.
#'
#' @name oldr
#' @docType package
#' @author  JB Duck-Mayr
#' @importFrom utils available.packages download.file install.packages sessionInfo untar
NULL
