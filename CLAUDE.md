# CLAUDE.md

R package `oeis.tools`: R port of the Python
[oeis-tools](https://github.com/oeistools/oeis-tools) package. Fetches OEIS
sequences and b-files into S3 objects (`Sequence`, `BFile`, environment-based),
stores terms as `gmp::bigz`, and plots with `ggplot2`.

Current release status and to-do list: see `PLAN.md`. The package is on its way
to CRAN, so every change must keep `R CMD check --as-cran` clean.

## Commands

```sh
Rscript -e 'roxygen2::roxygenise()'          # regenerate man/ and NAMESPACE after editing roxygen comments
Rscript -e 'devtools::test()'                # tests (all HTTP is mocked)
Rscript -e 'lintr::lint_package()'           # must report 0 lints
Rscript -e 'spelling::spell_check_package()' # add real terms to inst/WORDLIST
# Full CRAN check: build into a temp dir, then check the tarball
R CMD build . && R CMD check --as-cran --no-manual oeis.tools_<version>.tar.gz
```

## Rules

- **Network examples:** use `@examplesIf oeis_available()`, never `\dontrun{}`
  or `\donttest{}`. OEIS returns HTTP 403 to GitHub Actions runners (and
  possibly CRAN machines); an unguarded example fails the check.
- **Tests never touch the network.** Mock `.oeis_get_text` / `.oeis_get_raw`
  (or `.oeis_perform`) with `testthat::local_mocked_bindings()`.
- **All HTTP goes through `.oeis_perform()`** in `R/utils.R`: it sets the
  honest User-Agent and turns failures into an informative error naming the
  URL. Never use a browser User-Agent string (CRAN policy).
- **Never write to the user's files by default.** `create_bfile()` requires
  `output_path`; examples and tests write to `tempdir()` / `withr::local_tempdir()`.
- **Every exported function** needs `@return` and `@examples` (or
  `@examplesIf`).
- **Names that match the Python API** (`Sequence`, `BFile`, `OEIS_URL`, ...)
  are intentional; `.lintr` allows them. Don't rename them to snake_case.
- **Release bookkeeping:** bump `Version` in DESCRIPTION, add a `NEWS.md`
  entry, and update `version:` in `CITATION.cff` together. New top-level
  non-package files must be added to `.Rbuildignore`.
