baseoai <- function() "https://ws.pangaea.de/oai/provider"
base <- function() 'https://doi.pangaea.de/'
sbase <- function() "https://www.pangaea.de/advanced/search.php"
esbase <- function() "https://ws.pangaea.de/es/pangaea/panmd/_search"

pgc <- function(x) Filter(Negate(is.null), x)

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

check <- function(x){
  if (is.character(x)) {
    if ( grepl("does not exist|unknown", x))
      stop(x, call. = FALSE)
  }
}

read_csv <- function(x){
  lns <- readLines(x, n = 1000)
  ln_no <- grep("\\*/", lns)
  tmp <- utils::read.csv(x, header = FALSE, sep = "\t",
                  skip = ln_no + 1, stringsAsFactors = FALSE)
  nn <- strsplit(lns[ln_no + 1], "\t")[[1]]
  stats::setNames(tmp, nn)
}

ifn <- function(x) if (is.null(x)) NA else x

strextract <- function(str, pattern) regmatches(str, regexpr(pattern, str))

capwords <- function(s, strict = FALSE, onlyfirst = FALSE) {
  cap <- function(s) paste(toupper(substring(s,1,1)), {
    s <- substring(s,2); if (strict) tolower(s) else s
  }, sep = "", collapse = " " )
  if (!onlyfirst) {
    sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
  } else {
    sapply(s, function(x)
      paste(toupper(substring(x,1,1)),
            tolower(substring(x,2)),
            sep = "", collapse = " "), USE.NAMES = FALSE)
  }
}

cuf8 <- function(x) httr::content(x, "text", encoding = "UTF-8")

cl <- function(x) if (is.null(x)) NULL else paste0(x, collapse = ",")

cn <- function(x) {
  name <- substitute(x)
  if (!is.null(x)) {
    tryx <- tryCatch(as.numeric(as.character(x)), warning = function(e) e)
    if ("warning" %in% class(tryx)) {
      stop(name, " should be a numeric or integer class value", call. = FALSE)
    }
    if (!is.numeric(tryx) | is.na(tryx))
      stop(name, " should be a numeric or integer class value", call. = FALSE)
    return( format(x, digits = 22, scientific = FALSE) )
  } else {
    NULL
  }
}

as_log <- function(x) {
  if (is.null(x)) {
    x
  } else {
    if (x) 'true' else 'false'
  }
}
