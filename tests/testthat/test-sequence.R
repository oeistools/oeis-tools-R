.fake_get_text_for <- function(json_text, bfile_text = "") {
  function(url, timeout = 10) {
    if (grepl("fmt=json", url, fixed = TRUE)) json_text else bfile_text
  }
}

.build_seq_json <- function(fields) {
  as.character(jsonlite::toJSON(list(fields), auto_unbox = TRUE))
}

test_that("Sequence parses JSON fields, dates, links, and embeds a b-file", {
  payload <- .build_seq_json(list(
    id = "M1234 N5678",
    data = "1,1,2,3,5,8",
    name = "Fibonacci numbers",
    comment = c("First comment", "Second comment"),
    reference = c("Ref A", "Ref B"),
    formula = "a(n)=a(n-1)+a(n-2)",
    example = "a(5)=5",
    maple = "seq(fibonacci(n),n=0..10);",
    mathematica = "Table[Fibonacci[n], {n,0,10}]",
    program = "Python: ...",
    xref = "Cf. A000204",
    keyword = "nonn",
    offset = "0,2",
    author = "_Tom Verhoeff_, _N. J. A. Sloane_",
    references = "Some extra reference",
    revision = "42",
    time = "2024-01-02 03:04:05",
    created = "2000-01-01 00:00:00",
    link = c(
      '<a href="/A000045">Main entry</a>',
      '<a href="https://example.com/ref">External ref</a>',
      'See also <a href="/wiki">wiki</a>'
    )
  ))

  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))

  seq <- Sequence("A000045")

  expect_equal(seq$id, "A000045")
  expect_equal(seq$m_id, "M1234")
  expect_equal(seq$n_id, "N5678")
  expect_equal(seq$data_raw, "1,1,2,3,5,8")
  expect_equal(seq$data, gmp::as.bigz(c(1, 1, 2, 3, 5, 8)))
  expect_equal(seq$name, "Fibonacci numbers")
  expect_equal(seq$comment, "First comment\nSecond comment")
  expect_equal(seq$reference, "Ref A\nRef B")
  expect_equal(seq$author, c("Tom Verhoeff", "N. J. A. Sloane"))
  expect_equal(seq$keyword, "nonn")
  expect_equal(seq$offset, c(0L, 2L))
  expect_equal(seq$time, as.POSIXct("2024-01-02 03:04:05", tz = "UTC"))
  expect_equal(seq$created, as.POSIXct("2000-01-01 00:00:00", tz = "UTC"))
  expect_match(seq$link, "[Main entry](https://oeis.org/A000045)", fixed = TRUE)
  expect_match(seq$link, "[External ref](https://example.com/ref)", fixed = TRUE)
  expect_match(seq$link, "[wiki](https://oeis.org/wiki)", fixed = TRUE)
  expect_s3_class(seq$bfile, "BFile")
  expect_equal(seq$bfile$oeis_id, "A000045")
})

test_that("Sequence rejects an invalid OEIS id", {
  expect_error(Sequence("invalid-id"), "Invalid OEIS ID")
})

test_that("Sequence propagates HTTP errors from the JSON endpoint", {
  testthat::local_mocked_bindings(
    .oeis_get_text = function(url, timeout = 10) stop("request failed")
  )

  expect_error(Sequence("A000001"), "request failed")
})

test_that("Sequence author parsing drops trailing year tokens", {
  payload <- .build_seq_json(list(id = "M0001 N0001", author = "_N. J. A. Sloane_, 1964"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))

  seq <- Sequence("A000001")
  expect_equal(seq$author, "N. J. A. Sloane")
})

test_that("Sequence author parsing drops trailing full-date tokens", {
  payload <- .build_seq_json(list(id = "M0001 N0001", author = "_Pierre CAMI_, Apr 28 2012"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))

  seq <- Sequence("A000001")
  expect_equal(seq$author, "Pierre CAMI")
})

test_that("Sequence offset parsing ignores invalid tokens", {
  payload <- .build_seq_json(list(id = "M0001 N0001", offset = "1, bad, -3"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))

  seq <- Sequence("A000001")
  expect_equal(seq$offset, c(1L, -3L))
})

test_that("Sequence keyword parsing splits and drops empty tokens", {
  payload <- .build_seq_json(list(id = "M0001 N0001", keyword = "nonn, easy, ,look"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))

  seq <- Sequence("A000001")
  expect_equal(seq$keyword, c("nonn", "easy", "look"))
})

