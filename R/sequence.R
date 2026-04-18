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
  character(0)
}

parse_data_values <- function(data_raw) {
  if (is.null(data_raw)) return(integer(0))
  if (is.numeric(data_raw)) return(as.integer(data_raw))
  integer(0)
}

`%||%` <- function(x, y) if (is.null(x)) y else x

#' @export
print.Sequence <- function(x, ...) {
  cat("OEIS Sequence:", x$id, "\n")
  cat("Name:", x$name, "\n")
  invisible(x)
}
