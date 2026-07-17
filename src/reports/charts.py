#!/usr/bin/env python3

from __future__ import annotations

import argparse
import csv
from collections import Counter
from pathlib import Path


def load_commits(csv_path: Path) -> tuple[Counter[str], Counter[str]]:
    months: Counter[str] = Counter()
    years: Counter[str] = Counter()
    with csv_path.open("r", newline="", encoding="utf-8") as source:
        for row in csv.DictReader(source):
            date = (row.get("Date") or "").strip()
            if len(date) >= 7:
                months[date[:7]] += 1
                years[date[:4]] += 1
    return months, years


def save_chart(labels: list[str], values: list[int], title: str, output: Path) -> None:
    import matplotlib.pyplot as plt
    if not labels:
        return
    plt.figure(figsize=(max(9.0, min(22.0, len(labels) * 0.55)), 5.5))
    plt.bar(labels, values)
    plt.title(title)
    plt.xlabel("Period")
    plt.ylabel("Commits")
    plt.xticks(rotation=60, ha="right")
    plt.tight_layout()
    plt.savefig(output, dpi=160)
    plt.close()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("commits_csv", type=Path)
    parser.add_argument("output_dir", type=Path)
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    months, years = load_commits(args.commits_csv)
    save_chart(sorted(months), [months[key] for key in sorted(months)], "Commits by Month", args.output_dir / "commits_by_month.png")
    save_chart(sorted(years), [years[key] for key in sorted(years)], "Commits by Year", args.output_dir / "commits_by_year.png")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
