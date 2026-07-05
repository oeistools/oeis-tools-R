#' OEIS B-file Class
#'
#' @param oeis_id Character string (e.g., "A000045")
#'
#' @return An object of class "BFile"
#'
#' @export
BFile <- function(oeis_id) {
  if (!check_id(oeis_id)) {
    stop("Invalid OEIS ID: ", oeis_id)
  }

  filename <- oeis_bfile(oeis_id)
  url <- oeis_url(oeis_id, fmt = "bfile")
  parsed <- fetch_bfile_data(url)

  bfile <- new.env(parent = emptyenv())
  bfile$oeis_id <- oeis_id
  bfile$filename <- filename
  bfile$url <- url
  bfile$indices <- parsed$indices
  bfile$data <- parsed$data
  class(bfile) <- "BFile"

  bfile
}

#' Get B-file Filename
#'
#' @param bfile A BFile object
#'
#' @return Character string
#'
#' @export
get_filename <- function(bfile) {
  UseMethod("get_filename")
}

#' @export
get_filename.BFile <- function(bfile) {
  bfile$filename
}

#' Get B-file URL
#'
#' @param bfile A BFile object
#'
#' @return Character string
#'
#' @export
get_url <- function(bfile) {
  UseMethod("get_url")
}

#' @export
get_url.BFile <- function(bfile) {
  bfile$url
}

#' Get B-file Data
#'
#' @param bfile A BFile object
#'
#' @return A `gmp::bigz` vector or NULL
#'
#' @export
get_bfile_data <- function(bfile) {
  UseMethod("get_bfile_data")
}

#' @export
get_bfile_data.BFile <- function(bfile) {
  bfile$data
}

#' Get B-file Indices
#'
#' @param bfile A BFile object
#'
#' @return Integer vector of the first-column indices, or NULL when parsing failed
#'
#' @export
get_bfile_indices <- function(bfile) {
  UseMethod("get_bfile_indices")
}

#' @export
get_bfile_indices.BFile <- function(bfile) {
  bfile$indices
}

#' Create a b-file text file for an OEIS sequence
#'
#' Writes sequence values in the standard b-file format ("n a(n)", one pair
#' per line).
#'
#' @param oeis_id Character string (e.g., "A213676")
#' @param data Vector of sequence values (numeric, integer, character, or
#'   `gmp::bigz`)
#' @param offset Integer starting index. Defaults to 1
#' @param output_path Directory or exact file path to save the b-file. If
#'   `NULL` (default), saves to the current working directory using the
#'   standard b-file name (e.g., "b213676.txt")
#'
#' @return Character string: the path to the created b-file
#'
#' @export
create_bfile <- function(oeis_id, data, offset = 1L, output_path = NULL) {
  filename <- oeis_bfile(oeis_id)

  if (is.null(output_path)) {
    file_path <- filename
  } else if (dir.exists(output_path)) {
    file_path <- file.path(output_path, filename)
  } else {
    file_path <- output_path
  }

  indices <- seq_along(data) - 1L + as.integer(offset)
  writeLines(paste(indices, as.character(data)), file_path)

  file_path
}

#' Plot B-file Data
#'
#' @param bfile A BFile object
#' @param n Number of leading points to plot. When NULL (default), all
#'   available points are plotted
#' @param plot_style One of "line" (default), "joined" (alias for "line"),
#'   or "scatter"
#' @param ... Additional aesthetic parameters forwarded to `geom_line()` or
#'   `geom_point()`
#'
#' @return A ggplot2 plot object when `return_plot = TRUE`; otherwise
#'   invisible NULL
#'
#' @export
plot_data <- function(bfile, n = NULL, plot_style = "line", ...) {
  UseMethod("plot_data")
}

