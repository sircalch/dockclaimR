# Contributing to dockclaimR

Thank you for considering a contribution. `dockclaimR` is experimental
research software. Please open an issue before proposing a substantial change
to the analysis model, input schema, or benchmark protocol.

## Core requirements

- Do not describe docking scores or rank stability as evidence of binding,
  biological activity, efficacy, or clinical utility.
- Keep source data, derived results, executable binaries, and environments out
  of Git unless their licence and provenance permit redistribution.
- Record software versions, input hashes, random seeds, receptor preparation,
  ligand preparation, search-space definition, and all failures.
- Do not alter a prespecified protocol after its execution has begun. Propose a
  new protocol revision instead.
- Add tests and run `devtools::document()`, `devtools::test()`, and an R CMD
  check before requesting review.

## Reporting a problem

Please include a minimal reproducible input table, the package version, the R
version, and the expected and observed behaviour. Do not attach confidential
or unlicensed datasets.
