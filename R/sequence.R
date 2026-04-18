#' OEIS Sequence Class
#'
#' @param oeis_id Character string (e.g., "A000045")
#'
#' @return An object of class "Sequence"
#'
#' @examples
#' \donttest{
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

  tryCatch({
    response <- httr2::request(url) |>
      httr2::req_timeout(10) |>
      httr2::req_perform()

    json_data <- jsonlite::fromJSON(httr2::resp_body_string(response))
    seq_data <- json_data$results[[1]]
  }, error = function(e) {
    stop("Failed to fetch sequence: ", e$message)
  })

  data <- parse_data_values(seq_data$data)

  structure(
    list(
      id = oeis_id,
      name = seq_data$name %||% "",
      data = data,
      comments = seq_data$comment %||% character(0),
      formula = seq_data$formula %||% character(0),
      keywords = strsplit(seq_data$keyword %||% "", ",")[[1]],
      offset = seq_data$offset %||% "",
      author = seq_data$author %||% "",
      json = seq_data
    ),
    class = "Sequence"
  )
}

#' Get B-file Information
#'
#' @param seq A Sequence object
#'
#' @return List with b-file metadata
#'
#' @export
get_bfile_info <- function(seq) {
  UseMethod("get_bfile_info")
}

#' @export
get_bfile_info.Sequence <- function(seq) {
  bfile <- BFile(seq$id)
  data <- get_bfile_data(bfile)

  if (is.null(data)) {
    return(list(available = FALSE, length = 0))
  }

  list(available = TRUE, length = length(data))
}

#' Extract cross-reference IDs
#'
#' @param seq A Sequence object
#'
#' @return Character vector of OEIS IDs
#'
#' @export
get_xref_ids <- function(seq) {
  UseMethod("get_xref_ids")
}

#' @export
get_xref_ids.Sequence <- function(seq) {
  xref_text <- paste(seq$json$xref, collapse = " ")
  extract_oeis_ids(xref_text)
}

#' Plot Sequence Data
#'
#' @param x A Sequence object
#' @param ... Additional arguments passed to plot_data
#'
#' @export
plot.Sequence <- function(x, ...) {
  # Try to use b-file for more data, otherwise use available data
  tryCatch({
    bfile <- BFile(x$id)
    plot_data(bfile, ...)
  }, error = function(e) {
    # Fallback to internal data if b-file fails
    df <- data.frame(index = seq_along(x$data), value = x$data)
    ggplot2::ggplot(df, ggplot2::aes(x = .data$index, y = .data$value)) +
      ggplot2::geom_line() +
      ggplot2::theme_minimal() +
      ggplot2::labs(title = paste0(x$id, ": ", x$name))
  })
}

parse_data_values <- function(data_raw) {
  if (is.null(data_raw)) return(integer(0))
  if (is.numeric(data_raw)) return(as.integer(data_raw))
  if (is.character(data_raw)) {
    # Handle comma-separated values
    vals <- strsplit(data_raw, ",")[[1]]
    return(as.integer(vals))
  }
  integer(0)
}

`%||%` <- function(x, y) if (is.null(x)) y else x

#' @export
print.Sequence <- function(x, ...) {
  cat("OEIS Sequence:", x$id, "\n")
  cat("Name:", x$name, "\n")
  invisible(x)
}
