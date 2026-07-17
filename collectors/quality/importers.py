"""Normalize coverage, test, linter, and security scanner reports."""

from __future__ import annotations

import json
import re
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path
from typing import Any, Callable


MAX_REPORT_BYTES = 25_000_000
SKIP_PARTS = {".git", "node_modules", "vendor", "library", "temp", "__pycache__"}


def _read_json(path: Path) -> Any:
    if path.stat().st_size > MAX_REPORT_BYTES:
        raise ValueError("report exceeds 25 MB safety limit")
    return json.loads(path.read_text(encoding="utf-8", errors="replace"))


def _xml(path: Path) -> ET.Element:
    if path.stat().st_size > MAX_REPORT_BYTES:
        raise ValueError("report exceeds 25 MB safety limit")
    return ET.parse(path).getroot()


def _relative(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def _find(root: Path, names: set[str], patterns: tuple[str, ...] = ()) -> list[Path]:
    found: set[Path] = set()
    for name in names:
        path = root / name
        if path.is_file():
            found.add(path)
    for pattern in patterns:
        for path in root.glob(pattern):
            if path.is_file() and not (set(part.casefold() for part in path.relative_to(root).parts) & SKIP_PARTS):
                found.add(path)
            if len(found) >= 100:
                break
    return sorted(found)[:100]


def _percentage(covered: int | float | None, total: int | float | None) -> float | None:
    return round(float(covered) / float(total) * 100, 2) if covered is not None and total else None


def _coverage(root: Path) -> dict[str, Any]:
    reports: list[dict[str, Any]] = []
    errors: list[dict[str, str]] = []
    candidates = _find(root, {"coverage-summary.json", "coverage/coverage-summary.json", "coverage.xml", "jacoco.xml", "lcov.info", "coverage/lcov.info"}, ("**/coverage-summary.json", "**/coverage.xml", "**/jacoco.xml", "**/lcov.info"))
    for path in candidates:
        try:
            name = path.name.casefold()
            metrics: dict[str, Any] = {}
            tool = "unknown"
            if name == "coverage-summary.json":
                data = _read_json(path).get("total", {})
                tool = "Istanbul"
                for key in ("lines", "statements", "functions", "branches"):
                    item = data.get(key, {})
                    metrics[key] = {"covered": item.get("covered"), "total": item.get("total"), "percent": item.get("pct")}
            elif name == "lcov.info":
                text = path.read_text(encoding="utf-8", errors="replace")
                values = {key: sum(int(value) for value in re.findall(rf"^{key}:(\d+)$", text, re.M)) for key in ("LF", "LH", "BRF", "BRH", "FNF", "FNH")}
                tool = "LCOV"
                metrics = {
                    "lines": {"covered": values["LH"], "total": values["LF"], "percent": _percentage(values["LH"], values["LF"])},
                    "branches": {"covered": values["BRH"], "total": values["BRF"], "percent": _percentage(values["BRH"], values["BRF"])},
                    "functions": {"covered": values["FNH"], "total": values["FNF"], "percent": _percentage(values["FNH"], values["FNF"])},
                }
            else:
                document = _xml(path)
                if document.tag.endswith("report") and document.findall(".//counter"):
                    tool = "JaCoCo"
                    for counter in document.findall("./counter"):
                        key = counter.attrib.get("type", "").casefold()
                        covered, missed = int(counter.attrib.get("covered", 0)), int(counter.attrib.get("missed", 0))
                        metrics[key] = {"covered": covered, "total": covered + missed, "percent": _percentage(covered, covered + missed)}
                else:
                    tool = "Cobertura"
                    line_rate = document.attrib.get("line-rate")
                    branch_rate = document.attrib.get("branch-rate")
                    metrics["lines"] = {"covered": int(document.attrib.get("lines-covered", 0)), "total": int(document.attrib.get("lines-valid", 0)), "percent": round(float(line_rate) * 100, 2) if line_rate is not None else None}
                    metrics["branches"] = {"covered": int(document.attrib.get("branches-covered", 0)), "total": int(document.attrib.get("branches-valid", 0)), "percent": round(float(branch_rate) * 100, 2) if branch_rate is not None else None}
            reports.append({"path": _relative(root, path), "tool": tool, "metrics": metrics})
        except (OSError, ValueError, TypeError, ET.ParseError) as error:
            errors.append({"path": _relative(root, path), "error": str(error)})
    line_percentages = [item["metrics"].get("lines", {}).get("percent") for item in reports]
    line_percentages = [value for value in line_percentages if value is not None]
    return {
        "status": "imported" if reports else "invalid" if errors else "not_found",
        "line_coverage_percent": round(sum(line_percentages) / len(line_percentages), 2) if line_percentages else None,
        "reports": reports, "evidence_files": [item["path"] for item in reports], "parse_errors": errors,
        "note": "Coverage metrics are imported from existing reports; RepoDNA does not execute the test suite.",
    }


def _tests(root: Path) -> dict[str, Any]:
    reports: list[dict[str, Any]] = []
    errors: list[dict[str, str]] = []
    candidates = _find(root, {"junit.xml", "test-results.xml", "jest-results.json", "pytest-report.json"}, ("**/TEST-*.xml", "**/junit*.xml", "**/jest-results.json", "**/pytest-report.json"))
    for path in candidates:
        try:
            if path.suffix.casefold() == ".xml":
                document = _xml(path)
                suites = [document] if document.tag.endswith("testsuite") else list(document.findall(".//testsuite"))
                total = sum(int(item.attrib.get("tests", 0)) for item in suites)
                failed = sum(int(item.attrib.get("failures", 0)) for item in suites)
                errors_count = sum(int(item.attrib.get("errors", 0)) for item in suites)
                skipped = sum(int(item.attrib.get("skipped", item.attrib.get("disabled", 0))) for item in suites)
                duration = sum(float(item.attrib.get("time", 0) or 0) for item in suites)
                tool = "JUnit XML"
            else:
                data = _read_json(path)
                if "numTotalTests" in data:
                    tool, total, failed, skipped = "Jest", int(data.get("numTotalTests", 0)), int(data.get("numFailedTests", 0)), int(data.get("numPendingTests", 0))
                    errors_count, duration = 0, None
                else:
                    summary = data.get("summary", data)
                    tool = "pytest-json-report"
                    total = int(summary.get("total", summary.get("collected", 0)))
                    failed, skipped = int(summary.get("failed", 0)), int(summary.get("skipped", 0))
                    errors_count, duration = int(summary.get("error", summary.get("errors", 0))), data.get("duration")
            passed = max(total - failed - errors_count - skipped, 0)
            reports.append({"path": _relative(root, path), "tool": tool, "total": total, "passed": passed, "failed": failed, "errors": errors_count, "skipped": skipped, "duration_seconds": duration})
        except (OSError, ValueError, TypeError, ET.ParseError) as error:
            errors.append({"path": _relative(root, path), "error": str(error)})
    totals = Counter()
    for report in reports:
        for key in ("total", "passed", "failed", "errors", "skipped"):
            totals[key] += report[key]
    return {"status": "imported" if reports else "invalid" if errors else "not_found", **dict(totals), "reports": reports, "parse_errors": errors, "note": "Test outcomes are imported artifacts, not a test execution performed by RepoDNA."}


def _severity(value: str | int | None) -> str:
    if isinstance(value, int):
        return "error" if value >= 2 else "warning"
    lowered = str(value or "unknown").casefold()
    return {"fatal": "critical", "err": "error", "warn": "warning", "moderate": "medium"}.get(lowered, lowered)


def _linters(root: Path) -> dict[str, Any]:
    reports: list[dict[str, Any]] = []
    errors: list[dict[str, str]] = []
    candidates = _find(root, {"eslint-report.json", "ruff-report.json", "checkstyle-result.xml", "lint-results.sarif"}, ("**/eslint-report.json", "**/ruff-report.json", "**/checkstyle-result.xml", "**/lint-results.sarif"))
    for path in candidates:
        try:
            severities: Counter[str] = Counter()
            files: set[str] = set()
            name = path.name.casefold()
            if name.endswith(".sarif"):
                data = _read_json(path)
                tool = "SARIF"
                for run in data.get("runs", []):
                    tool = run.get("tool", {}).get("driver", {}).get("name", tool)
                    for result in run.get("results", []):
                        severities[_severity(result.get("level"))] += 1
                        uri = result.get("locations", [{}])[0].get("physicalLocation", {}).get("artifactLocation", {}).get("uri")
                        if uri:
                            files.add(uri)
            elif path.suffix.casefold() == ".xml":
                tool = "Checkstyle"
                for file_node in _xml(path).findall(".//file"):
                    for issue in file_node.findall("error"):
                        severities[_severity(issue.attrib.get("severity"))] += 1
                        files.add(file_node.attrib.get("name", ""))
            else:
                data = _read_json(path)
                if name == "eslint-report.json" or (isinstance(data, list) and data and isinstance(data[0], dict) and "messages" in data[0]):
                    tool = "ESLint"
                    for file_result in data:
                        for issue in file_result.get("messages", []):
                            severities[_severity(issue.get("severity"))] += 1
                        if file_result.get("messages"):
                            files.add(file_result.get("filePath", ""))
                else:
                    tool = "Ruff"
                    for issue in data if isinstance(data, list) else []:
                        severities["error"] += 1
                        if issue.get("filename"):
                            files.add(issue["filename"])
            reports.append({"path": _relative(root, path), "tool": tool, "issues": sum(severities.values()), "severities": dict(severities), "affected_files": len(files)})
        except (OSError, ValueError, TypeError, ET.ParseError) as error:
            errors.append({"path": _relative(root, path), "error": str(error)})
    combined = Counter()
    for report in reports:
        combined.update(report["severities"])
    return {"status": "imported" if reports else "invalid" if errors else "not_found", "issues": sum(combined.values()), "severities": dict(combined), "reports": reports, "parse_errors": errors, "note": "Linter findings are imported without source snippets or diagnostic message content."}


def _scanners(root: Path, manifest_count: int) -> dict[str, Any]:
    reports: list[dict[str, Any]] = []
    errors: list[dict[str, str]] = []
    candidates = _find(root, {"npm-audit.json", "pip-audit.json", "osv-results.json", "dependency-check-report.json", "trivy-results.json", "security-results.sarif"}, ("**/npm-audit.json", "**/pip-audit.json", "**/osv-results.json", "**/dependency-check-report.json", "**/trivy-results.json", "**/security-results.sarif"))
    for path in candidates:
        try:
            data = _read_json(path)
            severities: Counter[str] = Counter()
            name = path.name.casefold()
            tool = "Unknown"
            if name == "npm-audit.json":
                tool = "npm audit"
                severities.update({_severity(key): int(value) for key, value in data.get("metadata", {}).get("vulnerabilities", {}).items() if key != "total"})
            elif name == "pip-audit.json":
                tool = "pip-audit"
                for dependency in data.get("dependencies", data if isinstance(data, list) else []):
                    severities["unknown"] += len(dependency.get("vulns", []))
            elif name == "osv-results.json":
                tool = "OSV-Scanner"
                for result in data.get("results", []):
                    for package in result.get("packages", []):
                        severities["unknown"] += len(package.get("vulnerabilities", []))
            elif name == "dependency-check-report.json":
                tool = "OWASP Dependency-Check"
                for dependency in data.get("dependencies", []):
                    for vulnerability in dependency.get("vulnerabilities", []):
                        severities[_severity(vulnerability.get("severity"))] += 1
            elif name == "trivy-results.json":
                tool = "Trivy"
                for result in data.get("Results", []):
                    for finding in [*result.get("Vulnerabilities", []), *result.get("Misconfigurations", []), *result.get("Secrets", [])]:
                        severities[_severity(finding.get("Severity"))] += 1
            else:
                tool = "SARIF"
                for run in data.get("runs", []):
                    tool = run.get("tool", {}).get("driver", {}).get("name", tool)
                    for finding in run.get("results", []):
                        severities[_severity(finding.get("level"))] += 1
            reports.append({"path": _relative(root, path), "tool": tool, "findings": sum(severities.values()), "severities": dict(severities)})
        except (OSError, ValueError, TypeError) as error:
            errors.append({"path": _relative(root, path), "error": str(error)})
    combined = Counter()
    for report in reports:
        combined.update(report["severities"])
    return {"status": "imported" if reports else "invalid" if errors else "not_scanned", "findings": sum(combined.values()) if reports else None, "severities": dict(combined), "scanner_reports": [item["path"] for item in reports], "reports": reports, "parse_errors": errors, "manifests_available": manifest_count, "note": "Security findings are imported and counted without exporting vulnerable values, messages, or source snippets."}


def import_quality_results(root: Path, manifest_count: int) -> dict[str, Any]:
    return {"coverage": _coverage(root), "tests": _tests(root), "linters": _linters(root), "vulnerabilities": _scanners(root, manifest_count)}
