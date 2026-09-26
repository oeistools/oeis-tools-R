## Submission

This is a new submission.

`oeis.tools` provides programmatic access to the On-Line Encyclopedia of
Integer Sequences (OEIS, <https://oeis.org>): it downloads sequence metadata
and b-files, stores terms as arbitrary-precision integers ('gmp'), and plots
them with 'ggplot2'.

## Test environments

* Local: Ubuntu Linux, R release
* GitHub Actions: ubuntu-latest, R release

## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Enrique Pérez Herrero <energycode.org@gmail.com>'
  New submission

  This is a new submission.

## Internet access

The package accesses the OEIS web service. Tests use mocked HTTP responses and
never touch the network, and the vignette chunks that need the network are not
evaluated. Examples that need the internet are wrapped in `\donttest{}`.
Network failures produce an informative error (or, for b-files, a warning
and an empty object) rather than an uncaught failure.

Requests identify themselves with the User-Agent
"oeis.tools R package (https://github.com/oeistools/oeis-tools-R)".

## Files written

The package writes to disk only in `create_bfile()`, which requires the user
to supply `output_path`. Its example writes to `tempdir()` and removes the
file afterwards.
