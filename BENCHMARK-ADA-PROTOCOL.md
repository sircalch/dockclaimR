# ADA pilot: reproducible docking workflow check

## Purpose

This is a small workflow-validation pilot for `dockclaimR`, not a performance
benchmark and not a biological study. It will test whether a prespecified
ranking is stable across three random seeds for a fixed docking configuration.
No statement of binding, activity, clinical relevance, or superiority is in
scope.

## Public source data

- Dataset: DUD-E target ADA (adenosine deaminase), PDB structure `2e1w`.
- Download: https://dude.docking.org/targets/ada/ada.tar.gz
- Download date: 2026-08-07.
- Archive SHA-256:
  `333B9A0DD9D56CFF6E622E7BC72D72F92D2EA68614571A65E34B5499B49029E2`.
- Dataset citation: Mysinger et al. (2012),
  https://doi.org/10.1021/jm300687e.

ADA was chosen because DUD-E lists 98 source substances and 93 clustered
substances, allowing a small, traceable pilot before a larger study.

## Frozen pilot design

1. Select six actives and 18 decoys deterministically using
   `tools/prepare_ada_pilot.py`; selection is sorted by a SHA-256 token built
   from the source class, DUD-E identifier, and canonical SMILES.
2. Prepare each selected ligand with Meeko 0.7.1 and retain one PDBQT file per
   ligand. Preparation failures are recorded, never silently omitted.
3. Convert the DUD-E receptor with Open Babel 3.1.0 because its legacy PDB
   records omit the element columns required by Meeko. The conversion warnings
   and output checksum are retained.
4. Center the search box on the supplied crystal ligand, with a 5 Å padding.
5. Run AutoDock Vina 1.2.7 at exhaustiveness 4, three modes, and seeds 1001,
   2002, and 3003.
6. Store one row per ligand and seed in the `dockclaimR` run-table contract;
   derive stability only after the manifest validates.

The source data contain a repeated ligand label. Each selected record therefore
receives a unique `ada_pilot_XX` analysis identifier; the original DUD-E label
is retained as `source_ligand_id`.

## Tool record

- AutoDock Vina 1.2.7 binary SHA-256:
  `E0C4B2715E0C1A74F6E92D0F3BE0328AC97542EAFBC111E6B1EFAD897A73CCE5`.
- Python environment dependencies: `tools/requirements-docking.txt`.
- The first crystal-ligand run completed successfully on 2026-08-07. It is a
  technical smoke test only; its score and pose are not a benchmark result.

## Interpretation boundary

The pilot will describe reproducibility of rankings within this exact setup.
It will not estimate virtual-screening performance, because the deliberately
small stratified subset is not representative of the full DUD-E target set.
Its top-k summaries are descriptive because the pilot threshold was not
preregistered before execution.
