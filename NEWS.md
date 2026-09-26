# oeis.tools 0.3.0

## New features

* `Sequence` gains `get_bibtex()`, `get_data_values()`, `get_graph_image()`,
  `get_graph_png()` and `get_keyword_description()`.
* `BFile` gains `get_bfile_indices()`; new `create_bfile()` helper.
* `plot_data()` supports overlaying several b-files on one plot (`p` argument)
  and returning the plot object (`return_plot`).
* API requests send a package `User-Agent`.

## Documentation

* New "Getting started" vignette and expanded README.
* Public API now mirrors the Python
  [oeis-tools](https://github.com/oeistools/oeis-tools) package.

* Added citation information (`citation("oeis.tools")` and `CITATION.cff`).

## Internal

* Expanded test suite; package passes `R CMD check --as-cran`.

# oeis.tools 0.2.0

* Initial release: `Sequence` and `BFile` S3 classes, OEIS metadata and
  b-file fetching, `gmp::bigz` term storage, and `ggplot2` plotting.
