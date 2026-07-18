"""Resolve dependency lockfiles and build a CycloneDX software bill of materials."""

from __future__ import annotations

import json
import os
import re
import tomllib
from pathlib import Path
from typing import Any
from urllib.parse import quote


LOCKFILE_NAMES = {
    "package-lock.json", "npm-shrinkwrap.json", "yarn.lock", "pnpm-lock.yaml",
    "poetry.lock", "pipfile.lock", "packages.lock.json", "pubspec.lock",
    "cargo.lock", "go.sum", "packages-lock.json", "composer.lock", "gradle.lockfile",
}
EXCLUDED_DIRECTORIES = {".git", ".dart_tool", ".gradle", ".idea", ".repodna", "Library", "Temp", "build", "dist", "node_modules", "obj", "vendor"}

ECOSYSTEM_TYPES = {
    "npm": "npm", "PyPI": "pypi", "NuGet": "nuget", "Pub": "pub",
    "Cargo": "cargo", "Go": "golang", "Unity": "generic", "Composer": "composer",
    "Maven": "maven",
}


def _normalized(value: str) -> str:
    return value.strip().lower().replace("_", "-")


def _component(name: str, version: str | None, ecosystem: str, direct: bool = False,
               dependencies: list[str] | None = None) -> dict[str, Any]:
    return {
        "name": name, "version": str(version or "").lstrip("=v"), "ecosystem": ecosystem,
        "direct": direct, "dependencies": sorted(set(dependencies or [])),
    }


def _npm(data: dict[str, Any]) -> list[dict[str, Any]]:
    direct_names = set(data.get("dependencies", {})) | set(data.get("devDependencies", {}))
    result = []
    packages = data.get("packages", {})
    if packages:
        root = packages.get("", {})
        direct_names |= set(root.get("dependencies", {})) | set(root.get("devDependencies", {}))
        for location, metadata in packages.items():
            if not location or "node_modules/" not in location:
                continue
            name = location.rsplit("node_modules/", 1)[1]
            result.append(_component(name, metadata.get("version"), "npm", name in direct_names,
                                     list(metadata.get("dependencies", {}))))
    else:
        def walk(items: dict[str, Any], top: bool = False) -> None:
            for name, metadata in items.items():
                result.append(_component(name, metadata.get("version"), "npm", top or name in direct_names,
                                         list(metadata.get("requires", {}))))
                walk(metadata.get("dependencies", {}))
        walk(data.get("dependencies", {}), True)
    return result


def _json_lock(path: Path) -> tuple[str, list[dict[str, Any]]]:
    data = json.loads(path.read_text(encoding="utf-8"))
    name = path.name.lower()
    if name in {"package-lock.json", "npm-shrinkwrap.json"}:
        return "npm", _npm(data)
    if name == "pipfile.lock":
        rows = []
        for section, direct in (("default", True), ("develop", True)):
            for package, metadata in data.get(section, {}).items():
                version = metadata.get("version") if isinstance(metadata, dict) else metadata
                rows.append(_component(package, version, "PyPI", direct))
        return "PyPI", rows
    if name == "packages.lock.json":
        rows = []
        for framework in data.get("dependencies", {}).values():
            if not isinstance(framework, dict):
                continue
            for package, metadata in framework.items():
                rows.append(_component(package, metadata.get("resolved"), "NuGet",
                                       metadata.get("type", "").lower() == "direct",
                                       list(metadata.get("dependencies", {}))))
        return "NuGet", rows
    if name == "packages-lock.json":
        rows = []
        for package, metadata in data.get("dependencies", {}).items():
            rows.append(_component(package, metadata.get("version"), "Unity",
                                   metadata.get("depth", 1) == 0,
                                   list(metadata.get("dependencies", {}))))
        return "Unity", rows
    if name == "composer.lock":
        rows = []
        for section in ("packages", "packages-dev"):
            for metadata in data.get(section, []):
                rows.append(_component(metadata.get("name", "unknown"), metadata.get("version"), "Composer",
                                       False, list(metadata.get("require", {}))))
        return "Composer", rows
    raise ValueError(f"unsupported JSON lockfile: {path.name}")


