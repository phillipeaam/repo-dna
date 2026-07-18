#!/usr/bin/env python3

"""Finalize and expose the canonical RepoDNA analysis model."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


METRIC_KEYS = (
    "technology_count",
    "dependency_count",
    "system_count",
    "configuration_file_count",
    "test_file_count",
)


def canonical_metrics(report: dict[str, Any]) -> dict[str, int]:
    generic = report.get("generic_analysis", {})
    analysis = generic.get("analysis", {})
    inventory = generic.get("technology_inventory", {})
    return {
        "technology_count": int(inventory.get("technology_count", 0) or 0),
        "dependency_count": int(generic.get("dependencies", {}).get("total", 0) or 0),
        "system_count": len(analysis.get("systems", [])),
        "configuration_file_count": int(generic.get("configuration_file_count", 0) or 0),
        "test_file_count": int(generic.get("test_file_count", 0) or 0),
    }


def finalize(report: dict[str, Any]) -> dict[str, Any]:
    generic = report.get("generic_analysis", {})
    analysis = generic.get("analysis", {})
    profile = report.get("analysis_profile", {})
    specialized = {}
    for name in ("unity", "android", "flutter", "godot", "unreal"):
        value = analysis.pop(name, None)
        if profile.get(name) and value is not None:
            specialized[name] = value
    generic["$schema"] = "./generic-analysis-core-1.0.0.schema.json"
    generic["schema_version"] = "1.0"
    report["specialized_analysis"] = specialized
    report["canonical_metrics"] = canonical_metrics(report)
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=Path)
    args = parser.parse_args()
    report = finalize(json.loads(args.report.read_text(encoding="utf-8")))
    args.report.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
