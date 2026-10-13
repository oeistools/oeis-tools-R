# oeis.tools plan

## Status

- **0.3.1 accepted on CRAN** (first release; submitted 2026-09-26 from commit
  `69a2a93`, tag `v0.3.1`). README now carries CRAN badges and
  `install.packages("oeis.tools")`.
- GitHub release `v0.3.1` published 2026-10-13.

## Next steps

### Next version (0.3.2 or later)

- Remove `lintr` from `Suggests` in DESCRIPTION. Nothing in `R/`, `tests/` or
  `vignettes/` uses it; only the lint workflow does, and that installs it
  separately (`extra-packages: any::lintr`).
- Tidy the stray blank line between bullets in the 0.3.0 "Documentation"
  section of `NEWS.md`.
