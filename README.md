# oldr

[![Travis-CI Build Status](https://travis-ci.org/duckmayr/oldr.svg?branch=master)](https://travis-ci.org/duckmayr/oldr)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/duckmayr/oldr?branch=master&svg=true)](https://ci.appveyor.com/project/duckmayr/oldr)

`oldr` was created for the simple purpose of allowing users of old versions of `R` to install the latest available versions (on CRAN) of R packages compatible with their version of R.

## Installing

If you have [`devtools`](https://CRAN.R-project.org/package=devtools), or at least [`remotes`](https://cran.r-project.org/package=remotes), you can install via

```r
    remotes::install_github("duckmayr/oldr")
```

If you don't, you can download or clone the repository, then use `R CMD build oldr` and `R CMD INSTALL oldr_0.1.0.tar.gz`

(For more details on installing the package from source if you don't have [`devtools`](https://CRAN.R-project.org/package=devtools), see, e.g., [this page](http://kbroman.org/pkg_primer/pages/build.html]))

