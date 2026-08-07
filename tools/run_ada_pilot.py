"""Run a frozen DUD-E target subset and write one auditable row per ligand and seed."""

from __future__ import annotations

import argparse
import csv
import re
import subprocess
from pathlib import Path


BEST_MODE = re.compile(r"^\s*1\s+(-?\d+(?:\.\d+)?)\s+", re.MULTILINE)


def write_run_table(path: Path, rows: list[dict]) -> None:
    """Persist completed and resumed rows after each docking attempt."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        fields = list(rows[0])
        output = csv.DictWriter(handle, fieldnames=fields)
        output.writeheader()
        output.writerows(rows)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--vina", type=Path, required=True)
    parser.add_argument("--receptor", type=Path, required=True)
    parser.add_argument("--ligand-dir", type=Path, required=True)
    parser.add_argument("--selection-csv", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--run-table", type=Path, required=True)
    parser.add_argument("--target-code", default="ADA")
    parser.add_argument("--ligand-prefix", default="ada_pilot")
    parser.add_argument("--center", type=float, nargs=3, required=True)
    parser.add_argument("--size", type=float, nargs=3, required=True)
    parser.add_argument("--seeds", type=int, nargs="+", default=[1001, 2002, 3003])
    parser.add_argument("--exhaustiveness", type=int, default=4)
    parser.add_argument("--num-modes", type=int, default=3)
    args = parser.parse_args()

    args.output_dir.mkdir(parents=True, exist_ok=True)
    rows = []
    with args.selection_csv.open(newline="", encoding="utf-8") as handle:
        selection = list(csv.DictReader(handle))

    for record in selection:
        index = int(record["pilot_index"])
        ligand = args.ligand_dir / f"{args.ligand_prefix}-{index}.pdbqt"
        if not ligand.exists():
            raise FileNotFoundError(f"Missing prepared ligand: {ligand}")
        for seed in args.seeds:
            stem = f"pilot_{index:02d}_seed_{seed}"
            pose = args.output_dir / f"{stem}.pdbqt"
            log = args.output_dir / f"{stem}.log"
            if pose.exists() and log.exists() and (match := BEST_MODE.search(log.read_text(encoding="utf-8"))):
                returncode = 0
            else:
                command = [
                    str(args.vina), "--receptor", str(args.receptor),
                    "--ligand", str(ligand),
                    "--center_x", str(args.center[0]), "--center_y", str(args.center[1]),
                    "--center_z", str(args.center[2]), "--size_x", str(args.size[0]),
                    "--size_y", str(args.size[1]), "--size_z", str(args.size[2]),
                    "--seed", str(seed), "--exhaustiveness", str(args.exhaustiveness),
                    "--num_modes", str(args.num_modes), "--out", str(pose),
                ]
                completed = subprocess.run(command, text=True, capture_output=True, check=False)
                log.write_text(completed.stdout + completed.stderr, encoding="utf-8")
                match = BEST_MODE.search(completed.stdout)
                returncode = completed.returncode
            rows.append(
                {
                    "ligand_id": f"{args.target_code.lower()}_pilot_{index:02d}",
                    "source_ligand_id": record["ligand_id"],
                    "scenario_id": f"seed_{seed}",
                    "score": match.group(1) if match and returncode == 0 else "",
                    "engine": "AutoDock Vina",
                    "engine_version": "1.2.7",
                    "receptor_id": f"DUD-E {args.target_code.upper()} receptor.pdb converted with Open Babel 3.1.0",
                    "search_space_id": "crystal_ligand_bbox_plus_5A",
                    "seed": seed,
                    "scoring_method": "vina",
                    "class_label": record["class_label"],
                    "pilot_index": index,
                    "status": "success" if match and returncode == 0 else "failed",
                    "log_path": str(log),
                }
            )
            write_run_table(args.run_table, rows)

    failures = [row for row in rows if row["status"] != "success"]
    if failures:
        raise RuntimeError(f"{len(failures)} docking runs failed; inspect the run table and logs.")


if __name__ == "__main__":
    main()
