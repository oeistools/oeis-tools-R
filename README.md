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
- 📂 **Rich Metadata**: Access comments, formulas, keywords, and cross-references directly.
- 📊 **Beautiful Visualizations**: Built-in `ggplot2` integration for instant sequence exploration.
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

## 🛠️ Requirements

- R (>= 4.1.0)
- `httr2`
- `jsonlite`
- `ggplot2`

---

Built with ❤️ for the OEIS community.
