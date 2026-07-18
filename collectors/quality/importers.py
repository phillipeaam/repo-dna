"""Normalize coverage, test, linter, and security scanner reports."""

from __future__ import annotations

import json
import re
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path
from typing import Any, Callable
from urllib.parse import unquote


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
        "status": "imported" if reports else "invalid" if errors else "not_observed",
        "message": None if reports else "Coverage artifacts were invalid." if errors else "No coverage artifact was provided or discovered.",
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
    return {"status": "imported" if reports else "invalid" if errors else "not_observed", "message": None if reports else "Test-result artifacts were invalid." if errors else "No test-result artifact was provided or discovered.", **dict(totals), "reports": reports, "parse_errors": errors, "note": "Test outcomes are imported artifacts, not a test execution performed by RepoDNA."}


def _severity(value: str | int | None) -> str:
    if isinstance(value, int):
        return "error" if value >= 2 else "warning"
    lowered = str(value or "unknown").casefold()
    return {"fatal": "critical", "err": "error", "warn": "warning", "moderate": "medium"}.get(lowered, lowered)


def _normalized_package(value: str) -> str:
    normalized = unquote(value.strip()).casefold().replace("_", "-")
    if not normalized.startswith("pkg:"):
        return normalized
    purl = normalized[4:].split("?", 1)[0].split("#", 1)[0]
    ecosystem, _, identity = purl.partition("/")
    identity = identity.rsplit("@", 1)[0]
    if ecosystem == "maven" and "/" in identity:
        group, artifact = identity.rsplit("/", 1)
        return f"{group}:{artifact}"
    return identity


def _finding(package: str, version: str | None, identifier: Any, severity: Any, source: str) -> dict[str, Any]:
    return {"package": package, "version": version, "id": str(identifier or "unknown"), "severity": _severity(severity), "source": source}


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
    return {"status": "imported" if reports else "invalid" if errors else "not_observed", "message": None if reports else "Linter artifacts were invalid." if errors else "No linter artifact was provided or discovered.", "issues": sum(combined.values()) if reports else None, "severities": dict(combined), "reports": reports, "parse_errors": errors, "note": "Linter findings are imported without source snippets or diagnostic message content."}


