#!/usr/bin/env Rscript

# Generate descriptive rank-stability summaries for a completed DUD-E target subset.
# This script refuses incomplete or failed run tables.

args <- commandArgs(trailingOnly = TRUE)
input <- if (length(args) >= 1L) args[[1L]] else {
  "data/derived/dude-ada/pilot_runs.csv"
}
output_dir <- if (length(args) >= 2L) args[[2L]] else {
  "data/derived/dude-ada"
}
target_code <- if (length(args) >= 3L) toupper(args[[3L]]) else "ADA"

if (!requireNamespace("devtools", quietly = TRUE)) {
  stop("The development package 'devtools' is required to load dockclaimR.")
}
devtools::load_all(".", quiet = TRUE)

raw <- read.csv(input, stringsAsFactors = FALSE)
if (nrow(raw) != 72L || !all(raw$status == "success")) {
  stop("The target subset must contain exactly 72 successful rows before analysis.")
}

runs <- raw
runs$ligand_id <- sprintf("%s_pilot_%02d", tolower(target_code), as.integer(runs$pilot_index))
runs$score <- as.numeric(runs$score)

manifest <- docking_manifest_template()
manifest$study_id <- sprintf("DUD-E_%s_pilot_2026-08-07", target_code)
manifest$engine <- "AutoDock Vina"
manifest$engine_version <- "1.2.7"
manifest$score_direction <- "lower"
manifest$receptor_id <- sprintf("DUD-E %s receptor.pdb converted with Open Babel 3.1.0", target_code)
manifest$search_space_id <- "crystal_ligand_bbox_plus_5A"
manifest$ligand_preparation <- sprintf("Meeko 0.7.1; deterministic 6 active + 18 decoy %s pilot", target_code)
manifest$scenario_definition <- "AutoDock Vina random seeds 1001, 2002, and 3003; exhaustiveness 4; three modes"
manifest$random_seed_policy <- "Fixed seeds: 1001, 2002, 3003"
manifest$run_table_path <- file.path(output_dir, "pilot_runs_normalized.csv")
manifest$created_utc <- format(Sys.time(), tz = "UTC", usetz = TRUE)
validate_docking_manifest(manifest)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(manifest, file.path(output_dir, "pilot_manifest.csv"), row.names = FALSE)
write.csv(runs, file.path(output_dir, "pilot_runs_normalized.csv"), row.names = FALSE)
write.csv(
  summarise_top_k_stability(runs, top_k = 1L),
  file.path(output_dir, "stability_top1.csv"),
  row.names = FALSE
)
write.csv(
  summarise_top_k_stability(runs, top_k = 5L),
  file.path(output_dir, "stability_top5.csv"),
  row.names = FALSE
)
write.csv(
  summarise_rank_agreement(runs),
  file.path(output_dir, "rank_agreement.csv"),
  row.names = FALSE
)

cat(target_code, " pilot descriptive summaries written to ", output_dir, ".\n", sep = "")