def _toml_lock(path: Path) -> tuple[str, list[dict[str, Any]]]:
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    ecosystem = "Cargo" if path.name.lower() == "cargo.lock" else "PyPI"
    rows = []
    for metadata in data.get("package", []):
        dependencies = []
        for value in metadata.get("dependencies", []):
            if isinstance(value, str):
                dependencies.append(value.split()[0])
            elif isinstance(value, dict) and value.get("name"):
                dependencies.append(value["name"])
        rows.append(_component(metadata.get("name", "unknown"), metadata.get("version"), ecosystem,
                               False, dependencies))
    return ecosystem, rows


def _pubspec(path: Path) -> tuple[str, list[dict[str, Any]]]:
    rows, current = [], None
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = re.match(r"^  ([\w.-]+):\s*$", line)
        if match:
            current = _component(match.group(1), "", "Pub")
            rows.append(current)
            continue
        if current and (match := re.match(r'^    version:\s*["\047]?([^"\047\s]+)', line)):
            current["version"] = match.group(1)
        elif current and (match := re.match(r"^    dependency:\s*(.+?)\s*$", line)):
            current["direct"] = match.group(1).strip('"\047') in {"direct main", "direct dev"}
    return "Pub", rows


def _go_sum(path: Path) -> tuple[str, list[dict[str, Any]]]:
    rows = {}
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        parts = line.split()
        if len(parts) >= 2 and not parts[1].endswith("/go.mod"):
            rows[(parts[0], parts[1])] = _component(parts[0], parts[1], "Go")
    return "Go", list(rows.values())


def _gradle(path: Path) -> tuple[str, list[dict[str, Any]]]:
    rows = []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = re.match(r"^([^:#\s]+):([^:\s]+):([^=\s]+)", line)
        if match:
            rows.append(_component(f"{match.group(1)}:{match.group(2)}", match.group(3), "Maven"))
    return "Maven", rows


def _simple_yaml_packages(path: Path) -> tuple[str, list[dict[str, Any]]]:
    ecosystem = "npm"
    rows = []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        match = re.match(r"^\s{2,}/?((?:@[^/]+/)?[^:@\s]+)@([^:\s]+):\s*$", line)
        if match:
            rows.append(_component(match.group(1), match.group(2).strip("()"), ecosystem))
    return ecosystem, rows


def _yarn(path: Path) -> tuple[str, list[dict[str, Any]]]:
    rows, names = [], []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if line and not line.startswith((" ", "#")) and line.endswith(":"):
            names = []
            for selector in line[:-1].split(","):
                selector = selector.strip().strip('"')
                match = re.match(r"((?:@[^/]+/)?[^@]+)@", selector)
                if match:
                    names.append(match.group(1))
        elif names and (match := re.match(r'^\s+version\s+["\047]([^"\047]+)', line)):
            rows.extend(_component(name, match.group(1), "npm") for name in names)
            names = []
    return "npm", rows


def _parse_lockfile(path: Path) -> tuple[str, list[dict[str, Any]]]:
    name = path.name.lower()
    if name.endswith(".json") or name in {"composer.lock", "pipfile.lock"}:
        return _json_lock(path)
    if name in {"poetry.lock", "cargo.lock"}:
        return _toml_lock(path)
    if name == "pubspec.lock":
        return _pubspec(path)
    if name == "go.sum":
        return _go_sum(path)
    if name == "gradle.lockfile":
        return _gradle(path)
    if name == "yarn.lock":
        return _yarn(path)
    if name == "pnpm-lock.yaml":
        return _simple_yaml_packages(path)
    raise ValueError(f"unsupported lockfile: {path.name}")


def _purl(component: dict[str, Any]) -> str:
    package_type = ECOSYSTEM_TYPES.get(component["ecosystem"], "generic")
    raw_name = component["name"]
    if component["ecosystem"] == "Maven" and ":" in raw_name:
        group, artifact = raw_name.split(":", 1)
        name = f"{quote(group, safe='.')}/{quote(artifact, safe='.-_')}"
    else:
        name = quote(raw_name, safe="/.-_")
    version = quote(component["version"], safe=".-_+")
    return f"pkg:{package_type}/{name}" + (f"@{version}" if version else "")


