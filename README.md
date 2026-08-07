# dockclaimR

`dockclaimR` is a planned R package for evaluating whether molecular-docking
prioritizations are stable enough to support a stated computational claim.

It does not run docking engines and it does not infer binding or biological
activity from a docking score. Instead, it will consume already generated,
structured docking results and report transparent evidence about rank stability
across repeat runs, receptor conformations, preparation choices, and optional
rescoring methods.

## Status

**Design and protocol stage.** No empirical performance, biological, or
benchmarking claim is made in this repository yet.

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

## Relationship to claimtestR

`claimtestR` is a general framework for executable statistical claims.
`dockclaimR` will be domain-specific: it will define how docking runs become
prespecified stability evidence before a claim is evaluated. The projects will
remain separately versioned and separately cited.

## License and contributions

Licensing, governance, and contribution files will be selected before the first
public code release. Until then, this repository is a research design record.
