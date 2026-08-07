#!/usr/bin/env Rscript

# Generate descriptive rank-stability summaries for a completed ADA pilot.
# This script refuses incomplete or failed run tables.

args <- commandArgs(trailingOnly = TRUE)
input <- if (length(args) >= 1L) args[[1L]] else {
  "data/derived/dude-ada/pilot_runs.csv"
}
output_dir <- if (length(args) >= 2L) args[[2L]] else {
  "data/derived/dude-ada"
}

if (!requireNamespace("devtools", quietly = TRUE)) {
  stop("The development package 'devtools' is required to load dockclaimR.")
}
devtools::load_all(".", quiet = TRUE)

raw <- read.csv(input, stringsAsFactors = FALSE)
if (nrow(raw) != 72L || !all(raw$status == "success")) {
  stop("The ADA pilot must contain exactly 72 successful rows before analysis.")
}

runs <- raw
runs$source_ligand_id <- runs$ligand_id
runs$ligand_id <- sprintf("ada_pilot_%02d", as.integer(runs$pilot_index))
runs$score <- as.numeric(runs$score)

manifest <- docking_manifest_template()
manifest$study_id <- "DUD-E_ADA_pilot_2026-08-07"
manifest$engine <- "AutoDock Vina"
manifest$engine_version <- "1.2.7"
manifest$score_direction <- "lower"
manifest$receptor_id <- "DUD-E ADA receptor.pdb converted with Open Babel 3.1.0"
manifest$search_space_id <- "crystal_ligand_bbox_plus_5A"
manifest$ligand_preparation <- "Meeko 0.7.1; deterministic 6 active + 18 decoy pilot"
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

cat("ADA pilot descriptive summaries written to ", output_dir, ".\n", sep = "")
