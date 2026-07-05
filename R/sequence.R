`%||%` <- function(x, y) if (is.null(x)) y else x

.MONTH_ABBR <- c(
  "jan", "feb", "mar", "apr", "may", "jun",
  "jul", "aug", "sep", "oct", "nov", "dec"
)

#' OEIS Sequence Class
#'
#' @param oeis_id Character string (e.g., "A000045")
#'
#' @return An object of class "Sequence"
#'
#' @examples
#' \dontrun{
#' seq <- Sequence("A000045")
#' print(seq$name)
#' }
#'
#' @export
Sequence <- function(oeis_id) {
  if (!check_id(oeis_id)) {
    stop("Invalid OEIS ID: ", oeis_id)
  }

  url <- oeis_url(oeis_id, fmt = "json")
  text <- .oeis_get_text(url)
  json_data <- jsonlite::fromJSON(text, simplifyDataFrame = FALSE, simplifyVector = TRUE)
  seq_data <- json_data[[1]]

  seq <- new.env(parent = emptyenv())
  seq$id <- oeis_id
  seq$json <- seq_data

  seq$data_raw <- seq_data$data %||% ""
  seq$data <- .parse_data_values(seq$data_raw)
  seq$name <- seq_data$name %||% ""
  seq$comment <- .join_field(seq_data$comment)
  seq$reference <- .join_field(seq_data$reference)
  seq$formula <- .join_field(seq_data$formula)
  seq$example <- .join_field(seq_data$example)
  seq$maple <- .join_field(seq_data$maple)
  seq$mathematica <- .join_field(seq_data$mathematica)
  seq$program <- .join_field(seq_data$program)
  seq$xref <- .join_field(seq_data$xref)
  seq$keyword <- .parse_keywords(seq_data$keyword)
  seq$offset <- .parse_offset(seq_data$offset)
  seq$author <- .parse_authors(seq_data$author)
  seq$references <- .join_field(seq_data$references)
  seq$revision <- seq_data$revision %||% ""

  id_field <- seq_data$id %||% ""
  id_parts <- if (nzchar(id_field)) strsplit(id_field, "\\s+")[[1]] else character(0)
  seq$m_id <- if (length(id_parts) >= 1) id_parts[1] else NULL
  seq$n_id <- if (length(id_parts) >= 2) id_parts[2] else NULL

  seq$time <- .parse_oeis_datetime(seq_data$time)
  seq$created <- .parse_oeis_datetime(seq_data$created)

  seq$link <- .format_links(seq_data$link)

  seq$bfile <- BFile(oeis_id)

  class(seq) <- "Sequence"
  seq
}

#' Get B-file Information
#'
#' @param seq A Sequence object
#'
#' @return List with b-file metadata: available, filename, url, length,
#'   first, last, min, max
#'
#' @export
get_bfile_info <- function(seq) {
  UseMethod("get_bfile_info")
}

#' @export
get_bfile_info.Sequence <- function(seq) {
  bfile <- seq$bfile
  data <- get_bfile_data(bfile)

  if (is.null(data) || length(data) == 0) {
    return(list(
      available = FALSE,
      filename = get_filename(bfile),
      url = get_url(bfile),
      length = 0,
      first = NULL,
      last = NULL,
      min = NULL,
      max = NULL
    ))
  }

  list(
    available = TRUE,
    filename = get_filename(bfile),
    url = get_url(bfile),
    length = length(data),
    first = data[1],
    last = data[length(data)],
    min = min(data),
    max = max(data)
  )
}

#' Extract cross-reference IDs
#'
#' @param seq A Sequence object
#'
#' @return Character vector of unique OEIS IDs, in first-seen order
#'
#' @export
get_xref_ids <- function(seq) {
  UseMethod("get_xref_ids")
}

#' @export
get_xref_ids.Sequence <- function(seq) {
  extract_oeis_ids(seq$xref)
}

#' Download the OEIS graph image as PNG bytes
#'
#' @param seq A Sequence object
#' @param timeout Numeric timeout in seconds
#' @param use_cache Logical; reuse a previously downloaded PNG when TRUE
#'   (default)
#'
#' @return Raw vector of PNG bytes
#'
#' @export
get_graph_png <- function(seq, timeout = 10, use_cache = TRUE) {
  UseMethod("get_graph_png")
}

#' @export
get_graph_png.Sequence <- function(seq, timeout = 10, use_cache = TRUE) {
  if (isTRUE(use_cache) && !is.null(seq$.graph_png)) {
    return(seq$.graph_png)
  }

  url <- oeis_url(seq$id, fmt = "graph")
  png_bytes <- .oeis_get_raw(url, timeout = timeout)
  seq$.graph_png <- png_bytes
  png_bytes
}