def collect_dependency_inventory(root: Path, declared: dict[str, Any]) -> dict[str, Any]:
    direct_names = {
        _normalized(name)
        for manifest in declared.get("manifests", [])
        for name in manifest.get("dependencies", [])
    }
    records: dict[tuple[str, str, str], dict[str, Any]] = {}
    lockfiles, errors = [], []
    candidates = []
    for current, directories, files in os.walk(root):
        directories[:] = [name for name in directories if name not in EXCLUDED_DIRECTORIES and not re.match(r".*_project_analysis_\d{4}-\d{2}-\d{2}_", name)]
        candidates.extend(Path(current) / name for name in files if name.lower() in LOCKFILE_NAMES)
    for path in sorted(candidates):
        relative = path.relative_to(root).as_posix()
        try:
            ecosystem, components = _parse_lockfile(path)
            for component in components:
                component["direct"] = component["direct"] or _normalized(component["name"]) in direct_names
                key = (component["ecosystem"], _normalized(component["name"]), component["version"])
                record = records.setdefault(key, component | {"lockfiles": [], "purl": _purl(component)})
                record["direct"] = record["direct"] or component["direct"]
                record["lockfiles"].append(relative)
                record["dependencies"] = sorted(set(record["dependencies"]) | set(component["dependencies"]))
            lockfiles.append({"path": relative, "ecosystem": ecosystem, "component_count": len(components), "status": "parsed"})
        except (OSError, ValueError, TypeError, tomllib.TOMLDecodeError) as error:
            errors.append({"path": relative, "error": str(error)})
            lockfiles.append({"path": relative, "ecosystem": "Unknown", "component_count": 0, "status": "invalid"})

    components = sorted(records.values(), key=lambda item: (item["ecosystem"], item["name"].casefold(), item["version"]))
    refs_by_name = {(item["ecosystem"], _normalized(item["name"])): item["purl"] for item in components}
    sbom_components = [
        {
            "type": "library", "bom-ref": item["purl"], "name": item["name"],
            **({"version": item["version"]} if item["version"] else {}),
            "purl": item["purl"],
            "properties": [
                {"name": "repodna:ecosystem", "value": item["ecosystem"]},
                {"name": "repodna:direct", "value": str(item["direct"]).lower()},
                {"name": "repodna:lockfiles", "value": ",".join(item["lockfiles"])},
            ],
        }
        for item in components
    ]
    dependency_graph = [
        {"ref": item["purl"], "dependsOn": sorted({refs_by_name[(item["ecosystem"], _normalized(name))] for name in item["dependencies"] if (item["ecosystem"], _normalized(name)) in refs_by_name})}
        for item in components
    ]
    sbom = {
        "bomFormat": "CycloneDX", "specVersion": "1.6", "version": 1,
        "metadata": {"tools": {"components": [{"type": "application", "name": "RepoDNA"}]}},
        "components": sbom_components, "dependencies": dependency_graph,
    }
    return {
        "status": "resolved" if components and not errors else "partial" if components or errors else "not_found",
        "summary": {
            "lockfiles": len(lockfiles), "parsed_lockfiles": sum(item["status"] == "parsed" for item in lockfiles),
            "components": len(components), "direct_components": sum(item["direct"] for item in components),
            "transitive_components": sum(not item["direct"] for item in components), "ecosystems": len({item["ecosystem"] for item in components}),
        },
        "lockfiles": lockfiles, "components": components, "parse_errors": errors, "sbom": sbom,
        "method": "Versions and dependency relationships resolved statically from supported lockfiles; SBOM emitted as CycloneDX 1.6 JSON",
        "limitations": [
            "A missing lockfile prevents exact transitive resolution for that ecosystem",
            "Some text lockfiles do not encode complete dependency edges or directness",
            "The generated SBOM describes repository lockfiles and does not inspect deployed binaries or containers",
        ],
    }
