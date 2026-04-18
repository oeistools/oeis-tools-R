test_that("check_id works correctly", {
  expect_true(check_id("A000045"))
  expect_false(check_id("invalid"))
  expect_false(check_id("A123"))
  expect_false(check_id("B000045"))
})

test_that("oeis_bfile works correctly", {
  expect_equal(oeis_bfile("A000045"), "b000045.txt")
  expect_error(oeis_bfile("invalid"))
})

test_that("oeis_url works correctly", {
  expect_match(oeis_url("A000045"), "oeis.org/A000045")
  expect_match(oeis_url("A000045", fmt = "json"), "fmt=json")
  expect_match(oeis_url("A000045", fmt = "bfile"), "b000045.txt")
})

test_that("oeis_keyword_description works", {
  expect_match(oeis_keyword_description("core"), "fundamental")
  expect_null(oeis_keyword_description(NULL))
  expect_null(oeis_keyword_description(""))
})

test_that("extract_oeis_ids works", {
  text <- "Check A000045 and A000001"
  expect_equal(extract_oeis_ids(text), c("A000045", "A000001"))
  expect_equal(length(extract_oeis_ids("no IDs here")), 0)
})
