.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "oeis.tools ",
    utils::packageVersion("oeis.tools"),
    " | https://github.com/oeistools/oeis-tools-R"
  )
}

# Silence global variable warnings
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(".data", "index", "value"))
}
