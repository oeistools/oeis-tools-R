.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "oeis.tools ",
    utils::packageVersion("oeis.tools"),
    " | https://github.com/oeistools/oeis-tools-R"
  )
}
