#' Search the Pangaea database with Elasticsearch
#'
#' @export
#' @param query (character) Query terms..
#' @param size (character) The number of hits to return. Pass in as a
#' character string to avoid problems with large number conversion to
#' scientific notation. Default: 10. The default maximum is 10,000 - however,
#' you can change this default maximum by changing the
#' \code{index.max_result_window} index level parameter.
#' @param from (character) The starting from index of the hits to return.
#' Pass in as a character string to avoid problems with large number
#' conversion to scientific notation. Default: 0
#' @param source (character) character vector of fields to return
#' @param df (character) The default field to use when no field prefix is
#' defined within the query.
#' @param analyzer (character) The analyzer name to be used when analyzing the
#' query string.
#' @param default_operator (character) The default operator to be used, can be
#' \code{AND} or \code{OR}. Default: \code{OR}
#' @param explain (logical) For each hit, contain an explanation of how
#' scoring of the hits was computed. Default: \code{FALSE}
#' @param sort (character) Sorting to perform. Can either be in the form of
#' fieldName, or \code{fieldName:asc}/\code{fieldName:desc}. The fieldName
#' can either be an actual field within the document, or the special
#' \code{_score} name to indicate sorting based on scores. There can be several
#' sort parameters (order is important).
#' @param track_scores (logical) When sorting, set to \code{TRUE} in order to
#' still track scores and return them as part of each hit.
#' @param timeout (numeric) A search timeout, bounding the search request to
#' be executed within the specified time value and bail with the hits
#' accumulated up to that point when expired. Default: no timeout.
#' @param terminate_after (numeric) The maximum number of documents to collect
#' for each shard, upon reaching which the query execution will terminate
#' early. If set, the response will have a boolean field terminated_early to
#' indicate whether the query execution has actually terminated_early.
#' Default: no terminate_after
#' @param search_type (character) The type of the search operation to perform.
#' Can be \code{query_then_fetch} (default) or \code{dfs_query_then_fetch}.
#' Types \code{scan} and \code{count} are deprecated.
#' See \url{http://bit.ly/19Am9xP} for more details on the different types of
#' search that can be performed.
#' @param lowercase_expanded_terms (logical) Should terms be automatically
#' lowercased or not. Default: \code{TRUE}.
#' @param analyze_wildcard (logical) Should wildcard and prefix queries be
#' analyzed or not. Default: \code{FALSE}.
#' @param version (logical) Print the document version with each document.
#' @param ... Curl options passed on to \code{\link[httr]{GET}}
#' @return tibble/data.frame, empty if no results
#' @seealso \code{\link{pg_search}}
#' @details An interface to Pangaea's Elasticsearch query interface.
#' You can also just use \code{elastic} package to interact with it.
#' The base URL is https://ws.pangaea.de/es/pangaea/panmd/_search
#' @examples \dontrun{
#' (res <- pg_search_es())
#' attributes(res)
#' attr(res, "total")
#' attr(res, "max_score")
#'
#' pg_search_es(query = 'water', source = c('parentURI', 'minElevation'))
#' pg_search_es(query = 'water', size = 3)
#' pg_search_es(query = 'water', size = 3, from = 10)
#'
#' pg_search_es(query = 'water sky', default_operator = "OR")
#' pg_search_es(query = 'water sky', default_operator = "AND")
#'
#' pg_search_es(query = 'water', sort = "minElevation")
#' pg_search_es(query = 'water', sort = "minElevation:desc")
#' }

pg_search_es <- function(query = NULL, size = 10, from = NULL, source = NULL,
  df=NULL, analyzer=NULL, default_operator=NULL, explain=NULL, sort=NULL,
  track_scores=NULL, timeout=NULL, terminate_after=NULL,
  search_type=NULL, lowercase_expanded_terms=NULL, analyze_wildcard=NULL,
  version=FALSE, ...) {

  args <- pgc(
    list(
      q = query, size = size, from = from, `_source` = cl(source),
      df = df, analyzer = analyzer, default_operator = default_operator,
      explain = explain, sort = cl(sort), track_scores = track_scores,
      timeout = cn(timeout), terminate_after = cn(terminate_after),
      search_type = search_type,
      lowercase_expanded_terms = lowercase_expanded_terms,
      analyze_wildcard = analyze_wildcard, version = as_log(version)
    )
  )

  res <- httr::GET(esbase(), query = args, ...)
  httr::stop_for_status(res)
  out <- jsonlite::fromJSON(cuf8(res), flatten = TRUE)
  df <- tibble::as_data_frame(out$hits$hits)
  message("total hits: ", out$hits$total)
  structure(df, total = out$hits$total, max_score = out$hits$max_score)
}
