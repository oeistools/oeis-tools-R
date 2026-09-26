# oeis.tools 0.3.1

## Breaking changes

* `create_bfile()` no longer writes to the working directory by default:
  `output_path` must now be supplied.

## Bug fixes and improvements

* New `oeis_available()` reports whether the OEIS web service can be reached
  (it may refuse requests from some cloud and CI hosts).
* `get_graph_image()` failed whenever 'IRdisplay' was installed (it passed an
  argument `display_png()` does not accept). It now calls `display_png()`
  correctly, and only inside a Jupyter kernel.
* HTTP requests now identify themselves with an `oeis.tools` User-Agent
  instead of a browser User-Agent string. (The 0.3.0 NEWS incorrectly said
  this was already the case.)
* Network and HTTP failures now raise an informative error naming the URL,
  and `Sequence()` reports a clear error when no OEIS entry exists.

## Documentation

* Every exported function now has examples; examples that need the internet
  run only when `oeis_available()` is `TRUE`.
* Documented the return value of `plot.Sequence()`.
* New package title and description.

# oeis.tools 0.3.0

## New features

* `Sequence` gains `get_bibtex()`, `get_data_values()`, `get_graph_image()`,
  `get_graph_png()` and `get_keyword_description()`.
* `BFile` gains `get_bfile_indices()`; new `create_bfile()` helper.
* `plot_data()` supports overlaying several b-files on one plot (`p` argument)
  and returning the plot object (`return_plot`).

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
