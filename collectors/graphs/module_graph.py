"""Resolve source imports and build file, module, and dependency graphs."""

from __future__ import annotations

import re
import posixpath
from collections import Counter, defaultdict
from pathlib import Path, PurePosixPath
from typing import Any


EXTENSIONS = {
    "Python": (".py",), "JavaScript": (".js", ".jsx", ".ts", ".tsx"),
    "TypeScript": (".ts", ".tsx", ".js", ".jsx"), "Java": (".java", ".kt"),
    "Kotlin": (".kt", ".java"), "Dart": (".dart",), "Rust": (".rs",),
}


def _module(path: str) -> str:
    parent = PurePosixPath(path).parent.as_posix()
    return "[root]" if parent == "." else parent


def _candidates(base: PurePosixPath, extensions: tuple[str, ...]) -> list[str]:
    raw = posixpath.normpath(base.as_posix()).lstrip("./")
    result = [raw] if PurePosixPath(raw).suffix else []
    result.extend(f"{raw}{extension}" for extension in extensions)
    result.extend(f"{raw}/index{extension}" for extension in extensions)
    result.extend(f"{raw}/__init__.py" for extension in extensions if extension == ".py")
    result.extend(f"{raw}/mod.rs" for extension in extensions if extension == ".rs")
    return result


def _first_existing(candidates: list[str], files: set[str]) -> str | None:
    return next((candidate for candidate in candidates if candidate in files), None)


def _suffix_existing(suffixes: list[str], files: set[str]) -> str | None:
    matches = sorted(path for path in files if any(path == suffix or path.endswith(f"/{suffix}") for suffix in suffixes))
    return matches[0] if len(matches) == 1 else None


def _project_metadata(root: Path) -> dict[str, str]:
    metadata: dict[str, str] = {}
    for path, key, pattern in (
        (root / "go.mod", "go_module", r"^module\s+(\S+)"),
        (root / "pubspec.yaml", "dart_package", r"^name:\s*([\w-]+)"),
    ):
        try:
            match = re.search(pattern, path.read_text(encoding="utf-8", errors="replace"), re.M)
            if match:
                metadata[key] = match.group(1)
        except OSError:
            pass
    return metadata


def _resolve(source: str, language: str, imported: str, files: set[str], metadata: dict[str, str]) -> tuple[str | None, str]:
    source_parent = PurePosixPath(source).parent
    extensions = EXTENSIONS.get(language, ())
    imported = imported.strip().rstrip(".*")
    candidates: list[str] = []

    if language in {"JavaScript", "TypeScript"} and imported.startswith("."):
        candidates = _candidates(source_parent / imported, extensions)
    elif language == "Python":
        if imported.startswith("."):
            level = len(imported) - len(imported.lstrip("."))
            base = source_parent
            for _ in range(max(level - 1, 0)):
                base = base.parent
            imported = imported[level:]
            candidates = _candidates(base / imported.replace(".", "/"), extensions)
        else:
            suffix = imported.replace(".", "/")
            resolved = _suffix_existing([f"{suffix}.py", f"{suffix}/__init__.py"], files)
            return (resolved, "internal") if resolved else (None, "external")
    elif language in {"Java", "Kotlin"}:
        suffix = imported.replace(".", "/")
        resolved = _suffix_existing([f"{suffix}{ext}" for ext in extensions], files)
        if not resolved and "." in imported:
            type_name = imported.rsplit(".", 1)[-1]
            resolved = _suffix_existing([f"{type_name}{ext}" for ext in extensions], files)
        return (resolved, "internal") if resolved else (None, "external")
    elif language == "Dart":
        if imported.startswith("package:"):
            package, _, relative = imported.removeprefix("package:").partition("/")
            if package == metadata.get("dart_package"):
                candidates = _candidates(PurePosixPath("lib") / relative, extensions)
            else:
                return None, "external"
        elif imported.startswith("dart:"):
            return None, "external"
        else:
            candidates = _candidates(source_parent / imported, extensions)
    elif language == "Go":
        module = metadata.get("go_module", "")
        if module and (imported == module or imported.startswith(f"{module}/")):
            directory = imported.removeprefix(module).lstrip("/") or "."
            matches = sorted(path for path in files if PurePosixPath(path).parent.as_posix() == directory)
            return (matches[0], "internal") if matches else (None, "unresolved")
        return None, "external"
    elif language == "Rust":
        if imported.startswith(("crate::", "self::", "super::")):
            parts = imported.split("::")
            base = PurePosixPath("src") if parts[0] == "crate" else source_parent
            if parts[0] == "super":
                base = base.parent
            relative = "/".join(parts[1:])
            candidates = _candidates(base / relative, extensions)
        elif "::" not in imported:
            candidates = _candidates(source_parent / imported, extensions)
        else:
            return None, "external"
    elif language == "C#":
        directory = imported.replace(".", "/")
        matches = sorted(path for path in files if f"/{directory}/" in f"/{path}" or _module(path).endswith(directory))
        return (matches[0], "internal") if matches else (None, "external")
    else:
        return None, "external"

    resolved = _first_existing(candidates, files)
    return (resolved, "internal") if resolved else (None, "unresolved" if imported.startswith((".", "package:", "crate::", "self::", "super::")) else "external")


def _dependency_key(language: str, imported: str) -> str:
    value = imported.strip().strip("'\"")
    if language in {"JavaScript", "TypeScript"}:
        parts = value.split("/")
        return "/".join(parts[:2]) if value.startswith("@") else parts[0]
    if language == "Dart" and value.startswith("package:"):
        return value.removeprefix("package:").split("/", 1)[0]
    if language == "Rust":
        return value.split("::", 1)[0]
    if language == "Python":
        return value.lstrip(".").split(".", 1)[0]
    return value