test_that("get_bfile_info reports stats when b-file data is available", {
  payload <- .build_seq_json(list(id = "M0001 N0001"))
  testthat::local_mocked_bindings(
    .oeis_get_text = .fake_get_text_for(payload, bfile_text = "0 0\n1 1\n2 1\n3 2\n4 3\n")
  )

  seq <- Sequence("A000001")
  info <- get_bfile_info(seq)

  expect_true(info$available)
  expect_equal(info$length, 5)
  expect_equal(info$first, gmp::as.bigz(0))
  expect_equal(info$last, gmp::as.bigz(3))
  expect_equal(info$min, gmp::as.bigz(0))
  expect_equal(info$max, gmp::as.bigz(3))
})

test_that("get_bfile_info reports unavailable when b-file data is missing", {
  payload <- .build_seq_json(list(id = "M0001 N0001"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload, bfile_text = ""))

  seq <- Sequence("A000001")
  info <- get_bfile_info(seq)

  expect_false(info$available)
  expect_equal(info$length, 0)
  expect_null(info$first)
  expect_null(info$last)
  expect_null(info$min)
  expect_null(info$max)
})

test_that("get_xref_ids extracts unique OEIS ids in first-seen order", {
  payload <- .build_seq_json(list(
    id = "M0001 N0001",
    xref = c(
      "Essentially the partial sums of A001468.",
      "Cf. A000201, A001622, A003622.",
      "Cf. A004919, A004920, A000201."
    )
  ))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))

  seq <- Sequence("A000001")
  expect_equal(
    get_xref_ids(seq),
    c("A001468", "A000201", "A001622", "A003622", "A004919", "A004920")
  )
})

test_that("get_data_values re-parses whatever is currently in $data", {
  payload <- .build_seq_json(list(id = "M0001 N0001"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))
  seq <- Sequence("A000001")

  seq$data <- "1,2,3,5,8,13"
  expect_equal(get_data_values(seq), gmp::as.bigz(c(1, 2, 3, 5, 8, 13)))

  seq$data <- list(1, "abc", NULL, 5)
  expect_equal(get_data_values(seq), gmp::as.bigz(c(1, 5)))

  seq$data <- 12345
  expect_equal(get_data_values(seq), gmp::as.bigz(integer(0)))
})

test_that("get_keyword_description resolves through the instance method", {
  payload <- .build_seq_json(list(id = "M0001 N0001", keyword = "nonn, easy"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))
  seq <- Sequence("A000001")

  expect_equal(
    get_keyword_description(seq, "nonn"),
    "Displayed terms are nonnegative (later terms may still become negative)."
  )
  expect_equal(get_keyword_description(seq, "  EASY "), "It is easy to produce terms of this sequence.")
  expect_null(get_keyword_description(seq, "missing"))
})

test_that("get_graph_png downloads once and caches by default", {
  payload <- .build_seq_json(list(id = "M0001 N0001"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))
  seq <- Sequence("A000001")

  calls <- 0L
  png_bytes <- as.raw(c(0x89, 0x50, 0x4e, 0x47))
  testthat::local_mocked_bindings(
    .oeis_get_raw = function(url, timeout = 10) {
      calls <<- calls + 1L
      png_bytes
    }
  )

  expect_equal(get_graph_png(seq), png_bytes)
  expect_equal(get_graph_png(seq), png_bytes)
  expect_equal(calls, 1L)
})

test_that("get_graph_png bypasses the cache when use_cache = FALSE", {
  payload <- .build_seq_json(list(id = "M0001 N0001"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))
  seq <- Sequence("A000001")

  calls <- 0L
  testthat::local_mocked_bindings(
    .oeis_get_raw = function(url, timeout = 10) {
      calls <<- calls + 1L
      as.raw(calls)
    }
  )

  get_graph_png(seq, use_cache = FALSE)
  get_graph_png(seq, use_cache = FALSE)
  expect_equal(calls, 2L)
})

test_that("link parsing falls back to href substitution when there is no anchor tag", {
  payload <- .build_seq_json(list(
    id = "M0001 N0001",
    link = 'See href="/wiki/Fibonacci" for details'
  ))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))

  seq <- Sequence("A000001")
  expect_match(seq$link, 'href="https://oeis.org/wiki/Fibonacci"', fixed = TRUE)
})

