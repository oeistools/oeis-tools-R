test_that("BFile constructor rejects an invalid id", {
  expect_error(BFile("invalid"), "Invalid OEIS ID")
})

test_that("BFile parses numeric values and exposes metadata", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) {
      expect_match(url, "A000045")
      "# comment\n0 0\n1 1\n2 1\n3 2\n"
    }
  )

  bfile <- BFile("A000045")

  expect_equal(get_filename(bfile), "b000045.txt")
  expect_equal(get_url(bfile), "https://oeis.org/A000045/b000045.txt")
  expect_equal(get_bfile_data(bfile), gmp::as.bigz(c(0, 1, 1, 2)))
  expect_equal(get_bfile_indices(bfile), c(0L, 1L, 2L, 3L))
})

test_that("BFile data is NULL when the request fails", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) stop("network error")
  )

  expect_warning(BFile("A000045"), "Failed to fetch or parse b-file")
  bfile <- suppressWarnings(BFile("A000045"))
  expect_null(get_bfile_data(bfile))
  expect_null(get_bfile_indices(bfile))
})

test_that("BFile data is NULL for a malformed line", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) "0 0\nthis-is-not-valid\n"
  )

  bfile <- BFile("A000045")
  expect_null(get_bfile_data(bfile))
})

test_that("create_bfile writes to the working directory by default", {
  dir <- withr::local_tempdir()
  withr::local_dir(dir)

  result <- create_bfile("A123456", c(10, 20))

  expect_equal(result, "b123456.txt")
  expect_equal(readLines(result), c("1 10", "2 20"))
})

test_that("create_bfile writes into a directory when output_path is a dir", {
  dir <- withr::local_tempdir()

  result <- create_bfile("A123456", c(5, 6), offset = 0, output_path = dir)

  expect_equal(result, file.path(dir, "b123456.txt"))
  expect_equal(readLines(result), c("0 5", "1 6"))
})

test_that("create_bfile writes to an exact path", {
  dir <- withr::local_tempdir()
  exact_file <- file.path(dir, "my_custom.txt")

  result <- create_bfile("A123456", c(100), output_path = exact_file)

  expect_equal(result, exact_file)
  expect_equal(readLines(result), "1 100")
})

test_that("create_bfile handles arbitrary-precision values", {
  dir <- withr::local_tempdir()
  huge <- gmp::as.bigz(paste0("1", strrep("0", 40)))

  result <- create_bfile("A123456", huge, output_path = dir)

  expect_equal(readLines(result), paste("1", as.character(huge)))
})

test_that("plot_data plots values with a line by default", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) "0 2\n1 3\n2 5\n"
  )
  bfile <- BFile("A000045")

  p <- plot_data(bfile, show = FALSE, return_plot = TRUE, color = "black")

  expect_s3_class(p$layers[[1]]$geom, "GeomLine")
  expect_equal(p$layers[[1]]$data$x, c(0, 1, 2))
  expect_equal(p$layers[[1]]$data$y, c(2, 3, 5))
  expect_equal(p$layers[[1]]$aes_params$colour, "black")
  expect_equal(p$labels$title, "A000045 b-file data")
  expect_equal(p$labels$x, "n")
  expect_equal(p$labels$y, "A000045(n)")
})

test_that("plot_data falls back to a plain index when indices are unavailable", {
  fallback_bfile <- structure(
    list(oeis_id = "A000045", indices = NULL, data = gmp::as.bigz(c(2, 3, 5))),
    class = "BFile"
  )

  p <- plot_data(fallback_bfile, show = FALSE, return_plot = TRUE)

  expect_equal(p$layers[[1]]$data$x, c(0, 1, 2))
  expect_equal(p$labels$x, "Index")
})

test_that("plot_data uses scatter geom when requested", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) "0 2\n1 3\n2 5\n"
  )
  bfile <- BFile("A000045")

  p <- plot_data(bfile, show = FALSE, return_plot = TRUE, plot_style = "scatter")

  expect_s3_class(p$layers[[1]]$geom, "GeomPoint")
})

test_that("plot_data treats 'joined' as an alias for 'line'", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) "0 2\n"
  )
  bfile <- BFile("A000045")

  p <- plot_data(bfile, show = FALSE, return_plot = TRUE, plot_style = "joined")

  expect_s3_class(p$layers[[1]]$geom, "GeomLine")
})

test_that("plot_data accepts n to plot only a prefix", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) "10 2\n20 3\n40 5\n80 8\n"
  )
  bfile <- BFile("A000045")

  p <- plot_data(bfile, n = 2, show = FALSE, return_plot = TRUE)

  expect_equal(p$layers[[1]]$data$x, c(10, 20))
  expect_equal(p$layers[[1]]$data$y, c(2, 3))
})

test_that("plot_data validates n and plot_style", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) "0 2\n1 3\n"
  )
  bfile <- BFile("A000045")

  expect_error(plot_data(bfile, n = "2", show = FALSE), "n must be an integer or NULL")
  expect_error(plot_data(bfile, n = -1, show = FALSE), "n must be non-negative")
  expect_error(plot_data(bfile, plot_style = "invalid", show = FALSE), "plot_style must be one of")
})

test_that("plot_data raises when no b-file data is available", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) stop("network error")
  )

  bfile <- suppressWarnings(BFile("A000045"))
  expect_error(plot_data(bfile, show = FALSE), "No b-file data available to plot")
})

test_that("plot_data falls back to signed log10 magnitude for values beyond double range", {
  huge <- paste0("1", strrep("0", 400))
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) paste0("0 0\n1 2\n2 -3\n3 ", huge, "\n")
  )
  bfile <- BFile("A000045")

  p <- plot_data(bfile, show = FALSE, return_plot = TRUE)

  expect_equal(
    p$layers[[1]]$data$y,
    c(0, log10(2), -log10(3), 400),
    tolerance = 1e-6
  )
  expect_equal(p$labels$title, "A000045 b-file data (log10 magnitude)")
  expect_equal(p$labels$y, "sign(value) * log10(|value|)")
})

test_that("plot_data combines titles when layering onto an existing plot", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) "0 2\n1 3\n"
  )
  first <- BFile("A000045")
  base_plot <- plot_data(first, show = FALSE, return_plot = TRUE)

  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) "0 5\n1 8\n"
  )
  second <- BFile("A000032")
  combined <- plot_data(second, show = FALSE, return_plot = TRUE, p = base_plot)

  expect_equal(combined$labels$title, "A000045 + A000032 b-file data")
  expect_length(combined$layers, 2)
})