def _scanners(root: Path, manifest_count: int) -> dict[str, Any]:
    reports: list[dict[str, Any]] = []
    errors: list[dict[str, str]] = []
    candidates = _find(
        root,
        {"npm-audit.json", "pip-audit.json", "osv-results.json", "dependency-check-report.json", "trivy-results.json", "security-results.sarif", "bom.json", "sbom.json"},
        ("**/npm-audit.json", "**/pip-audit.json", "**/osv-results.json", "**/dependency-check-report.json", "**/trivy-results.json", "**/security-results.sarif", "**/bom.json", "**/sbom.json"),
    )
    for path in candidates:
        try:
            data = _read_json(path)
            severities: Counter[str] = Counter()
            dependency_findings: list[dict[str, Any]] = []
            name = path.name.casefold()
            tool = "Unknown"
            if name == "npm-audit.json":
                tool = "npm audit"
                for package, vulnerability in data.get("vulnerabilities", {}).items():
                    via = [item for item in vulnerability.get("via", []) if isinstance(item, dict)]
                    if via:
                        for item in via:
                            dependency_findings.append(_finding(package, None, item.get("source", item.get("name")), item.get("severity", vulnerability.get("severity")), tool))
                    else:
                        dependency_findings.append(_finding(package, None, None, vulnerability.get("severity"), tool))
            elif name == "pip-audit.json":
                tool = "pip-audit"
                for dependency in data.get("dependencies", data if isinstance(data, list) else []):
                    for vulnerability in dependency.get("vulns", []):
                        dependency_findings.append(_finding(dependency.get("name", "unknown"), dependency.get("version"), vulnerability.get("id"), vulnerability.get("severity"), tool))
            elif name == "osv-results.json":
                tool = "OSV-Scanner"
                for result in data.get("results", []):
                    for package in result.get("packages", []):
                        package_info = package.get("package", {})
                        for vulnerability in package.get("vulnerabilities", []):
                            severity = vulnerability.get("database_specific", {}).get(
                                "severity",
                                vulnerability.get("ecosystem_specific", {}).get("severity", "unknown"),
                            )
                            dependency_findings.append(_finding(package_info.get("name", "unknown"), package.get("version"), vulnerability.get("id"), severity, tool))
            elif name == "dependency-check-report.json":
                tool = "OWASP Dependency-Check"
                for dependency in data.get("dependencies", []):
                    for vulnerability in dependency.get("vulnerabilities", []):
                        package = dependency.get("packages", [{}])[0].get("id") if dependency.get("packages") else dependency.get("fileName", "unknown")
                        dependency_findings.append(_finding(package, None, vulnerability.get("name"), vulnerability.get("severity"), tool))
            elif name == "trivy-results.json":
                tool = "Trivy"
                for result in data.get("Results", []):
                    for vulnerability in result.get("Vulnerabilities", []):
                        dependency_findings.append(_finding(vulnerability.get("PkgName", "unknown"), vulnerability.get("InstalledVersion"), vulnerability.get("VulnerabilityID"), vulnerability.get("Severity"), tool))
                    for finding in [*result.get("Misconfigurations", []), *result.get("Secrets", [])]:
                        severities[_severity(finding.get("Severity"))] += 1
            elif name in {"bom.json", "sbom.json"} and data.get("bomFormat") == "CycloneDX":
                tool = "CycloneDX"
                if not data.get("vulnerabilities"):
                    continue
                components = {item.get("bom-ref"): item for item in data.get("components", [])}
                for vulnerability in data.get("vulnerabilities", []):
                    ratings = vulnerability.get("ratings", [])
                    severity = ratings[0].get("severity") if ratings else "unknown"
                    for affect in vulnerability.get("affects", []):
                        component = components.get(affect.get("ref"), {})
                        dependency_findings.append(_finding(component.get("name", affect.get("ref", "unknown")), component.get("version"), vulnerability.get("id"), severity, tool))
            else:
                tool = "SARIF"
                for run in data.get("runs", []):
                    tool = run.get("tool", {}).get("driver", {}).get("name", tool)
                    for finding in run.get("results", []):
                        package = finding.get("properties", {}).get("packageName")
                        if package:
                            dependency_findings.append(_finding(package, finding.get("properties", {}).get("packageVersion"), finding.get("ruleId"), finding.get("level"), tool))
                        else:
                            severities[_severity(finding.get("level"))] += 1
            severities.update(item["severity"] for item in dependency_findings)
            reports.append({"path": _relative(root, path), "tool": tool, "findings": sum(severities.values()), "severities": dict(severities), "dependency_findings": dependency_findings})
        except (OSError, ValueError, TypeError) as error:
            errors.append({"path": _relative(root, path), "error": str(error)})
    combined = Counter()
    for report in reports:
        combined.update(report["severities"])
    dependency_findings = [finding for report in reports for finding in report.get("dependency_findings", [])]
    return {"status": "imported" if reports else "invalid" if errors else "not_observed", "message": None if reports else "Security scanner artifacts were invalid." if errors else "No security scanner artifact was provided or discovered.", "findings": sum(combined.values()) if reports else None, "severities": dict(combined), "dependency_findings": dependency_findings, "scanner_reports": [item["path"] for item in reports], "reports": reports, "parse_errors": errors, "manifests_available": manifest_count, "note": "Security findings are imported and counted without exporting vulnerable values, messages, or source snippets."}


def _license_value(value: Any) -> list[str]:
    if isinstance(value, list):
        return sorted({str(item).strip() for item in value if str(item).strip()})
    if isinstance(value, dict):
        value = value.get("id", value.get("name", value.get("expression", "")))
    return [str(value).strip()] if value and str(value).strip() else []


