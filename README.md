# oeis.tools 🌀

[![R-CMD-check](https://github.com/oeistools/oeis-tools-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/oeistools/oeis-tools-R/actions/workflows/R-CMD-check.yaml)
[![lint](https://github.com/oeistools/oeis-tools-R/actions/workflows/lint.yaml/badge.svg)](https://github.com/oeistools/oeis-tools-R/actions/workflows/lint.yaml)
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#maturing)
[![R-version](https://img.shields.io/badge/R-%3E%3D%204.1.0-blue.svg)](https://cran.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/oeistools/oeis-tools-R.svg)](https://github.com/oeistools/oeis-tools-R/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/oeistools/oeis-tools-R.svg)](https://github.com/oeistools/oeis-tools-R/commits/main)

**oeis.tools** is a premium, high-performance R toolkit for interacting with the [Online Encyclopedia of Integer Sequences (OEIS)](https://oeis.org). 

Designed for both speed and ease of use, it provides a modern object-oriented interface to fetch sequence metadata, parse extensive b-files, and visualize integer sequences with beautiful, publication-ready plots.

## ✨ Features

- 🚀 **Fast B-file Parsing**: Highly optimized parsing of OEIS b-files using efficient R internals.
- 🔢 **Arbitrary Precision**: Sequence and b-file terms are stored as `gmp::bigz` values, so terms with hundreds of digits are never truncated.
- 📂 **Rich Metadata**: Access comments, formulas, keywords, cross-references, authors, dates, and links directly.
- 📊 **Beautiful Visualizations**: Built-in `ggplot2` integration, with automatic log10-magnitude scaling for extreme values.
- 📝 **Citable**: Generate a ready-to-use BibTeX entry for any sequence with `get_bibtex()`.
- 🖼️ **Graph Images**: Download (and cache) the OEIS-rendered graph for a sequence with `get_graph_png()`/`get_graph_image()`.
- ✍️ **B-file Creation**: Write your own sequence values out to a standard b-file with `create_bfile()`.
- 🛠️ **Developer Friendly**: Clean, documented API with full support for `httr2` and `jsonlite`.

## 🚀 Installation

You can install the development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("oeistools/oeis-tools-R")
```

## 📖 Quick Start

### Fetch a Sequence

```r
library(oeis.tools)

# Fetch the famous Fibonacci sequence
fib <- Sequence("A000045")

print(fib$name)
# [1] "Fibonacci numbers: F(n) = F(n-1) + F(n-2) with F(0) = 0 and F(1) = 1."

# Access metadata
print(fib$keywords)
# [1] "core" "nonn" "nice" "easy" "look" "hear" "changed"
```

### Plot B-file Data

B-files often contain thousands of terms. `oeis.tools` handles them with ease:

```r
# Fetch and plot the first 1000 terms of the Prime numbers (A000040)
primes <- BFile("A000040")
plot_data(primes, n = 1000, color = "royalblue")
```

### Extract Cross-References

Find related sequences effortlessly:

```r
get_xref_ids(fib)
# [1] "A000032" "A000071" "A000108" ...
```

### Cite a Sequence

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

### Create a B-file

```r
create_bfile("A999999", data = c(1, 1, 2, 3, 5, 8), offset = 0)
# [1] "b999999.txt"
```

## 🛠️ Requirements

- R (>= 4.1.0)
- `httr2`
- `jsonlite`
- `ggplot2`
- `gmp`

---

Built with ❤️ for the OEIS community.
