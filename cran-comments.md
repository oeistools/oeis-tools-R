## Submission

This is a new submission.

`oeis.tools` provides programmatic access to the On-Line Encyclopedia of
Integer Sequences (OEIS, <https://oeis.org>): it downloads sequence metadata
and b-files, stores terms as arbitrary-precision integers ('gmp'), and plots
them with 'ggplot2'.

## Test environments

* Local: Ubuntu Linux, R 4.5.2
* GitHub Actions: Ubuntu 24.04, R 4.6.1 (OEIS unreachable: online examples skipped)
* mac builder: macOS Tahoe 26.6 (aarch64), R 4.6.1 Patched -- OK, 0 notes
* win-builder: Windows (x86_64-w64-mingw32), R-devel (2026-09-25 r90590 ucrt) -- 1 NOTE (see below)

## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Enrique Pérez Herrero <energycode.org@gmail.com>'
  New submission

  This is a new submission.

  Possibly misspelled words in DESCRIPTION: OEIS

  This is not a misspelling: OEIS is the standard acronym of the On-Line
  Encyclopedia of Integer Sequences, which is spelled out in the Description.

## Internet access

The package accesses the OEIS web service. Tests use mocked HTTP responses and
never touch the network, and the vignette chunks that need the network are not
evaluated. Examples that need the internet use `@examplesIf oeis_available()`,
so they are skipped when the OEIS cannot be reached. (The OEIS returns
HTTP 403 to some cloud hosts, e.g. GitHub Actions runners.)
Network failures produce an informative error (or, for b-files, a warning
and an empty object) rather than an uncaught failure.

Requests identify themselves with the User-Agent
"oeis.tools R package (https://github.com/oeistools/oeis-tools-R)".

## Files written

The package writes to disk only in `create_bfile()`, which requires the user
to supply `output_path`. Its example writes to `tempdir()` and removes the
file afterwards.