#' Retrieve the OEIS graph image for display
#'
#' Uses `IRdisplay::display_png()` when running under Jupyter/IRkernel;
#' otherwise returns the raw PNG bytes.
#'
#' @param seq A Sequence object
#' @param width Optional display width in pixels
#' @param height Optional display height in pixels
#' @param timeout Numeric timeout in seconds
#' @param use_cache Logical; reuse a previously downloaded PNG when TRUE
#'
#' @return Raw vector of PNG bytes (invisibly, when displayed via IRdisplay)
#'
#' @export
get_graph_image <- function(seq, width = NULL, height = NULL, timeout = 10, use_cache = TRUE) {
  UseMethod("get_graph_image")
}

#' @export
get_graph_image.Sequence <- function(seq, width = NULL, height = NULL, timeout = 10, use_cache = TRUE) {
  png_bytes <- get_graph_png(seq, timeout = timeout, use_cache = use_cache)

  if (requireNamespace("IRdisplay", quietly = TRUE)) {
    IRdisplay::display_png(raw = png_bytes, width = width, height = height)
    return(invisible(png_bytes))
  }

  png_bytes
}

#' Return the parsed sequence data terms
#'
#' @param seq A Sequence object
#'
#' @return A `gmp::bigz` vector of terms
#'
#' @export
get_data_values <- function(seq) {
  UseMethod("get_data_values")
}

#' @export
get_data_values.Sequence <- function(seq) {
  .parse_data_values(seq$data)
}

#' Return the OEIS keyword description for a given tag
#'
#' Instance-method wrapper around [oeis_keyword_description()].
#'
#' @param seq A Sequence object
#' @param keyword_tag Character string
#'
#' @return Character string with description, or NULL
#'
#' @export
get_keyword_description <- function(seq, keyword_tag) {
  UseMethod("get_keyword_description")
}

#' @export
get_keyword_description.Sequence <- function(seq, keyword_tag) {
  oeis_keyword_description(keyword_tag)
}

#' Build a BibTeX @misc entry citing this OEIS sequence
#'
#' @param seq A Sequence object
#'
#' @return Character string with a BibTeX `@misc` entry
#'
#' @export
get_bibtex <- function(seq) {
  UseMethod("get_bibtex")
}

#' @export
get_bibtex.Sequence <- function(seq) {
  authors <- if (length(seq$author) > 0) {
    paste(seq$author, collapse = " and ")
  } else {
    "OEIS Foundation Inc."
  }

  created <- seq$created
  year <- if (!is.null(created)) format(created, "%Y", tz = "UTC") else ""
  date_str <- if (!is.null(created)) format(created, "%Y-%m-%d", tz = "UTC") else ""
  title <- if (nzchar(seq$name %||% "")) paste0(seq$id, ": ", seq$name) else seq$id

  fields <- list(
    author = paste0("{", authors, "}"),
    title = paste0("{", title, "}"),
    howpublished = "{The {O}n-{L}ine {E}ncyclopedia of {I}nteger {S}equences}",
    year = paste0("{", year, "}")
  )

  if (!is.null(created)) {
    month_index <- as.integer(format(created, "%m", tz = "UTC"))
    fields$month <- .MONTH_ABBR[month_index]
    fields$day <- sprintf("{%02d}", as.integer(format(created, "%d", tz = "UTC")))
  }

  fields$date <- paste0("{", date_str, "}")
  fields$url <- paste0("{", oeis_url(seq$id), "}")

  width <- max(nchar(names(fields)))
  body <- paste(
    sprintf("  %s = %s", formatC(names(fields), width = -width), unlist(fields)),
    collapse = ",\n"
  )

  paste0("@misc{", seq$id, ",\n", body, "\n}")
}

#' Plot Sequence Data
#'
#' Prefers the sequence's embedded b-file (richer, longer) and falls back to
#' the terms parsed from the OEIS JSON entry.
#'
#' @param x A Sequence object
#' @param ... Additional arguments passed to [plot_data()]
#'
#' @export
plot.Sequence <- function(x, ...) {
  bfile <- x$bfile
  bfile_values <- if (!is.null(bfile)) get_bfile_data(bfile) else NULL

  target <- if (!is.null(bfile_values) && length(bfile_values) > 0) {
    bfile
  } else if (!is.null(x$data) && length(x$data) > 0) {
    structure(list(oeis_id = x$id, indices = NULL, data = x$data), class = "BFile")
  } else {
    stop("No data available to plot")
  }

  plot_data(target, ...)
}

