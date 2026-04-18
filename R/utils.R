#' OEIS URL constant
#' @keywords internal
OEIS_URL <- "https://oeis.org"

#' Check if an OEIS ID is valid
#'
#' Validates that the OEIS ID follows the format: A followed by exactly 6 digits
#'
#' @param oeis_id Character string to validate
#'
#' @return Logical TRUE if valid, FALSE otherwise
#'
#' @examples
#' check_id("A000045")  # TRUE
#' check_id("invalid")  # FALSE
#'
#' @export
check_id <- function(oeis_id) {
  if (!is.character(oeis_id)) return(FALSE)
  grepl("^A\\d{6}$", oeis_id)
}

#' Generate OEIS b-file filename
#'
#' @param oeis_id Character string (e.g., "A000045")
#'
#' @return Character string (e.g., "b000045.txt")
#'
#' @examples
#' oeis_bfile("A000045")
#'
#' @export
oeis_bfile <- function(oeis_id) {
  if (!check_id(oeis_id)) {
    stop("Invalid OEIS ID: ", oeis_id)
  }
  digits <- substr(oeis_id, 2, 7)
  paste0("b", digits, ".txt")
}

#' Generate OEIS URL
#'
#' @param oeis_id Character string (e.g., "A000045")
#' @param fmt Character string: "json", "text", "bfile", "graph", or NULL
#'
#' @return Character string containing the URL
#'
#' @examples
#' oeis_url("A000045")
#' oeis_url("A000045", fmt = "json")
#'
#' @export
oeis_url <- function(oeis_id, fmt = NULL) {
  base_url <- OEIS_URL
  
  if (is.null(fmt)) {
    return(paste0(base_url, "/", oeis_id))
  }
  
  fmt <- tolower(trimws(as.character(fmt)))
  
  switch(fmt,
    json = paste0(base_url, "/search?q=id:", oeis_id, "&fmt=json"),
    text = paste0(base_url, "/search?q=id:", oeis_id, "&fmt=text"),
    bfile = paste0(base_url, "/", oeis_id, "/", oeis_bfile(oeis_id)),
    graph = paste0(base_url, "/", oeis_id, "/graph?png=1"),
    paste0(base_url, "/", oeis_id)
  )
}

#' Get OEIS keyword description
#'
#' @param keyword_tag Character string
#'
#' @return Character string with description or NULL
#'
#' @export
oeis_keyword_description <- function(keyword_tag) {
  keyword_map <- list(
    base = "Sequence is dependent on the numeral base used.",
    bref = "Sequence is too short to do any analysis with.",
    cofr = "A continued fraction expansion of a number.",
    cons = "A decimal expansion of a number (occasionally another base).",
    core = "A fundamental sequence.",
    dead = "An erroneous or duplicated sequence kept with pointers to correct versions.",
    dumb = "An unimportant sequence.",
    easy = "It is easy to produce terms of this sequence.",
    eigen = "An eigensequence: a fixed sequence under some transformation.",
    fini = "A confirmed finite sequence.",
    frac = "Numerators or denominators of a sequence of rational numbers.",
    full = "The full sequence is given (implies the sequence is finite).",
    hard = "Next term is not known and may be hard to find; more terms are requested.",
    hear = "Graph audio is considered particularly interesting or beautiful.",
    less = "Less interesting sequence and less likely to be the intended target.",
    look = "Graph visual is considered particularly interesting or beautiful.",
    more = "More terms are needed; extension requested.",
    mult = "Multiplicative sequence: a(m*n)=a(m)*a(n) for gcd(m,n)=1.",
    nice = "An exceptionally nice sequence.",
    nonn = "Displayed terms are nonnegative (later terms may still become negative).",
    obsc = "Obscure sequence; better description needed.",
    sign = "Sequence contains negative numbers.",
    tabf = "Irregular array read row by row.",
    tabl = "Regular array read row by row.",
    unkn = "Definition or context is not known.",
    walk = "Counts walks or self-avoiding paths.",
    word = "Depends on words in some language.",
    allocated = "A-number allocated for a contributor; entry not ready to go live.",
    changed = "Older entry modified within the last two weeks.",
    `new` = "New entry, added or modified within roughly the last two weeks.",
    probation = "Included provisionally and may be deleted at editor discretion.",
    recycled = "A proposed entry was rejected and the A-number is reused.",
    uned = "Not edited; entry still needs editorial review."
  )
  
  if (is.null(keyword_tag)) return(NULL)
  tag <- tolower(trimws(as.character(keyword_tag)))
  if (tag == "") return(NULL)
  keyword_map[[tag]]
}

#' Extract OEIS IDs from text
#'
#' @param text Character string to search
#'
#' @return Character vector of OEIS IDs
#'
#' @export
extract_oeis_ids <- function(text) {
  if (is.null(text) || length(text) == 0) return(character(0))
  matches <- regmatches(text, gregexpr("A\\d{6}", text))
  unique(unlist(matches))
}
