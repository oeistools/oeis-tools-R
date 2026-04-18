test_that("parse_data_values works", {
  # Numeric
  expect_equal(parse_data_values(c(1, 2, 3)), c(1L, 2L, 3L))
  # String
  expect_equal(parse_data_values("1,2,3"), c(1L, 2L, 3L))
  expect_equal(length(parse_data_values(NULL)), 0)
})

test_that("Sequence constructor handles invalid ID", {
  expect_error(Sequence("invalid"))
})

# We won't test the actual network call here
# to avoid dependency on OEIS being up/internet
