# dockclaimR

[![R-CMD-check](https://github.com/sircalch/dockclaimR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sircalch/dockclaimR/actions/workflows/R-CMD-check.yaml)

`dockclaimR` is an experimental R package for evaluating whether molecular-docking
prioritizations are stable enough to support a stated computational claim.

It does not run docking engines and it does not infer binding or biological
activity from a docking score. Instead, it will consume already generated,
structured docking results and report transparent evidence about rank stability
across repeat runs, receptor conformations, preparation choices, and optional
rescoring methods.

## Status

**Experimental prototype (pre-release).** The repository contains a small,
fully documented workflow-validation pilot and synthetic examples. It makes no
claim of biological activity, binding, virtual-screening performance, or
generalizability. The public API and validation scope may change before a
stable release.

## Intended first release

The first release will provide:

- a documented tabular input schema for docking runs;
- provenance checks for engine version, seed, search space, receptor, ligand,
  and scoring method;
- rank-agreement and top-*k* stability summaries across prespecified scenario
  groups;
- explicit, inspectable assertions such as “candidate X remains in the top 5
  across 90% of prespecified runs”;
- a machine-readable report that distinguishes score consistency from evidence
  of molecular binding or experimental efficacy.

## Why this is needed

Docking outputs depend on choices such as target preparation, search-space
definition, sampling settings, and scoring. Responsible reporting requires
those inputs and a validation strategy to be visible, rather than treating one
lowest score as a definitive result. `dockclaimR` is intended as an analysis
layer for that reporting and sensitivity problem.

## Planned validation

The validation protocol is defined before implementation in
[PROJECT-CHARTER.md](PROJECT-CHARTER.md). Benchmark results will be added only
after the scripts, inputs, software versions, and outputs can be released.

## Minimal synthetic example

The example below is deliberately synthetic: its values are not docking
results and must not be interpreted as molecular evidence.

```r
library(dockclaimR)

runs <- data.frame(
  ligand_id = rep(c("candidate_a", "candidate_b", "candidate_c"), 2),
  scenario_id = rep(c("seed_1", "seed_2"), each = 3),
  score = c(-8.1, -7.4, -6.8, -7.8, -8.3, -6.5)
)

stability <- summarise_top_k_stability(runs, top_k = 1)
assess_top_k_stability(stability, threshold = 0.90)
```

The output reports only whether a ligand met the declared ranking criterion in
the supplied scenarios. It does not claim that the ligand binds a target.

## Provenance manifest

Real analyses must be accompanied by a complete one-row manifest before the
run table is assessed. The manifest records the engine and version, receptor,
search space, score direction, ligand preparation, scenario definition, seed
policy, run-table path, and creation time.

```r
manifest <- docking_manifest_template()
manifest[] <- "recorded-before-analysis"
manifest$score_direction <- "lower"
validate_docking_manifest(manifest)
```

The template does not verify whether reported choices are scientifically
appropriate. It ensures that omissions are visible rather than silently
accepted.

## Benchmark development record

The first workflow-validation pilot uses the public ADA target from DUD-E. Its
scope, frozen sampling procedure, tool versions, hashes, and interpretation
limits are documented in [BENCHMARK-ADA-PROTOCOL.md](BENCHMARK-ADA-PROTOCOL.md).
Derived data, docking poses, executable binaries, and environments are kept out
of version control; their provenance is recorded by the protocol and manifest.

A prespecified three-target extension is documented in
[BENCHMARK-MULTITARGET-PROTOCOL.md](BENCHMARK-MULTITARGET-PROTOCOL.md). It has
not been executed or interpreted yet.

## Relationship to claimtestR

`claimtestR` is a general framework for executable statistical claims.
`dockclaimR` will be domain-specific: it will define how docking runs become
prespecified stability evidence before a claim is evaluated. The projects will
remain separately versioned and separately cited.

## License and contributions

This prototype is released under the [MIT License](LICENSE.md). Contributions
and reuse should preserve the provenance and interpretation limits documented
in the benchmark protocols.

## Citation

Until a versioned archival record exists, cite the exact Git commit or package
version used and the repository URL. The repository includes both
[`CITATION.cff`](CITATION.cff) and the R-package citation metadata available
through `citation("dockclaimR")` after installation. A DOI will be added only
for a frozen, validated release.

The future archive will exclude DUD-E inputs and generated docking artefacts;
see [ARCHIVE-POLICY.md](ARCHIVE-POLICY.md) for the third-party material policy.
