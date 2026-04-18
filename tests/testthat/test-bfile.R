test_that("BFile constructor handles invalid ID", {
  expect_error(BFile("invalid"))
})

test_that("BFile accessor methods work", {
  # Mock a BFile object
  bf <- structure(
    list(
      oeis_id = "A000045",
      filename = "b000045.txt",
      url = "https://oeis.org/A000045/b000045.txt",
      data = c(0, 1, 1, 2)
    ),
    class = "BFile"
  )
  
  expect_equal(get_filename(bf), "b000045.txt")
  expect_equal(get_url(bf), "https://oeis.org/A000045/b000045.txt")
  expect_equal(get_bfile_data(bf), c(0, 1, 1, 2))
})

test_that("plot_data fails on empty data", {
  bf_empty <- structure(list(data = NULL), class = "BFile")
  expect_error(plot_data(bf_empty))
})
