test_that("ranks are calculated within scenario", {
  runs <- data.frame(
    ligand_id = rep(c("A", "B", "C"), 2L),
    scenario_id = rep(c("seed_1", "seed_2"), each = 3L),
    score = c(-8, -7, -6, -7, -9, -6)
  )

  ranked <- rank_docking_runs(runs)
  expect_equal(ranked$rank_within_scenario, c(1, 2, 3, 2, 1, 3))
})

test_that("rank agreement uses ligands shared by both scenarios", {
  runs <- data.frame(
    ligand_id = c("A", "B", "C", "A", "B", "C"),
    scenario_id = c(rep("first", 3L), rep("second", 3L)),
    score = c(-9, -8, -7, -6, -7, -8)
  )
  agreement <- summarise_rank_agreement(runs)
  expect_equal(agreement$ligands_shared, 3L)
  expect_equal(agreement$spearman_rho, -1)
  expect_error(summarise_rank_agreement(runs[runs$scenario_id == "first", ]), "two scenarios")
})

test_that("top-k stability remains explicit about scenario coverage", {
  runs <- data.frame(
    ligand_id = c("A", "B", "A", "B", "C"),
    scenario_id = c("one", "one", "two", "two", "two"),
    score = c(-9, -8, -8, -7, -9)
  )

  stability <- summarise_top_k_stability(runs, top_k = 1L)
  a <- stability[stability$ligand_id == "A", ]
  expect_equal(a$scenarios_observed, 2L)
  expect_equal(a$top_k_proportion, 0.5)

  claim <- assess_top_k_stability(stability, threshold = 0.75)
  expect_false(claim$stable_top_k[claim$ligand_id == "A"])
})

test_that("invalid or duplicate inputs fail clearly", {
  expect_error(validate_docking_runs(data.frame(score = -7)), "missing required")
  duplicate <- data.frame(
    ligand_id = c("A", "A"),
    scenario_id = c("one", "one"),
    score = c(-7, -8)
  )
  expect_error(validate_docking_runs(duplicate), "must occur once")
  valid <- data.frame(
    ligand_id = c("A", "B"),
    scenario_id = c("one", "one"),
    score = c(-7, -8)
  )
  expect_error(summarise_top_k_stability(valid, top_k = "1"), "positive integer")
})

test_that("manifest records required provenance before analysis", {
  manifest <- docking_manifest_template()
  expect_error(validate_docking_manifest(manifest), "empty required")

  manifest[] <- "recorded"
  manifest$score_direction <- "lower"
  expect_identical(validate_docking_manifest(manifest), manifest)
  manifest$score_direction <- "unknown"
  expect_error(validate_docking_manifest(manifest), "lower.*higher")
})