def _normalized_dependency(value: str) -> str:
    return value.casefold().replace("_", "-")


def _cycles(nodes: set[str], edges: set[tuple[str, str]]) -> list[list[str]]:
    adjacency: dict[str, list[str]] = defaultdict(list)
    for source, target in edges:
        adjacency[source].append(target)
    index = 0
    indices: dict[str, int] = {}
    low: dict[str, int] = {}
    stack: list[str] = []
    active: set[str] = set()
    result: list[list[str]] = []

    def visit(node: str) -> None:
        nonlocal index
        indices[node] = low[node] = index
        index += 1
        stack.append(node)
        active.add(node)
        for target in adjacency[node]:
            if target not in indices:
                visit(target)
                low[node] = min(low[node], low[target])
            elif target in active:
                low[node] = min(low[node], indices[target])
        if low[node] == indices[node]:
            component: list[str] = []
            while stack:
                member = stack.pop()
                active.remove(member)
                component.append(member)
                if member == node:
                    break
            if len(component) > 1 or (component and (component[0], component[0]) in edges):
                result.append(sorted(component))

    for node in sorted(nodes):
        if node not in indices:
            visit(node)
    return sorted(result, key=lambda item: (-len(item), item))


def build_graphs(root: Path, files: list[dict[str, Any]], imports: list[dict[str, Any]], dependencies: dict[str, Any]) -> dict[str, Any]:
    source_files = {item["path"] for item in files if item.get("language")}
    languages = {item["path"]: item.get("language", "Unknown") for item in files}
    metadata = _project_metadata(root)
    edges: list[dict[str, Any]] = []
    external_refs: list[dict[str, str]] = []
    unresolved: list[dict[str, str]] = []
    for item in imports:
        source = item["path"]
        language = languages.get(source, "Unknown")
        for imported in item.get("imports", []):
            target, status = _resolve(source, language, imported, source_files, metadata)
            edge = {"source": source, "import": imported, "status": status}
            if target:
                edge["target"] = target
            edges.append(edge)
            if status == "external":
                external_refs.append({"source": source, "module": _module(source), "dependency": _dependency_key(language, imported), "import": imported})
            elif status == "unresolved":
                unresolved.append({"source": source, "import": imported})

    internal_edges = {(edge["source"], edge["target"]) for edge in edges if edge["status"] == "internal" and edge.get("target")}
    incoming = Counter(target for _, target in internal_edges)
    outgoing = Counter(source for source, _ in internal_edges)
    file_nodes = [{"id": path, "language": languages[path], "fan_in": incoming[path], "fan_out": outgoing[path]} for path in sorted(source_files)]

    module_edge_counts: Counter[tuple[str, str]] = Counter((_module(source), _module(target)) for source, target in internal_edges if _module(source) != _module(target))
    module_nodes_set = {_module(path) for path in source_files}
    module_in = Counter(target for source, target in module_edge_counts)
    module_out = Counter(source for source, target in module_edge_counts)
    module_nodes = [{"id": module, "fan_in": module_in[module], "fan_out": module_out[module], "files": sum(_module(path) == module for path in source_files)} for module in sorted(module_nodes_set)]
    module_edges = [{"source": source, "target": target, "references": count} for (source, target), count in sorted(module_edge_counts.items())]

    declared: dict[str, dict[str, Any]] = {}
    for manifest in dependencies.get("manifests", []):
        for dependency in manifest.get("dependencies", []):
            key = _normalized_dependency(dependency)
            entry = declared.setdefault(key, {"name": dependency, "manifests": set()})
            entry["manifests"].add(manifest.get("path", ""))
    dependency_refs: Counter[str] = Counter(_normalized_dependency(item["dependency"]) for item in external_refs if item["dependency"])
    dependency_modules: dict[str, set[str]] = defaultdict(set)
    external_names: dict[str, str] = {}
    for item in external_refs:
        key = _normalized_dependency(item["dependency"])
        dependency_modules[key].add(item["module"])
        external_names.setdefault(key, item["dependency"])
    dependency_names = set(dependency_refs) | set(declared)
    display_names = {key: declared.get(key, {}).get("name", external_names.get(key, key)) for key in dependency_names}
    dependency_nodes = [{
        "id": display_names[key], "declared": key in declared,
        "import_references": dependency_refs[key], "source_modules": len(dependency_modules[key]),
        "manifests": sorted(declared.get(key, {}).get("manifests", set())),
    } for key in sorted(dependency_names)]
    dependency_edges = [{"source": item["module"], "target": display_names[_normalized_dependency(item["dependency"])], "import": item["import"]} for item in external_refs if item["dependency"]]

    return {
        "summary": {
            "files": len(file_nodes), "imports": len(edges), "internal_edges": len(internal_edges),
            "external_references": len(external_refs), "unresolved_imports": len(unresolved),
            "modules": len(module_nodes), "module_edges": len(module_edges),
            "dependency_nodes": len(dependency_nodes), "cycles": len(_cycles(module_nodes_set, set(module_edge_counts))),
        },
        "file_graph": {"nodes": file_nodes, "edges": edges, "unresolved": unresolved},
        "module_graph": {"nodes": module_nodes, "edges": module_edges, "cycles": _cycles(module_nodes_set, set(module_edge_counts))},
        "dependency_graph": {"nodes": dependency_nodes, "edges": dependency_edges},
        "method": "Language-aware import resolution with file and directory-module aggregation",
        "limitations": [
            "Runtime dependency injection, reflection, generated code, and dynamic imports may not appear in the graph.",
            "C# namespace and Java/Kotlin wildcard resolution is directory-based when exact declaration metadata is unavailable.",
        ],
    }
