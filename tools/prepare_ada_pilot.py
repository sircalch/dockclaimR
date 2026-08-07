"""Create a deterministic, small DUD-E ADA pilot set for workflow testing.

This script is not an enrichment benchmark and does not estimate biological
activity. It selects a fixed stratified subset solely to exercise the docking
provenance and rank-stability workflow before a larger benchmark is designed.
"""

from __future__ import annotations

import argparse
import csv
import gzip
import hashlib
from pathlib import Path

from rdkit import Chem


def stable_records(path: Path, class_label: str) -> list[dict]:
    """Return molecules in a deterministic order independent of SDF order."""
    records = []
    if path.suffix == ".gz":
        handle = gzip.open(path, "rb")
        supplier = Chem.ForwardSDMolSupplier(handle, removeHs=False)
    else:
        handle = None
        supplier = Chem.SDMolSupplier(str(path), removeHs=False)
    try:
        iterator = enumerate(supplier)
        for index, molecule in iterator:
            if molecule is None:
                raise ValueError(f"Could not read molecule {index} from {path}")
            name = molecule.GetProp("_Name") if molecule.HasProp("_Name") else f"{class_label}_{index:05d}"
            canonical_smiles = Chem.MolToSmiles(molecule, canonical=True)
            token = hashlib.sha256(
                f"ADA|{class_label}|{name}|{canonical_smiles}".encode("utf-8")
            ).hexdigest()
            records.append(
                {
                    "ligand_id": name,
                    "class_label": class_label,
                    "selection_hash": token,
                    "molecule": molecule,
                }
            )
    finally:
        if handle is not None:
            handle.close()
    return sorted(records, key=lambda record: record["selection_hash"])


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--actives", type=Path, required=True)
    parser.add_argument("--decoys", type=Path, required=True)
    parser.add_argument("--output-sdf", type=Path, required=True)
    parser.add_argument("--selection-csv", type=Path, required=True)
    parser.add_argument("--n-actives", type=int, default=6)
    parser.add_argument("--n-decoys", type=int, default=18)
    args = parser.parse_args()

    if args.n_actives < 1 or args.n_decoys < 1:
        raise ValueError("Both pilot class counts must be positive.")

    selected = (
        stable_records(args.actives, "active")[: args.n_actives]
        + stable_records(args.decoys, "decoy")[: args.n_decoys]
    )
    if len(selected) != args.n_actives + args.n_decoys:
        raise ValueError("The requested pilot exceeds available input molecules.")

    args.output_sdf.parent.mkdir(parents=True, exist_ok=True)
    args.selection_csv.parent.mkdir(parents=True, exist_ok=True)
    writer = Chem.SDWriter(str(args.output_sdf))
    try:
        for record in selected:
            molecule = record["molecule"]
            molecule.SetProp("dockclaimR_ligand_id", record["ligand_id"])
            molecule.SetProp("dockclaimR_class", record["class_label"])
            writer.write(molecule)
    finally:
        writer.close()

    with args.selection_csv.open("w", newline="", encoding="utf-8") as handle:
        fields = ["pilot_index", "ligand_id", "class_label", "selection_hash"]
        output = csv.DictWriter(handle, fieldnames=fields)
        output.writeheader()
        for index, record in enumerate(selected, start=1):
            row = {field: record[field] for field in fields if field != "pilot_index"}
            row["pilot_index"] = index
            output.writerow(row)


if __name__ == "__main__":
    main()
