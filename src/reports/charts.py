#!/usr/bin/env python3

from __future__ import annotations

import argparse
import csv
import json
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


def load_commits(csv_path: Path) -> tuple[Counter[str], Counter[str]]:
    months: Counter[str] = Counter()
    years: Counter[str] = Counter()
    if not csv_path.is_file():
        return months, years
    with csv_path.open("r", newline="", encoding="utf-8") as source:
        for row in csv.DictReader(source):
            date = (row.get("Date") or "").strip()
            if len(date) >= 7:
                months[date[:7]] += 1
                years[date[:4]] += 1
    return months, years


def load_analysis(path: Path | None) -> dict[str, Any]:
    if path is None or not path.is_file():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    return data.get("generic_analysis", data)


def _plt():
    import matplotlib.pyplot as plt
    return plt


def save_bar(labels: list[str], values: list[int | float], title: str, ylabel: str, output: Path) -> None:
    if not labels:
        return
    plt = _plt()
    plt.figure(figsize=(max(9.0, min(22.0, len(labels) * 0.55)), 5.5))
    plt.bar(labels, values, color="#4c78a8")
    plt.title(title)
    plt.ylabel(ylabel)
    plt.xticks(rotation=60, ha="right")
    plt.tight_layout()
    plt.savefig(output, dpi=160)
    plt.close()


def save_horizontal(labels: list[str], values: list[int | float], title: str, xlabel: str, output: Path) -> None:
    if not labels:
        return
    plt = _plt()
    labels, values = labels[::-1], values[::-1]
    plt.figure(figsize=(11, max(5.5, len(labels) * 0.42)))
    plt.barh(labels, values, color="#4c78a8")
    plt.title(title)
    plt.xlabel(xlabel)
    plt.tight_layout()
    plt.savefig(output, dpi=160)
    plt.close()


def churn_chart(git_data: dict[str, Any], output: Path) -> None:
    monthly: dict[str, Counter[str]] = defaultdict(Counter)
    for item in git_data.get("technical_impact", {}).get("contributions", []):
        month = str(item.get("date", ""))[:7]
        if len(month) == 7:
            monthly[month]["additions"] += item.get("touched", {}).get("additions", 0)
            monthly[month]["deletions"] += item.get("touched", {}).get("deletions", 0)
    if not monthly:
        return
    plt = _plt()
    labels = sorted(monthly)
    additions = [monthly[key]["additions"] for key in labels]
    deletions = [monthly[key]["deletions"] for key in labels]
    plt.figure(figsize=(max(10, min(22, len(labels) * 0.6)), 5.8))
    plt.bar(labels, additions, label="Added", color="#2ca02c")
    plt.bar(labels, [-value for value in deletions], label="Removed", color="#d62728")
    plt.axhline(0, color="#667085", linewidth=0.8)
    plt.title("Code Churn by Month")
    plt.ylabel("Lines added / removed")
    plt.xticks(rotation=60, ha="right")
    plt.legend()
    plt.tight_layout()
    plt.savefig(output, dpi=160)
    plt.close()


def system_evolution_chart(git_data: dict[str, Any], output: Path) -> None:
    evolution = git_data.get("system_evolution", {})
    months = sorted({month for periods in evolution.values() for month in periods})
    systems = sorted(evolution, key=lambda name: sum(evolution[name].values()), reverse=True)[:10]
    if not months or not systems:
        return
    plt = _plt()
    plt.figure(figsize=(max(10, min(22, len(months) * 0.6)), 6.2))
    for system in systems:
        plt.plot(months, [evolution[system].get(month, 0) for month in months], marker="o", label=system)
    plt.title("System Evolution by Month")
    plt.ylabel("Commits touching system")
    plt.xticks(rotation=60, ha="right")
    plt.legend(fontsize=8, ncol=2)
    plt.tight_layout()
    plt.savefig(output, dpi=160)
    plt.close()


def architecture_evolution_chart(git_data: dict[str, Any], output: Path) -> None:
    monthly: dict[str, Counter[str]] = defaultdict(Counter)
    for item in git_data.get("technical_impact", {}).get("contributions", []):
        month = str(item.get("date", ""))[:7]
        if len(month) != 7:
            continue
        monthly[month]["complexity_delta"] += item.get("delta", {}).get("estimated_complexity", 0)
        signals = set(item.get("signals", []))
        monthly[month]["structural_changes"] += len(signals & {"dependencies_changed", "configuration_changed", "refactor_candidate"})
    if not monthly:
        return
    plt = _plt()
    labels = sorted(monthly)
    complexity = [monthly[key]["complexity_delta"] for key in labels]
    structural = [monthly[key]["structural_changes"] for key in labels]
    figure, left = plt.subplots(figsize=(max(10, min(22, len(labels) * 0.6)), 6.0))
    left.bar(labels, complexity, color="#4c78a8", alpha=0.8, label="Estimated complexity delta")
    left.set_ylabel("Estimated complexity delta")
    left.axhline(0, color="#667085", linewidth=0.8)
    right = left.twinx()
    right.plot(labels, structural, color="#f58518", marker="o", label="Structural change signals")
    right.set_ylabel("Dependency/config/refactor signals")
    left.set_title("Architecture-related Change Signals over Time")
    left.tick_params(axis="x", rotation=60)
    figure.tight_layout()
    figure.savefig(output, dpi=160)
    plt.close(figure)


def analysis_charts(analysis: dict[str, Any], output_dir: Path) -> None:
    git_data = analysis.get("git", {})
    insights = analysis.get("analysis", {})
    hotspots = git_data.get("hotspots", [])[:20]
    save_horizontal(
        [item["path"] for item in hotspots], [item.get("score", 0) for item in hotspots],
        "Composite Hotspots", "Composite score", output_dir / "hotspots.png",
    )
    systems = insights.get("systems", [])[:20]
    save_horizontal(
        [item["name"] for item in systems], [item.get("file_count", 0) for item in systems],
        "Detected Systems by Source Files", "Source files", output_dir / "systems.png",
    )
    contributors = git_data.get("contributors", [])[:20]
    save_horizontal(
        [item["name"] for item in contributors], [item.get("commits", 0) for item in contributors],
        "Commits by Author", "Commits in selected scope", output_dir / "authors.png",
    )
    churn_chart(git_data, output_dir / "churn_by_month.png")
    system_evolution_chart(git_data, output_dir / "system_evolution.png")
    architecture_evolution_chart(git_data, output_dir / "architecture_evolution.png")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("commits_csv", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--analysis-json", type=Path)
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    months, years = load_commits(args.commits_csv)
    save_bar(sorted(months), [months[key] for key in sorted(months)], "Commits by Month", "Commits", args.output_dir / "commits_by_month.png")
    save_bar(sorted(years), [years[key] for key in sorted(years)], "Commits by Year", "Commits", args.output_dir / "commits_by_year.png")
    analysis = load_analysis(args.analysis_json)
    if analysis:
        analysis_charts(analysis, args.output_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
