#' Validate a table of molecular docking runs
#'
#' Checks the minimum provenance fields required to compare rankings across
#' prespecified docking scenarios. A scenario may represent, for example, a
#' random seed, receptor conformation, or rescoring method.
#'
#' @param data A data frame with `ligand_id`, `scenario_id`, and `score`.
#'
#' @return Invisibly returns `data` when it satisfies the input contract.
#' @export
validate_docking_runs <- function(data) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  required <- c("ligand_id", "scenario_id", "score")
  missing <- setdiff(required, names(data))
  if (length(missing) > 0L) {
    stop(
      "`data` is missing required column(s): ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }

  if (nrow(data) == 0L) {
    stop("`data` must contain at least one docking result.", call. = FALSE)
  }
  if (anyNA(data$ligand_id) || anyNA(data$scenario_id)) {
    stop("`ligand_id` and `scenario_id` cannot contain missing values.", call. = FALSE)
  }
  if (!is.numeric(data$score) || any(!is.finite(data$score))) {
    stop("`score` must be a finite numeric column.", call. = FALSE)
  }

  pair <- paste(data$ligand_id, data$scenario_id, sep = "\r")
  if (anyDuplicated(pair)) {
    stop(
      "Each `ligand_id` and `scenario_id` combination must occur once.",
      call. = FALSE
    )
  }

  invisible(data)
}

#' Rank docking results within scenario
#'
#' Ranks scores only within each scenario. Scores are not pooled across engines
#' or scoring methods because their scales need not be comparable.
#'
#' @param data A validated docking-run table.
#' @param score_direction Whether lower or higher scores are preferred.
#'
#' @return A copy of `data` with a `rank_within_scenario` column.
#' @export
rank_docking_runs <- function(data, score_direction = c("lower", "higher")) {
  validate_docking_runs(data)
  score_direction <- match.arg(score_direction)

  ranking_score <- if (identical(score_direction, "lower")) {
    data$score
  } else {
    -data$score
  }
  scenario <- as.character(data$scenario_id)
  data$rank_within_scenario <- stats::ave(
    ranking_score,
    scenario,
    FUN = function(x) rank(x, ties.method = "min")
  )
  data
}

#' Summarise pairwise rank agreement between docking scenarios
#'
#' Calculates Spearman rank correlation using only ligand instances present in
#' both scenarios of a pair. It describes agreement within the supplied study;
#' it is not a validation of binding or biological activity.
#'
#' @param data A validated docking-run table.
#' @param score_direction Whether lower or higher scores are preferred.
#'
#' @return A data frame with one row per scenario pair.
#' @export
summarise_rank_agreement <- function(
    data,
    score_direction = c("lower", "higher")) {
  ranked <- rank_docking_runs(data, score_direction = score_direction)
  scenarios <- sort(unique(as.character(ranked$scenario_id)))
  if (length(scenarios) < 2L) {
    stop("At least two scenarios are required for rank agreement.", call. = FALSE)
  }

  scenario_pairs <- utils::combn(scenarios, 2L, simplify = FALSE)
  rows <- lapply(scenario_pairs, function(pair) {
    first <- ranked[as.character(ranked$scenario_id) == pair[[1L]],
      c("ligand_id", "rank_within_scenario"), drop = FALSE
    ]
    second <- ranked[as.character(ranked$scenario_id) == pair[[2L]],
      c("ligand_id", "rank_within_scenario"), drop = FALSE
    ]
    shared <- merge(first, second, by = "ligand_id", suffixes = c("_first", "_second"))
    if (nrow(shared) < 2L) {
      rho <- NA_real_
    } else {
      rho <- stats::cor(
        shared$rank_within_scenario_first,
        shared$rank_within_scenario_second,
        method = "spearman"
      )
    }
    data.frame(
      scenario_first = pair[[1L]],
      scenario_second = pair[[2L]],
      ligands_shared = nrow(shared),
      spearman_rho = rho,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

#' Summarise top-k stability across docking scenarios
#'
#' Calculates the proportion of observed scenarios in which each ligand falls
#' within the requested top-k ranking. Missing ligand-scenario combinations are
#' retained explicitly through `scenarios_observed`; the function does not
#' silently treat missing runs as poor ranks.
#'
#' @param data A validated docking-run table.
#' @param top_k Positive integer defining the top-k set within a scenario.
#' @param score_direction Whether lower or higher scores are preferred.
#'
#' @return A data frame with one row per ligand and stability summaries.
#' @export
summarise_top_k_stability <- function(
    data,
    top_k = 5L,
    score_direction = c("lower", "higher")) {
  if (!is.numeric(top_k) || length(top_k) != 1L || is.na(top_k) ||
      top_k < 1L || top_k != as.integer(top_k)) {
    stop("`top_k` must be one positive integer.", call. = FALSE)
  }

  ranked <- rank_docking_runs(data, score_direction = score_direction)
  by_ligand <- split(ranked, as.character(ranked$ligand_id), drop = TRUE)
  summary_rows <- lapply(by_ligand, function(x) {
    top_k_count <- sum(x$rank_within_scenario <= top_k)
    data.frame(
      ligand_id = as.character(x$ligand_id[[1L]]),
      scenarios_observed = nrow(x),
      mean_rank = mean(x$rank_within_scenario),
      top_k_count = top_k_count,
      top_k_proportion = top_k_count / nrow(x),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, summary_rows)
  rownames(out) <- NULL
  out[order(-out$top_k_proportion, out$mean_rank, out$ligand_id), , drop = FALSE]
}

#' Assess a prespecified top-k stability threshold
#'
#' Returns a transparent claim table. Passing the threshold means only that a
#' ligand met the stated rank-stability criterion in the supplied scenarios; it
#' is not evidence of molecular binding, biological activity, or safety.
#'
#' @param stability Output from [summarise_top_k_stability()].
#' @param threshold Number between zero and one, fixed before interpretation.
#'
#' @return A data frame containing the stability criterion and pass/fail result.
#' @export
assess_top_k_stability <- function(stability, threshold = 0.9) {
  needed <- c("ligand_id", "scenarios_observed", "top_k_proportion")
  if (!is.data.frame(stability) || !all(needed %in% names(stability))) {
    stop(
      "`stability` must be output from `summarise_top_k_stability()`.",
      call. = FALSE
    )
  }
  if (!is.numeric(threshold) || length(threshold) != 1L || is.na(threshold) ||
      threshold < 0 || threshold > 1) {
    stop("`threshold` must be one number between 0 and 1.", call. = FALSE)
  }

  data.frame(
    ligand_id = stability$ligand_id,
    scenarios_observed = stability$scenarios_observed,
    top_k_proportion = stability$top_k_proportion,
    threshold = threshold,
    stable_top_k = stability$top_k_proportion >= threshold,
    interpretation = "Rank-stability criterion only; not binding or activity evidence.",
    stringsAsFactors = FALSE
  )
}
