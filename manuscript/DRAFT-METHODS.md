# Seed-level rank stability in a small three-target molecular docking workflow

## Draft status

Internal methods draft. The wording and interpretation require author review
before circulation or submission. The study reports computational rank
stability only; it does not report binding, biological activity, efficacy, or
virtual-screening performance.

## Abstract

Molecular-docking scores are frequently used to prioritize compounds, yet the
stability of the resulting order under repeated stochastic searches is often
not reported. We developed an auditable workflow implemented in the
experimental R package `dockclaimR` to summarize rank agreement and top-*k*
retention across prespecified docking scenarios. A small descriptive study was
conducted using three DUD-E targets (ADA, AMPC, and COMT). For each target, six
actives and 18 decoys were selected deterministically; 24 ligand instances
were docked with AutoDock Vina 1.2.7 under three fixed random seeds. All 216
planned target-by-seed runs completed. Pairwise Spearman correlations of
ligand ranks ranged from 0.930 to 0.998. Strict top-5 retention across all
three seeds varied by target (4/24 for ADA, 5/24 for AMPC, and 4/24 for COMT).
These descriptive findings show that high global rank agreement can coexist
with limited reproducibility of the highest-ranked set. They do not validate
the scoring function or establish molecular binding or biological activity.

## Introduction

Docking workflows combine choices about receptor preparation, ligand
preparation, search space, scoring, and stochastic search. A single docking
score therefore does not, by itself, document how sensitive a prioritization is
to repeated runs under a fixed workflow. We describe a compact, reproducible
approach for exposing that sensitivity before a stronger computational claim is
made.

The objective was not to benchmark enrichment or to distinguish DUD-E actives
from decoys. Instead, we asked whether ligand ranks produced by repeated runs
of the same workflow were consistent, and whether the same ligand instances
remained in a prespecified top-*k* set.

## Methods

### Inputs and prespecified design

ADA (PDB 2e1w), AMPC (PDB 1l2s), and COMT (PDB 3bwm) were obtained from DUD-E.
For each target, six actives and 18 decoys were selected with a deterministic
SHA-256 ordering rule. Receptors were converted with Open Babel 3.1.0 and
ligands were prepared with Meeko 0.7.1. The docking box was defined from the
supplied crystal ligand with 5 Å padding in each direction.

AutoDock Vina 1.2.7 was run with exhaustiveness 4, three output modes, and
seeds 1001, 2002, and 3003. Each target therefore had 72 planned runs. A
target-level summary was produced only after all 72 runs completed. The input
archives, selection maps, preparation messages, run logs, poses, and manifest
files were retained locally with hashes.

### Outcomes

For each target, the three pairwise Spearman correlations of ranks were
calculated across seeds. We also counted ligand instances that appeared in the
top-1 and top-5 sets in all three seeds. Targets were reported separately;
there was no pooled estimate, threshold test, or activity-label analysis.

## Results

All 216 planned runs completed successfully. Rank correlations were high in
all target-specific comparisons: ADA 0.970–0.982, AMPC 0.985–0.998, and COMT
0.930–0.975. No ligand instance was top-1 across all three seeds for ADA or
COMT; AMPC had one. The corresponding strict top-5 counts were 4/24, 5/24,
and 4/24 for ADA, AMPC, and COMT, respectively.

## Discussion and limitations

The study illustrates an important distinction: agreement across a complete
rank list does not guarantee that a selected short list is unchanged. These
results are conditional on one receptor preparation, search-space definition,
engine version, parameterization, and small deterministic subset per target.
They do not validate docking scores, estimate affinity, establish binding, or
identify bioactive compounds. Future work should evaluate additional receptor
conformations, preparation choices, scoring methods, and independent
experimental measurements.

## Software and data availability

The experimental software, protocol, and result-rendering script are available
at https://github.com/sircalch/dockclaimR. Source inputs are from DUD-E; raw
and derived docking artefacts are not redistributed in the repository. A
versioned archival record should be created only after author review and a
frozen release.

## References

1. Mysinger MM, Carchia M, Irwin JJ, Shoichet BK. Directory of Useful Decoys,
   Enhanced (DUD-E): Better Ligands and Decoys for Better Benchmarking.
   *Journal of Medicinal Chemistry*. 2012;55(14):6582-6594.
   https://doi.org/10.1021/jm300687e
2. Eberhardt J, Santos-Martins D, Tillack AF, Forli S. AutoDock Vina 1.2.0:
   New Docking Methods, Expanded Force Field, and Python Bindings. *Journal
   of Chemical Information and Modeling*. 2021;61(8):3891-3898.
   https://doi.org/10.1021/acs.jcim.1c00203
