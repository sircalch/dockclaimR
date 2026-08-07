#' Return a template for docking provenance metadata
#'
#' Produces the required fields for a one-row manifest that accompanies a table
#' of docking runs. Fill the fields before analysing real runs; missing values
#' are intentionally retained in the template so that they cannot be mistaken
#' for observed provenance.
#'
#' @return A one-row data frame with required manifest fields set to `NA`.
#' @export
docking_manifest_template <- function() {
  fields <- c(
    "study_id", "engine", "engine_version", "score_direction",
    "receptor_id", "search_space_id", "ligand_preparation",
    "scenario_definition", "random_seed_policy", "run_table_path",
    "created_utc"
  )
  out <- as.data.frame(as.list(rep(NA_character_, length(fields))),
    stringsAsFactors = FALSE
  )
  names(out) <- fields
  out
}

#' Validate a docking provenance manifest
#'
#' Ensures that analysis is accompanied by the minimum context needed to audit
#' the origin of a docking-run table. It verifies completeness, not scientific
#' correctness of the reported choices.
#'
#' @param manifest A one-row data frame based on [docking_manifest_template()].
#'
#' @return Invisibly returns `manifest` when it is complete.
#' @export
validate_docking_manifest <- function(manifest) {
  template <- docking_manifest_template()
  required <- names(template)

  if (!is.data.frame(manifest) || nrow(manifest) != 1L) {
    stop("`manifest` must be a one-row data frame.", call. = FALSE)
  }
  missing <- setdiff(required, names(manifest))
  if (length(missing) > 0L) {
    stop(
      "`manifest` is missing required field(s): ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  values <- manifest[1L, required, drop = FALSE]
  incomplete <- names(values)[vapply(values, function(x) {
    length(x) != 1L || is.na(x) || !nzchar(trimws(as.character(x)))
  }, logical(1L))]
  if (length(incomplete) > 0L) {
    stop(
      "`manifest` has empty required field(s): ",
      paste(incomplete, collapse = ", "), ".",
      call. = FALSE
    )
  }

  direction <- tolower(as.character(values$score_direction))
  if (!direction %in% c("lower", "higher")) {
    stop("`score_direction` must be `lower` or `higher`.", call. = FALSE)
  }
  invisible(manifest)
}
