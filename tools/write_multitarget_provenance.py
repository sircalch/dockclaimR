"""Write SHA-256 provenance records for the local DUD-E workflow study.

The manifest records essential inputs and derived summaries without copying
source archives, docking poses, or binary tools into version control.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
from pathlib import Path


TARGETS = ("ada", "ampc", "comt")
DERIVED = (
    "pilot_selection.csv",
    "receptor.pdbqt",
    "crystal_ligand.pdbqt",
    "pilot_runs.csv",
    "pilot_manifest.csv",
    "pilot_runs_normalized.csv",
    "stability_top1.csv",
    "stability_top5.csv",
    "rank_agreement.csv",
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", type=Path, default=Path("."))
    parser.add_argument(
        "--output", type=Path, default=Path("results/multitarget/provenance.csv")
    )
    args = parser.parse_args()
    repo = args.repo.resolve()
    output = args.output if args.output.is_absolute() else repo / args.output
    output.parent.mkdir(parents=True, exist_ok=True)

    rows: list[dict[str, str]] = []
    for target in TARGETS:
        raw = repo / "data" / "raw" / f"dude-{target}" / f"{target}.tar.gz"
        paths = [("source_archive", raw)]
        paths.extend(
            ("derived_output", repo / "data" / "derived" / f"dude-{target}" / name)
            for name in DERIVED
        )
        for category, path in paths:
            if not path.exists():
                raise FileNotFoundError(f"Required {category} is missing: {path}")
            rows.append(
                {
                    "target": target.upper(),
                    "category": category,
                    "path": path.relative_to(repo).as_posix(),
                    "bytes": str(path.stat().st_size),
                    "sha256": sha256(path),
                }
            )

    with output.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote {len(rows)} provenance records to {output}")


if __name__ == "__main__":
    main()
