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
  data <- fetch_bfile_data(url)
  
  structure(
    list(
      oeis_id = oeis_id,
      filename = filename,
      url = url,
      data = data
    ),
    class = "BFile"
  )
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
#' @return Integer vector or NULL
#'
#' @export
get_bfile_data <- function(bfile) {
  UseMethod("get_bfile_data")
}

#' @export
get_bfile_data.BFile <- function(bfile) {
  bfile$data
}

#' Plot B-file Data
#'
#' @param bfile A BFile object
#' @param n Number of points to plot
#' @param plot_style "line" or "scatter"
#' @param ... Additional arguments
#'
#' @return A ggplot2 plot
#'
#' @export
plot_data <- function(bfile, n = NULL, plot_style = "line", ...) {
  UseMethod("plot_data")
}

#' @export
plot_data.BFile <- function(bfile, n = NULL, plot_style = "line", ...) {
  data <- get_bfile_data(bfile)
  
  if (is.null(data) || length(data) == 0) {
    stop("No b-file data available")
  }
  
  if (!is.null(n)) {
    data <- head(data, as.integer(n))
  }
  
  df <- data.frame(index = seq_along(data), value = data)
  
  ggplot2::ggplot(df, ggplot2::aes(x = index, y = value)) +
    {if (plot_style == "scatter") ggplot2::geom_point(...) else ggplot2::geom_line(...)} +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = paste0(bfile$oeis_id, " b-file data"))
}

fetch_bfile_data <- function(url) {
  tryCatch({
    response <- httr2::request(url) |>
      httr2::req_timeout(10) |>
      httr2::req_perform()
    
    lines <- strsplit(httr2::resp_body_string(response), "\n")[[1]]
    data <- integer(0)
    
    for (line in lines) {
      line <- trimws(line)
      if (line == "" || grepl("^#", line)) next
      
      parts <- strsplit(line, "\\s+")[[1]]
      if (length(parts) >= 2) {
        data <- c(data, as.integer(parts[2]))
      }
    }
    
    if (length(data) == 0) NULL else data
  }, error = function(e) NULL)
}

#' @export
print.BFile <- function(x, ...) {
  cat("OEIS B-file:", x$oeis_id, "\n")
  cat("Filename:", x$filename, "\n")
  invisible(x)
}
