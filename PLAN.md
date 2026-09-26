# oeis.tools plan

## Status

- **0.3.1 submitted to CRAN on 2026-09-26** (first submission), from commit
  `69a2a93`; tag `v0.3.1` points at that commit.
- **CRAN pretests passed (2026-09-26):** Windows and Debian r-devel, 1 NOTE
  each (the expected one below); examples ran against OEIS on both. Now
  **pending manual inspection**: CRAN says a team member typically responds
  within 10 working days (by about 2026-10-10). Logs (kept ~7 days):
  <https://win-builder.r-project.org/incoming_pretest/oeis.tools_0.3.1_20260926_120447/>
- Pre-submission checks: 0 errors, 0 warnings. Only NOTE: "New submission"
  plus "possibly misspelled: OEIS" (false positive, explained in
  `cran-comments.md`).
  - Local Ubuntu, R 4.5.2
  - GitHub Actions, Ubuntu 24.04, R 4.6.1 (online examples skipped: OEIS
    returns HTTP 403 to GitHub runners)
  - mac builder, macOS Tahoe 26.6, R 4.6.1 Patched: OK, 0 notes
  - win-builder, R-devel 2026-09-25 r90590: 1 NOTE (above)

## Next steps

### If CRAN requests changes

1. Make the fixes and bump the version to 0.3.2.
2. Add a 0.3.2 entry to `NEWS.md`.
3. Update `cran-comments.md`: open with "This is a resubmission", list each
   reviewer point and how it was addressed, then refresh the test results.
4. Re-run `devtools::check_win_devel()` (and `check_mac_release()`).
5. Resubmit with `devtools::submit_cran()`.

### When CRAN accepts 0.3.1

- Run `usethis::use_github_release()`. It creates the GitHub release for
  `v0.3.1` from `NEWS.md` and deletes `CRAN-SUBMISSION`.

### Next version (0.3.2 or later)

- Remove `lintr` from `Suggests` in DESCRIPTION. Nothing in `R/`, `tests/` or
  `vignettes/` uses it; only the lint workflow does, and that installs it
  separately (`extra-packages: any::lintr`). Do it in any resubmission, or in
  the next release otherwise.
- Tidy the stray blank line between bullets in the 0.3.0 "Documentation"
  section of `NEWS.md`.
