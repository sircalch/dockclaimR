# Project charter: dockclaimR

## Research question

How can a computational workflow distinguish a reproducible docking
prioritization from a conclusion based on a single score or a single run?

## Scope

The project will analyze a table in which each row represents one ligand in one
prespecified docking scenario. A scenario may vary by random seed, receptor
conformation, preparation protocol, docking engine, or rescoring method.

The project will not:

- predict biological activity, toxicity, or clinical usefulness;
- present docking scores as binding free energies;
- substitute for experimental validation;
- run or distribute docking engines in the initial version.

## Minimum input contract

Required fields are proposed as:

| Field | Meaning |
| --- | --- |
| `ligand_id` | Stable identifier for a tested ligand. |
| `scenario_id` | Identifier for a prespecified run or scenario. |
| `score` | Engine- or method-specific score, kept with its native meaning. |
| `engine` and `engine_version` | Docking software provenance. |
| `receptor_id` | Structure or receptor-preparation identifier. |
| `search_space_id` | Identifier for the reported docking box or pocket definition. |
| `seed` | Random seed when applicable; otherwise an explicit missing-value reason. |
| `scoring_method` | Native score or named rescoring method. |

Optional fields will retain ligand-state, receptor-preparation, grid, pose-file,
and input-file provenance.

## Core analyses

1. Verify that the scenario design and provenance fields are complete.
2. Convert scores to within-scenario ranks only when score direction and
   comparability have been declared.
3. Quantify rank agreement and top-*k* membership across a prespecified set of
   scenarios.
4. Report sensitivity to individual scenario dimensions rather than concealing
   disagreement in an aggregate score.
5. Generate a compact evidence report with thresholds stated by the analyst,
   never chosen after seeing results.

## Validation protocol

Before reporting performance, we will:

1. Freeze a public benchmark and the scenario matrix.
2. Release a manifest containing input structures, engine versions, search
   spaces, parameters, seed policy, and processing scripts.
3. Use known actives and decoys only for prespecified retrospective measures;
   report target-level results, not only a pooled headline number.
4. Compare single-run ranking with scenario-robust ranking.
5. Publish every generated table needed to reproduce figures and claims.
6. Treat a negative or unstable result as a valid outcome.

## Publication path

1. Protocol and repository release with an archived DOI.
2. Package release with tests, vignette, and cross-platform continuous
   integration.
3. Benchmark paper only after the complete executable workflow is public.
4. A separate application paper may later use the tool for a materials or
   bioactive-compound question, but must include independent experimental
   validation before making biological claims.

## Literature anchors

- Spiga et al. describe practical reporting and validation requirements for
  meaningful molecular docking, including the need to share inputs and
  parameters: https://doi.org/10.1371/journal.pcbi.1013030
- The *Communications Biology* reproducibility checklist covers molecular
  simulations and related docking workflows:
  https://doi.org/10.1038/s42003-023-04653-0
- Docking reproducibility work emphasizes that score-only reports omit crucial
  information about provenance and validation. The project will address this
  analytical layer without claiming to replace experimental confirmation.

## Authorship and research integrity

Authorship will be assigned by documented intellectual and practical
contributions, not by affiliation or tool use. All generated text, code, and
results will be reviewed, tested, and approved by the authors. No result will
be described as observed until its underlying data and script exist.