#' @rdname plot_data
#' @param p An existing ggplot object to layer onto, or NULL to create a new
#'   plot
#' @param show Logical; print the plot when TRUE (default)
#' @param return_plot Logical; return the ggplot object when TRUE. Defaults
#'   to FALSE
#' @export
plot_data.BFile <- function(bfile, n = NULL, plot_style = "line", p = NULL,
                             show = TRUE, return_plot = FALSE, ...) {
  values <- get_bfile_data(bfile)
  if (is.null(values) || length(values) == 0) {
    stop("No b-file data available to plot")
  }

  if (!is.null(n)) {
    if (!is.numeric(n) || length(n) != 1 || n != as.integer(n)) {
      stop("n must be an integer or NULL.")
    }
    if (n < 0) {
      stop("n must be non-negative.")
    }
  }

  if (!is.character(plot_style) || length(plot_style) != 1) {
    stop("plot_style must be a string.")
  }

  style <- tolower(trimws(plot_style))
  if (style == "joined") style <- "line"
  if (!style %in% c("line", "scatter")) {
    stop("plot_style must be one of: 'line', 'joined', or 'scatter'.")
  }

  indices <- get_bfile_indices(bfile)
  use_bfile_indices <- !is.null(indices) && length(indices) == length(values)

  plot_values <- if (is.null(n)) values else utils::head(values, as.integer(n))
  if (use_bfile_indices) {
    x_values <- if (is.null(n)) indices else utils::head(indices, as.integer(n))
  } else {
    x_values <- seq_along(plot_values) - 1L
  }

  numeric_values <- suppressWarnings(as.numeric(plot_values))
  use_log_magnitude <- any(!is.finite(numeric_values))

  if (use_log_magnitude) {
    y_values <- vapply(seq_along(plot_values), function(i) {
      value <- plot_values[i]
      if (value == 0) return(0)
      magnitude <- .safe_log10_abs(value)
      if (value < 0) -magnitude else magnitude
    }, numeric(1))
    y_label <- "sign(value) * log10(|value|)"
    title_suffix <- " b-file data (log10 magnitude)"
  } else {
    y_values <- numeric_values
    y_label <- paste0(bfile$oeis_id, "(n)")
    title_suffix <- " b-file data"
  }

  x_label <- if (use_bfile_indices) "n" else "Index"

  df <- data.frame(x = as.numeric(x_values), y = y_values)
  geom_layer <- if (style == "scatter") {
    ggplot2::geom_point(data = df, mapping = ggplot2::aes(x = .data$x, y = .data$y), ...)
  } else {
    ggplot2::geom_line(data = df, mapping = ggplot2::aes(x = .data$x, y = .data$y), ...)
  }

  base <- if (is.null(p)) ggplot2::ggplot() else p
  plot_obj <- base + geom_layer

  existing_title <- if (is.null(p)) NULL else p$labels$title
  new_title <- paste0(bfile$oeis_id, title_suffix)
  if (!is.null(existing_title) && nzchar(existing_title) &&
      !grepl(bfile$oeis_id, existing_title, fixed = TRUE) &&
      endsWith(existing_title, title_suffix)) {
    title <- sub(title_suffix, paste0(" + ", bfile$oeis_id, title_suffix), existing_title, fixed = TRUE)
  } else {
    title <- new_title
  }

  plot_obj <- plot_obj +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = title, x = x_label, y = y_label)

  if (isTRUE(show)) {
    print(plot_obj)
  }

  if (isTRUE(return_plot)) {
    return(plot_obj)
  }

  invisible(NULL)
}

fetch_bfile_data <- function(url) {
  text <- tryCatch(.oeis_get_text(url), error = function(e) {
    warning("Failed to fetch or parse b-file: ", conditionMessage(e))
    NULL
  })

  if (is.null(text)) {
    return(list(indices = NULL, data = NULL))
  }

  lines <- trimws(strsplit(text, "\n")[[1]])
  lines <- lines[lines != "" & !startsWith(lines, "#")]

  if (length(lines) == 0) {
    return(list(indices = NULL, data = NULL))
  }

  tokens <- strsplit(lines, "\\s+")
  if (any(vapply(tokens, length, integer(1)) < 2)) {
    return(list(indices = NULL, data = NULL))
  }

  index_tokens <- vapply(tokens, `[[`, character(1), 1)
  value_tokens <- vapply(tokens, `[[`, character(1), 2)

  indices <- suppressWarnings(as.integer(index_tokens))
  if (anyNA(indices)) {
    return(list(indices = NULL, data = NULL))
  }

  values <- suppressWarnings(gmp::as.bigz(value_tokens))
  if (any(is.na(values))) {
    return(list(indices = NULL, data = NULL))
  }

  list(indices = indices, data = values)
}

#' @export
print.BFile <- function(x, ...) {
  cat("OEIS B-file:", x$oeis_id, "\n")
  cat("Filename:", x$filename, "\n")
  invisible(x)
}
