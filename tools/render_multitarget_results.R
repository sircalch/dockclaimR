#!/usr/bin/env Rscript

# Render publication-oriented descriptive outputs from completed local DUD-E
# target subsets. This script does not estimate activity or docking performance.

args <- commandArgs(trailingOnly = TRUE)
output_dir <- if (length(args) >= 1L) args[[1L]] else "results/multitarget"
targets <- c("ada", "ampc", "comt")

read_target <- function(target) {
  base <- file.path("data", "derived", paste0("dude-", target))
  agreement <- read.csv(file.path(base, "rank_agreement.csv"), stringsAsFactors = FALSE)
  top1 <- read.csv(file.path(base, "stability_top1.csv"), stringsAsFactors = FALSE)
  top5 <- read.csv(file.path(base, "stability_top5.csv"), stringsAsFactors = FALSE)
  data.frame(
    target = toupper(target),
    scenario_first = agreement$scenario_first,
    scenario_second = agreement$scenario_second,
    ligands_shared = agreement$ligands_shared,
    spearman_rho = agreement$spearman_rho,
    top1_all_three_seeds = sum(top1$top_k_proportion == 1),
    top5_all_three_seeds = sum(top5$top_k_proportion == 1),
    total_ligands = nrow(top1)
  )
}

summary <- do.call(rbind, lapply(targets, read_target))
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(summary, file.path(output_dir, "multitarget_rank_agreement.csv"), row.names = FALSE)

png(file.path(output_dir, "multitarget_rank_agreement.png"),
    width = 1800, height = 1100, res = 200)
old <- par(mar = c(7, 4.5, 3, 1))
on.exit(par(old), add = TRUE)
labels <- paste(summary$target, sub("seed_", "", summary$scenario_first),
                sub("seed_", "", summary$scenario_second), sep = "\n")
cols <- c(ADA = "#377eb8", AMPC = "#4daf4a", COMT = "#984ea3")
barplot(summary$spearman_rho, names.arg = labels, col = cols[summary$target],
        ylim = c(0, 1), las = 2, ylab = "Spearman rank correlation",
        main = "Seed-level rank agreement in the DUD-E workflow study")
abline(h = c(0, 1), col = "grey80", lty = c(1, 2))
legend("bottomleft", legend = names(cols), fill = cols, bty = "n")
dev.off()

message("Wrote descriptive multiblanco outputs to ", output_dir)