def _licenses(root: Path) -> dict[str, Any]:
    reports: list[dict[str, Any]] = []
    errors: list[dict[str, str]] = []
    candidates = _find(root, {"license-checker.json", "pip-licenses.json", "dotnet-licenses.json", "bom.json", "sbom.json", "spdx.json"}, ("**/license-checker.json", "**/pip-licenses.json", "**/dotnet-licenses.json", "**/bom.json", "**/sbom.json", "**/spdx.json"))
    for path in candidates:
        try:
            data = _read_json(path)
            packages: list[dict[str, Any]] = []
            tool = "Unknown"
            name = path.name.casefold()
            if name == "license-checker.json":
                tool = "license-checker"
                for package_version, metadata in data.items():
                    package = package_version.rsplit("@", 1)[0] if "@" in package_version[1:] else package_version
                    version = package_version.rsplit("@", 1)[1] if "@" in package_version[1:] else None
                    license_value = metadata.get("licenses") if isinstance(metadata, dict) else metadata
                    packages.append({"name": package, "version": version, "licenses": _license_value(license_value)})
            elif name == "pip-licenses.json":
                tool = "pip-licenses"
                for item in data:
                    packages.append({"name": item.get("Name", item.get("name", "unknown")), "version": item.get("Version", item.get("version")), "licenses": _license_value(item.get("License", item.get("license")))})
            elif name == "dotnet-licenses.json":
                tool = "dotnet-project-licenses"
                items = data if isinstance(data, list) else data.get("packages", data.get("Packages", []))
                for item in items:
                    packages.append({"name": item.get("PackageName", item.get("name", "unknown")), "version": item.get("PackageVersion", item.get("version")), "licenses": _license_value(item.get("PackageLicense", item.get("license")))})
            elif data.get("bomFormat") == "CycloneDX":
                tool = "CycloneDX"
                for item in data.get("components", []):
                    licenses = []
                    for license_item in item.get("licenses", []):
                        licenses.extend(_license_value(license_item.get("license", license_item.get("expression"))))
                    packages.append({"name": item.get("name", "unknown"), "version": item.get("version"), "licenses": sorted(set(licenses))})
            elif "spdxVersion" in data:
                tool = "SPDX"
                for item in data.get("packages", []):
                    values = [item.get("licenseConcluded"), item.get("licenseDeclared")]
                    licenses = sorted({value for value in values if value and value not in {"NOASSERTION", "NONE"}})
                    packages.append({"name": item.get("name", "unknown"), "version": item.get("versionInfo"), "licenses": licenses})
            else:
                continue
            reports.append({"path": _relative(root, path), "tool": tool, "packages": packages})
        except (OSError, ValueError, TypeError) as error:
            errors.append({"path": _relative(root, path), "error": str(error)})
    packages = [item | {"source": report["tool"], "report": report["path"]} for report in reports for item in report["packages"]]
    return {"status": "imported" if reports else "invalid" if errors else "not_observed", "message": None if reports else "License artifacts were invalid." if errors else "No dependency-license artifact was provided or discovered.", "packages": packages, "reports": reports, "parse_errors": errors, "note": "Licenses are imported metadata and are not legal advice or a compatibility determination."}


def _license_category(licenses: list[str]) -> str:
    text = " OR ".join(licenses).upper()
    if not licenses:
        return "unresolved"
    if re.search(r"\b(?:AGPL|GPL|LGPL|SSPL|EUPL|MPL|EPL)", text):
        return "review_required"
    if re.search(r"\b(?:MIT|APACHE|BSD|ISC|ZLIB|UNLICENSE)", text):
        return "permissive"
    if re.search(r"PROPRIETARY|COMMERCIAL", text):
        return "proprietary"
    return "review_required"