.split_field_tokens <- function(raw) {
  if (is.null(raw)) return(NULL)
  if (length(raw) > 1) return(as.character(raw))
  if (is.character(raw) && length(raw) == 1) return(strsplit(raw, ",")[[1]])
  NULL
}

.join_field <- function(x) {
  paste(x, collapse = "\n")
}

.parse_data_values <- function(data_raw) {
  if (is.null(data_raw)) return(gmp::as.bigz(integer(0)))
  if (gmp::is.bigz(data_raw)) return(data_raw)

  if (is.list(data_raw) || (is.atomic(data_raw) && length(data_raw) > 1)) {
    tokens <- vapply(seq_along(data_raw), function(i) {
      value <- data_raw[[i]]
      if (is.null(value) || length(value) == 0) return(NA_character_)
      as.character(value)[1]
    }, character(1))
  } else if (is.character(data_raw) && length(data_raw) == 1) {
    tokens <- regmatches(data_raw, gregexpr("[-+]?[0-9]+", data_raw))[[1]]
  } else {
    return(gmp::as.bigz(integer(0)))
  }

  valid <- character(0)
  for (token in tokens) {
    if (is.na(token)) next
    parsed <- suppressWarnings(gmp::as.bigz(token))
    if (!is.na(parsed)) valid <- c(valid, token)
  }

  if (length(valid) == 0) return(gmp::as.bigz(integer(0)))
  gmp::as.bigz(valid)
}

.parse_keywords <- function(keyword_raw) {
  tokens <- .split_field_tokens(keyword_raw)
  if (is.null(tokens)) return(character(0))

  keywords <- character(0)
  for (token in tokens) {
    value <- trimws(token)
    if (nzchar(value)) keywords <- c(keywords, value)
  }
  keywords
}

.parse_offset <- function(offset_raw) {
  tokens <- .split_field_tokens(offset_raw)
  if (is.null(tokens)) return(integer(0))

  offsets <- integer(0)
  for (token in tokens) {
    value <- trimws(token)
    if (!nzchar(value)) next
    parsed <- suppressWarnings(as.integer(value))
    if (!is.na(parsed)) offsets <- c(offsets, parsed)
  }
  offsets
}

.is_date_token <- function(value) {
  if (grepl("^\\d{4}$", value)) return(TRUE)

  patterns <- c(
    "^[A-Za-z]{3,9}\\.? \\d{1,2},? \\d{4}$",
    "^\\d{1,2} [A-Za-z]{3,9}\\.? \\d{4}$",
    "^\\d{4}-\\d{2}-\\d{2}$"
  )
  any(vapply(patterns, function(p) grepl(p, value), logical(1)))
}

.parse_authors <- function(author_raw) {
  tokens <- .split_field_tokens(author_raw)
  if (is.null(tokens)) return(character(0))

  authors <- character(0)
  for (chunk in tokens) {
    name <- trimws(gsub("^_+|_+$", "", trimws(chunk)))
    if (.is_date_token(name)) next
    if (nzchar(name)) authors <- c(authors, name)
  }
  authors
}

.format_links <- function(links) {
  if (is.null(links) || length(links) == 0) return("")

  formatted <- vapply(links, function(link) {
    m <- regmatches(link, regexec('<a href="([^"]*)">(.*?)</a>', link, perl = TRUE))[[1]]
    if (length(m) == 3) {
      url <- m[2]
      text <- m[3]
      if (startsWith(url, "/")) url <- paste0(OEIS_URL, url)
      paste0("[", text, "](", url, ")")
    } else {
      gsub('href="/', paste0('href="', OEIS_URL, "/"), link, fixed = TRUE)
    }
  }, character(1))

  paste(formatted, collapse = "\n")
}

.parse_oeis_datetime <- function(x) {
  if (is.null(x) || !nzchar(x)) return(NULL)

  normalized <- sub("([+-][0-9]{2}):([0-9]{2})$", "\\1\\2", x)
  normalized <- sub("Z$", "+0000", normalized)

  for (fmt in c("%Y-%m-%dT%H:%M:%S%z", "%Y-%m-%d %H:%M:%S")) {
    parsed <- as.POSIXct(normalized, format = fmt, tz = "UTC")
    if (!is.na(parsed)) return(parsed)
  }
  NULL
}

#' @export
print.Sequence <- function(x, ...) {
  cat("OEIS Sequence:", x$id, "\n")
  cat("Name:", x$name, "\n")
  invisible(x)
}