test_that("get_bibtex includes authors, creation date, title, and url", {
  payload <- .build_seq_json(list(
    id = "M1234 N5678",
    name = "Fibonacci numbers",
    author = "_Tom Verhoeff_, _N. J. A. Sloane_",
    created = "2000-01-01 00:00:00"
  ))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))

  seq <- Sequence("A000045")
  bibtex <- get_bibtex(seq)

  expect_true(startsWith(bibtex, "@misc{A000045,"))
  expect_match(bibtex, "author       = {Tom Verhoeff and N. J. A. Sloane}", fixed = TRUE)
  expect_match(bibtex, "title        = {A000045: Fibonacci numbers}", fixed = TRUE)
  expect_match(
    bibtex,
    "howpublished = {The {O}n-{L}ine {E}ncyclopedia of {I}nteger {S}equences}",
    fixed = TRUE
  )
  expect_match(bibtex, "year         = {2000}", fixed = TRUE)
  expect_match(bibtex, "month        = jan", fixed = TRUE)
  expect_match(bibtex, "day          = {01}", fixed = TRUE)
  expect_match(bibtex, "date         = {2000-01-01}", fixed = TRUE)
  expect_match(bibtex, "url          = {https://oeis.org/A000045}", fixed = TRUE)
})

test_that("get_bibtex falls back gracefully without authors or a creation date", {
  payload <- .build_seq_json(list(id = "M0001 N0001"))
  testthat::local_mocked_bindings(.oeis_get_text = .fake_get_text_for(payload))

  seq <- Sequence("A000001")
  bibtex <- get_bibtex(seq)

  expect_match(bibtex, "author       = {OEIS Foundation Inc.}", fixed = TRUE)
  expect_match(bibtex, "title        = {A000001}", fixed = TRUE)
  expect_match(bibtex, "year         = {}", fixed = TRUE)
  expect_false(grepl("month", bibtex, fixed = TRUE))
  expect_match(bibtex, "date         = {}", fixed = TRUE)
  expect_match(bibtex, "url          = {https://oeis.org/A000001}", fixed = TRUE)
})

test_that(".parse_data_values handles list input and skips unconvertible tokens", {
  expect_equal(.parse_data_values(list("1", "2", "3")), gmp::as.bigz(c(1, 2, 3)))
  expect_equal(.parse_data_values(NULL), gmp::as.bigz(integer(0)))
  expect_equal(.parse_data_values(42), gmp::as.bigz(integer(0)))
  expect_equal(.parse_data_values(list("1", "abc", NULL, "5")), gmp::as.bigz(c(1, 5)))
  expect_equal(
    .parse_data_values("-2, -1, 0, 1, 2, ..., bad"),
    gmp::as.bigz(c(-2, -1, 0, 1, 2))
  )
})

test_that(".parse_authors handles list input and rejects non-standard input", {
  expect_equal(.parse_authors(c("_Alice_", "_Bob_")), c("Alice", "Bob"))
  expect_equal(.parse_authors(NULL), character(0))
  expect_equal(.parse_authors(42), character(0))
})

test_that(".parse_offset handles list input and rejects non-standard input", {
  expect_equal(.parse_offset(c(0, 2)), c(0L, 2L))
  expect_equal(.parse_offset(NULL), integer(0))
  expect_equal(.parse_offset(42), integer(0))
})

test_that(".parse_keywords handles list input and rejects non-standard input", {
  expect_equal(.parse_keywords(c("nonn", "easy")), c("nonn", "easy"))
  expect_equal(.parse_keywords(NULL), character(0))
  expect_equal(.parse_keywords(42), character(0))
})

test_that("plot.Sequence prefers the embedded b-file and falls back to $data", {
  payload <- .build_seq_json(list(id = "M0001 N0001", data = "1,1,2,3,5,8"))
  testthat::local_mocked_bindings(
    .oeis_get_text = .fake_get_text_for(payload, bfile_text = "0 1\n1 1\n2 2\n3 3\n4 5\n5 8\n6 13\n")
  )
  seq <- Sequence("A000045")

  p <- plot(seq, show = FALSE, return_plot = TRUE)
  expect_equal(length(p$layers[[1]]$data$y), 7)

  seq$bfile <- structure(list(oeis_id = seq$id, indices = NULL, data = NULL), class = "BFile")
  p2 <- plot(seq, show = FALSE, return_plot = TRUE)
  expect_equal(length(p2$layers[[1]]$data$y), 6)
})