def _resolve_dependencies(dependencies: dict[str, Any], scanners: dict[str, Any], licenses: dict[str, Any], inventory: dict[str, Any]) -> dict[str, Any]:
    records: dict[str, dict[str, Any]] = {}
    for component in inventory.get("components", []):
        key = _normalized_package(component["name"])
        record = records.setdefault(key, {"name": component["name"], "direct": False, "manifests": set(), "versions": set(), "vulnerabilities": [], "licenses": set(), "sources": set()})
        record["direct"] = record["direct"] or component.get("direct", False)
        if component.get("version"):
            record["versions"].add(component["version"])
        record["sources"].update(component.get("lockfiles", []))
    for manifest in dependencies.get("manifests", []):
        for name in manifest.get("dependencies", []):
            key = _normalized_package(name)
            record = records.setdefault(key, {"name": name, "direct": True, "manifests": set(), "versions": set(), "vulnerabilities": [], "licenses": set(), "sources": set()})
            record["direct"] = True
            record["manifests"].add(manifest.get("path", ""))
    for finding in scanners.get("dependency_findings", []):
        key = _normalized_package(finding["package"])
        record = records.setdefault(key, {"name": finding["package"], "direct": False, "manifests": set(), "versions": set(), "vulnerabilities": [], "licenses": set(), "sources": set()})
        record["vulnerabilities"].append({key: finding[key] for key in ("id", "severity", "source")})
        if finding.get("version"):
            record["versions"].add(finding["version"])
        record["sources"].add(finding["source"])
    for package in licenses.get("packages", []):
        key = _normalized_package(package["name"])
        record = records.setdefault(key, {"name": package["name"], "direct": False, "manifests": set(), "versions": set(), "vulnerabilities": [], "licenses": set(), "sources": set()})
        record["licenses"].update(package.get("licenses", []))
        if package.get("version"):
            record["versions"].add(package["version"])
        record["sources"].add(package["source"])
    resolved = []
    for record in records.values():
        license_values = sorted(record["licenses"])
        vulnerabilities = record["vulnerabilities"]
        resolved.append({
            "name": record["name"], "direct": record["direct"], "manifests": sorted(record["manifests"]), "versions": sorted(record["versions"]),
            "vulnerability_status": "affected" if vulnerabilities else "not_resolved",
            "vulnerability_count": len(vulnerabilities), "vulnerabilities": vulnerabilities,
            "license_status": "resolved" if license_values else "unresolved", "license_category": _license_category(license_values),
            "licenses": license_values, "sources": sorted(record["sources"]),
        })
    resolved.sort(key=lambda item: (-item["vulnerability_count"], item["name"].casefold()))
    return {
        "summary": {
            "dependencies": len(resolved), "direct_dependencies": sum(item["direct"] for item in resolved),
            "affected_dependencies": sum(item["vulnerability_status"] == "affected" for item in resolved),
            "license_resolved": sum(item["license_status"] == "resolved" for item in resolved),
            "license_review_required": sum(item["license_category"] in {"review_required", "proprietary"} for item in resolved),
            "license_unresolved": sum(item["license_status"] == "unresolved" for item in resolved),
        },
        "dependencies": resolved,
        "method": "Normalized package identity correlated across manifests, resolved lockfiles, scanners, SBOMs, and license reports",
        "limitations": [
            "not_resolved means that no per-dependency scanner result was correlated; it does not mean vulnerability-free",
            "License categories are triage signals, not legal advice or compatibility analysis",
        ],
    }


def import_quality_results(root: Path, dependencies: dict[str, Any], inventory: dict[str, Any] | None = None) -> dict[str, Any]:
    scanners = _scanners(root, len(dependencies.get("manifests", [])))
    licenses = _licenses(root)
    inventory = inventory or {}
    return {"coverage": _coverage(root), "tests": _tests(root), "linters": _linters(root), "vulnerabilities": scanners, "dependency_licenses": licenses, "dependency_resolution": _resolve_dependencies(dependencies, scanners, licenses, inventory)}
