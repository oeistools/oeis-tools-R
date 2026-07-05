# oeis.tools

[![R-CMD-check](https://github.com/oeistools/oeis-tools-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/oeistools/oeis-tools-R/actions/workflows/R-CMD-check.yaml)
[![lint](https://github.com/oeistools/oeis-tools-R/actions/workflows/lint.yaml/badge.svg)](https://github.com/oeistools/oeis-tools-R/actions/workflows/lint.yaml)
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#maturing)
[![R-version](https://img.shields.io/badge/R-%3E%3D%204.1.0-blue.svg)](https://cran.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/oeistools/oeis-tools-R.svg)](https://github.com/oeistools/oeis-tools-R/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/oeistools/oeis-tools-R.svg)](https://github.com/oeistools/oeis-tools-R/commits/main)

R interface to the [Online Encyclopedia of Integer Sequences (OEIS)](https://oeis.org). Fetches sequence metadata and b-files, parses them into S3 objects (`Sequence`, `BFile`), and plots terms with `ggplot2`. Terms are stored as `gmp::bigz` values, so precision is not lost for sequences whose terms exceed double-precision range.

R port of [oeis-tools](https://github.com/oeistools/oeis-tools) (Python).

## Installation

```r
# install.packages("devtools")
devtools::install_github("oeistools/oeis-tools-R")
```

## Usage

### Sequence metadata

```r
library(oeis.tools)

fib <- Sequence("A000045")

fib$name
# [1] "Fibonacci numbers: F(n) = F(n-1) + F(n-2) with F(0) = 0 and F(1) = 1."

fib$keyword
# [1] "core" "nonn" "nice" "easy" "look" "hear" "changed"

fib$author
# [1] "N. J. A. Sloane"

fib$data
# gmp bigz vector of the terms given in the OEIS entry
```

`Sequence` also exposes `data_raw`, `offset`, `comment`, `reference`, `formula`, `example`, `maple`, `mathematica`, `program`, `xref`, `references`, `revision`, `m_id`, `n_id`, `time`, `created`, `link` (OEIS `link` field reformatted to Markdown), and `bfile` (an embedded `BFile`).

### B-files

B-files contain more terms than the main entry (often thousands).

```r
primes <- BFile("A000040")
get_bfile_data(primes)[1:10]
get_bfile_indices(primes)[1:10]

plot_data(primes, n = 1000, color = "royalblue")
```

`plot_data()` accepts `plot_style = "line" | "joined" | "scatter"`, `p` to layer onto an existing `ggplot` object, and `return_plot = TRUE` to get the object back instead of (or in addition to) printing it. When a term exceeds double-precision range, the plot falls back to a signed `log10(|value|)` axis rather than truncating or erroring.

```r
create_bfile("A999999", data = c(1, 1, 2, 3, 5, 8), offset = 0)
# [1] "b999999.txt"
```

### Cross-references and keywords

```r
get_xref_ids(fib)
# [1] "A000032" "A000071" "A000108" ...

oeis_keyword_description("core")
# [1] "A fundamental sequence."
```

### Graph image

```r
png_bytes <- get_graph_png(fib)  # cached after first call
get_graph_image(fib)             # displays inline under IRkernel; else returns raw bytes
```

### BibTeX citation

```r
cat(get_bibtex(fib))
# @misc{A000045,
#   author       = {N. J. A. Sloane},
#   title        = {A000045: Fibonacci numbers: F(n) = F(n-1) + F(n-2) with F(0) = 0 and F(1) = 1.},
#   howpublished = {The {O}n-{L}ine {E}ncyclopedia of {I}nteger {S}equences},
#   year         = {1991},
#   month        = apr,
#   day          = {30},
#   date         = {1991-04-30},
#   url          = {https://oeis.org/A000045}
# }
```

## API summary

| Function | Applies to | Description |
|---|---|---|
| `Sequence(oeis_id)` | — | Fetch and parse an OEIS entry from the JSON API |
| `BFile(oeis_id)` | — | Fetch and parse a b-file |
| `create_bfile(oeis_id, data, offset, output_path)` | — | Write a b-file to disk |
| `check_id(oeis_id)` | — | Validate an OEIS id (`^A\d{6}$`) |
| `oeis_url(oeis_id, fmt)` | — | Build an OEIS URL (`json`, `text`, `bfile`, `graph`) |
| `oeis_bfile(oeis_id)` | — | Build a b-file filename |
| `oeis_keyword_description(tag)` | — | Look up an OEIS keyword tag description |
| `extract_oeis_ids(text)` | — | Extract `A\d{6}` ids from text |
| `get_bfile_data`, `get_bfile_indices`, `get_filename`, `get_url` | `BFile` | Accessors |
| `get_bfile_info`, `get_xref_ids`, `get_data_values`, `get_keyword_description`, `get_graph_png`, `get_graph_image`, `get_bibtex` | `Sequence` | Derived metadata |
| `plot_data(x, ...)` | `BFile` | ggplot2 line/scatter plot |
| `plot(x, ...)` | `Sequence` | Delegates to `plot_data` on the embedded `BFile` |

## Requirements

- R (>= 4.1.0)
- `httr2`
- `jsonlite`
- `ggplot2`
- `gmp`
