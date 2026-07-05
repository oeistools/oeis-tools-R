test_that("check_id accepts valid OEIS ids", {
  expect_true(check_id("A000045"))
})

test_that("check_id rejects invalid OEIS ids", {
  expect_false(check_id("A12345"))
  expect_false(check_id("B000001"))
  expect_false(check_id("A0000012"))
  expect_false(check_id("A12ABC"))
})

test_that("check_id rejects non-character values", {
  expect_false(check_id(NULL))
  expect_false(check_id(12345))
})

test_that("oeis_bfile builds the expected filename", {
  expect_equal(oeis_bfile("A000045"), "b000045.txt")
})

test_that("oeis_bfile raises for an invalid id", {
  expect_error(oeis_bfile("A123"), "Invalid OEIS ID")
})

test_that("oeis_url builds supported formats", {
  expect_equal(oeis_url("A000001"), paste0(OEIS_URL, "/A000001"))
  expect_equal(oeis_url("A000001", fmt = "json"), paste0(OEIS_URL, "/search?q=id:A000001&fmt=json"))
  expect_equal(oeis_url("A000001", fmt = "text"), paste0(OEIS_URL, "/search?q=id:A000001&fmt=text"))
  expect_equal(oeis_url("A000001", fmt = "bfile"), paste0(OEIS_URL, "/A000001/b000001.txt"))
  expect_equal(oeis_url("A000001", fmt = "graph"), paste0(OEIS_URL, "/A000001/graph?png=1"))
})

test_that("oeis_url normalizes format strings", {
  expect_equal(
    oeis_url("A000001", fmt = " JSON "),
    paste0(OEIS_URL, "/search?q=id:A000001&fmt=json")
  )
})

test_that("oeis_url falls back to the default url for an unknown format", {
  expect_equal(oeis_url("A000001", fmt = "unknown"), paste0(OEIS_URL, "/A000001"))
})

test_that("oeis_keyword_description returns the expected description", {
  expect_equal(
    oeis_keyword_description("nonn"),
    "Displayed terms are nonnegative (later terms may still become negative)."
  )
})

test_that("oeis_keyword_description normalizes case/whitespace and handles unknown tags", {
  expect_equal(oeis_keyword_description("  EASY  "), "It is easy to produce terms of this sequence.")
  expect_null(oeis_keyword_description("not-a-tag"))
  expect_null(oeis_keyword_description(""))
})

test_that("oeis_keyword_description returns NULL for NULL input", {
  expect_null(oeis_keyword_description(NULL))
})

test_that("extract_oeis_ids finds unique ids in first-seen order", {
  text <- "Check A000045 and A000001, also A000045 again"
  expect_equal(extract_oeis_ids(text), c("A000045", "A000001"))
  expect_equal(length(extract_oeis_ids("no IDs here")), 0)
  expect_equal(length(extract_oeis_ids(NULL)), 0)
})

test_that(".safe_log10_abs matches ordinary log10 within double range", {
  expect_equal(.safe_log10_abs(gmp::as.bigz(2)), log10(2), tolerance = 1e-6)
  expect_equal(.safe_log10_abs(gmp::as.bigz(-3)), log10(3), tolerance = 1e-6)
})

test_that(".safe_log10_abs approximates magnitude for values beyond double range", {
  huge <- gmp::as.bigz(paste0("1", strrep("0", 400)))
  expect_equal(.safe_log10_abs(huge), 400, tolerance = 1e-6)
})
