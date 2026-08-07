# Archival scope and third-party material policy

## Scope of a future dockclaimR archive

A future Zenodo software record may include the versioned R package source,
tests, vignettes, workflow scripts, manually authored protocols, citation
metadata, and documentation produced by this project.

## Excluded material

The archive must exclude DUD-E source archives and their contents, including
receptors, crystal ligands, active and decoy structures, selection files,
prepared PDBQT files, docking poses, logs, and derived run tables. It must
also exclude AutoDock Vina executables and local Python/R environments.

DUD-E states that it is free to use and requests citation, but its target pages
do not state a redistribution licence for the downloaded material. Exclusion is
therefore the conservative default. Users can obtain the original inputs from
DUD-E and regenerate local artefacts with the documented workflow.

## Reproduction boundary

The repository records target identifiers, source URLs, archive SHA-256
values, package/tool versions, selection policy, search-space policy, fixed
seeds, and hashes of essential local artefacts. These records support auditing
without claiming that an archive redistributes third-party files.

## Before release

- Recheck the upstream DUD-E terms at the time of deposit.
- Do not add third-party files merely because they are publicly downloadable.
- If the authors later seek permission to redistribute a limited derived
  dataset, record the permission and its terms in a separate archive revision.
