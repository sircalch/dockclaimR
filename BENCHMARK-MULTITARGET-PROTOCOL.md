# Prespecified DUD-E multiblanco stability study

## Aim

Evaluate, descriptively, whether seed-level rank stability observed in the ADA
workflow-validation pilot is similar across three distinct DUD-E enzyme targets.
This is a computational reproducibility study, not a study of biological
activity, binding affinity, or drug discovery performance.

## Targets and source

The following DUD-E targets will be analysed separately:

| Target | DUD-E code | PDB | DUD-E substances |
| --- | --- | --- | --- |
| Adenosine deaminase | ADA | 2e1w | 98 |
| Beta-lactamase | AMPC | 1l2s | 48 |
| Catechol O-methyltransferase | COMT | 3bwm | 41 |

DUD-E provides the inputs target-by-target. Each source archive and every
derived file will receive a SHA-256 record before analysis. Cite DUD-E as
Mysinger et al. (2012), https://doi.org/10.1021/jm300687e.

## Source acquisition record

The following original DUD-E archives were retrieved before target-specific
preparation or docking on 2026-08-07. These records do not constitute results.

| Target | Archive | SHA-256 |
| --- | --- | --- |
| AMPC | `ampc.tar.gz` | `886B31A35FA5D1E68051F543853A7C43FEA14127B7C35EB8D626E4874BBA3763` |
| COMT | `comt.tar.gz` | `545F5778D007536741CD05D2F8C855318588C3956AC8A55F1559DB031D3709FD` |

## Frozen design

For each target:

1. Select six actives and 18 decoys using the deterministic SHA-256 selection
   rule implemented for the ADA pilot. If a target has fewer than six usable
   actives after preparation, stop and revise the protocol before docking.
2. Prepare the receptor and ligands with the recorded versions of Open Babel
   and Meeko. Preserve warnings and failures.
3. Define the search space from the supplied crystal ligand with 5 Å padding.
4. Run AutoDock Vina 1.2.7 at exhaustiveness 4, three modes, and seeds 1001,
   2002, and 3003.
5. Require all 72 target-specific runs to complete before producing a target
   summary. No failed run is replaced silently.

## Outcomes fixed before execution

For each target, report:

- all three pairwise Spearman rank correlations across seeds;
- the number and proportion of ligand instances that remain top-1 and top-5 in
  all three seeds;
- the complete run table, manifest, selection map, logs, poses, tool hashes,
  and preparation warnings.

Target-specific values will be shown separately. No pooled effect, success
threshold, or comparison with activity labels is planned for this small study.

## Interpretation boundary

Even complete agreement across seeds would demonstrate only stability under
this exact receptor preparation, search box, engine, and parameter set. It
would not validate the scoring function, establish biochemical binding, or
identify a bioactive compound.

## Execution record and descriptive results

The frozen execution completed on 2026-08-07. Each target produced 72/72
successful runs (24 selected ligand instances by three fixed seeds). The
following target-specific values are descriptive outputs of this exact
workflow; they are neither activity labels nor a measure of docking or
screening performance.

| Target | Spearman rho across seed pairs | Top-1 in all three seeds | Top-5 in all three seeds |
| --- | --- | ---: | ---: |
| ADA | 0.9704, 0.9748, 0.9817 | 0/24 | 4/24 |
| AMPC | 0.9852, 0.9870, 0.9983 | 0/24 | 0/24 |
| COMT | 0.9296, 0.9467, 0.9746 | 0/24 | 0/24 |

The complete target-specific selection maps, run tables, manifests, docking
logs, poses, preparation warnings, and derived summaries are retained locally
outside version control. Their source archives and the protocol above provide
the reproducibility record; no claim is made from unshared binary outputs.
