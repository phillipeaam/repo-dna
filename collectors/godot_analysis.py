"""Evidence-based static analysis for Godot repositories."""

from __future__ import annotations

import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


SYSTEM_KEYWORDS = {
    "Combat": ("combat", "weapon", "damage", "health", "hitbox", "hurtbox"),
    "Character": ("character", "player", "actor", "pawn"),
    "Movement": ("movement", "locomotion", "velocity", "jump", "dash"),
    "Camera": ("camera", "cinemachine"),
    "AI": ("ai", "enemy", "behavior", "navigation", "pathfind"),
    "Inventory": ("inventory", "item", "equipment", "loot"),
    "Abilities": ("ability", "abilities", "skill", "spell"),
    "Quests": ("quest", "mission", "objective"),
    "Progression": ("progression", "level", "experience", "upgrade"),
    "Save": ("save", "persistence", "serialize", "checkpoint"),
    "Networking": ("network", "multiplayer", "rpc", "server", "client"),
    "UI": ("ui", "hud", "menu", "screen", "control", "button"),
    "Audio": ("audio", "music", "sound", "sfx"),
    "Animation": ("animation", "animator", "tween"),
    "Localization": ("localization", "translation", "locale", "i18n"),
    "Analytics": ("analytics", "telemetry", "metrics"),
    "Tools": ("tool", "editor", "plugin", "importer"),
    "LiveOps": ("liveops", "live_ops", "remote_config", "event", "season"),
}

TEXT_ASSET_EXTENSIONS = {".gdshader", ".shader", ".json", ".csv", ".po", ".pot", ".translation"}
MEDIA_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".svg", ".ogg", ".wav", ".mp3", ".glb", ".gltf", ".fbx", ".obj"}
NATIVE_EXTENSIONS = {".gdextension", ".gdnlib", ".dll", ".so", ".dylib", ".a", ".framework"}


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def _value(value: str) -> Any:
    value = value.strip()
    if value in {"true", "false"}:
        return value == "true"
    if re.fullmatch(r"-?\d+(?:\.\d+)?", value):
        return float(value) if "." in value else int(value)
    if value.startswith('"') and value.endswith('"'):
        return value[1:-1]
    if match := re.match(r"PackedStringArray\((.*)\)$", value):
        return re.findall(r'"([^"\\]*(?:\\.[^"\\]*)*)"', match.group(1))
    return value


def parse_project_settings(text: str) -> dict[str, dict[str, Any]]:
    sections: dict[str, dict[str, Any]] = defaultdict(dict)
    section = "root"
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith((";", "#")):
            continue
        if match := re.match(r"^\[([^]]+)]$", stripped):
            section = match.group(1)
        elif "=" in stripped:
            key, value = stripped.split("=", 1)
            sections[section][key.strip()] = _value(value)
    return dict(sections)


def _resource_path(value: str) -> str:
    return value.removeprefix("res://")


def parse_scene(path: str, text: str) -> dict[str, Any]:
    ext_resources = {
        match.group("id"): {"type": match.group("type"), "path": _resource_path(match.group("path"))}
        for match in re.finditer(r'\[ext_resource\s+type="(?P<type>[^"]+)"\s+path="(?P<path>[^"]+)"[^]]*?id="(?P<id>[^"]+)"[^]]*]', text)
    }
    nodes = []
    for match in re.finditer(r"\[node\s+([^]]+)]", text):
        attributes = dict(re.findall(r'(\w+)="([^"]*)"', match.group(1)))
        nodes.append({
            "name": attributes.get("name", ""), "type": attributes.get("type", "instanced"),
            "parent": attributes.get("parent", ""), "instance": attributes.get("instance"),
        })
    connections = [
        dict(re.findall(r'(\w+)="([^"]*)"', match.group(1)))
        for match in re.finditer(r"\[connection\s+([^]]+)]", text)
    ]
    dependencies = sorted({item["path"] for item in ext_resources.values()})
    scripts = sorted({item["path"] for item in ext_resources.values() if item["type"] in {"Script", "CSharpScript"}})
    instances = sorted({ext_resources[match.group(1)]["path"] for match in re.finditer(r'instance=ExtResource\("([^"]+)"\)', text) if match.group(1) in ext_resources})
    header = re.search(r"\[gd_scene\s+([^]]+)]", text)
    header_text = header.group(1) if header else ""
    format_match = re.search(r"\bformat=(\d+)", header_text)
    uid_match = re.search(r'\buid="([^"]+)"', header_text)
    return {
        "path": path, "format": int(format_match.group(1)) if format_match else 0,
        "uid": uid_match.group(1) if uid_match else "", "node_count": len(nodes),
        "root_node": nodes[0] if nodes else None, "nodes": nodes, "node_types": dict(Counter(item["type"] for item in nodes)),
        "dependencies": dependencies, "scripts": scripts, "instanced_scenes": instances,
        "connections": connections, "connection_count": len(connections),
    }


def parse_gdscript(path: str, text: str, activity: dict[str, Any]) -> dict[str, Any]:
    functions = [{"name": name, "line": text[:match.start()].count("\n") + 1} for match in re.finditer(r"^\s*func\s+([A-Za-z_]\w*)", text, re.M) for name in [match.group(1)]]
    frame_names = {"_process", "_physics_process", "_input", "_unhandled_input"}
    return {
        "path": path, "language": "GDScript", "extends": (re.search(r"^\s*extends\s+([^\s#]+)", text, re.M) or [None, None])[1],
        "class_name": (re.search(r"^\s*class_name\s+([A-Za-z_]\w*)", text, re.M) or [None, None])[1],
        "tool": bool(re.search(r"^\s*@tool\b", text, re.M)), "functions": functions,
        "signals": re.findall(r"^\s*signal\s+([A-Za-z_]\w*)", text, re.M),
        "exports": len(re.findall(r"@export(?:_[A-Za-z_]+)?\b", text)), "onready": len(re.findall(r"@onready\b", text)),
        "rpc_methods": len(re.findall(r"@rpc(?:\([^)]*\))?", text)), "await_count": len(re.findall(r"\bawait\b", text)),
        "resource_loads": sorted(set(_resource_path(value) for value in re.findall(r'(?:preload|load)\(\s*"(res://[^"]+)"', text))),
        "frame_methods": [item["name"] for item in functions if item["name"] in frame_names],
        "lines": len(text.splitlines()), "git_commit_touches": sum(item.get("commits", 0) for item in activity.get(path, {}).values()),
    }


def parse_csharp(path: str, text: str, activity: dict[str, Any]) -> dict[str, Any]:
    base = re.search(r"(?:partial\s+)?class\s+([A-Za-z_]\w*)\s*:\s*([A-Za-z_][\w.]*)", text)
    methods = re.findall(r"(?:public|private|protected|internal)?\s*(?:override\s+)?(?:async\s+)?[\w<>.?]+\s+([A-Za-z_]\w*)\s*\(", text)
    return {
        "path": path, "language": "C#", "class_name": base.group(1) if base else None,
        "extends": base.group(2) if base else None, "tool": "[Tool]" in text,
        "functions": [{"name": name, "line": 0} for name in methods],
        "signals": re.findall(r"\[Signal]\s*(?:public\s+)?delegate\s+void\s+([A-Za-z_]\w*)", text),
        "exports": len(re.findall(r"\[Export(?:\([^]]*\))?]", text)), "onready": 0,
        "rpc_methods": len(re.findall(r"\[Rpc(?:\([^]]*\))?]", text)), "await_count": len(re.findall(r"\bawait\b", text)),
        "resource_loads": sorted(set(_resource_path(value) for value in re.findall(r'GD\.Load<[^>]+>\(\s*"(res://[^"]+)"', text))),
        "frame_methods": [name for name in methods if name in {"_Process", "_PhysicsProcess", "_Input", "_UnhandledInput"}],
        "lines": len(text.splitlines()), "git_commit_touches": sum(item.get("commits", 0) for item in activity.get(path, {}).values()),
    }


def parse_resource(path: str, text: str) -> dict[str, Any]:
    header = re.search(r"\[(?:gd_resource|sub_resource)\s+([^]]+)]", text)
    attributes = dict(re.findall(r'(\w+)="([^"]*)"', header.group(1))) if header else {}
    dependencies = sorted(set(_resource_path(value) for value in re.findall(r'path="(res://[^"]+)"', text)))
    return {"path": path, "type": attributes.get("type", "Unknown"), "script_class": attributes.get("script_class"), "dependencies": dependencies}


def parse_export_presets(text: str) -> list[dict[str, Any]]:
    sections = parse_project_settings(text)
    presets = []
    for section, values in sections.items():
        if re.fullmatch(r"preset\.\d+", section):
            presets.append({
                "name": values.get("name", section), "platform": values.get("platform", "Unknown"),
                "runnable": values.get("runnable", False), "export_filter": values.get("export_filter", "Unknown"),
                "features": values.get("custom_features", ""),
            })
    return presets


def parse_plugins(root: Path, paths: set[str], enabled: list[str]) -> list[dict[str, Any]]:
    plugins = []
    for path in sorted(value for value in paths if value.endswith("plugin.cfg")):
        settings = parse_project_settings(read(root / path)).get("plugin", {})
        directory = str(Path(path).parent)
        plugins.append({
            "path": path, "directory": directory, "name": settings.get("name", Path(directory).name),
            "description": settings.get("description", ""), "author": settings.get("author", ""),
            "version": settings.get("version", ""), "script": settings.get("script", ""),
            "enabled": any(directory in item or path in item for item in enabled),
        })
    return plugins


def risk_signals(root: Path, scripts: list[dict[str, Any]]) -> list[dict[str, Any]]:
    signals = []
    for script in scripts:
        text = read(root / script["path"])
        candidates = [
            ("large_script", script["lines"] >= 500, script["lines"], "Large scripts may combine multiple responsibilities."),
            ("many_frame_callbacks", len(script["frame_methods"]) >= 3, len(script["frame_methods"]), "Several per-frame callbacks deserve profiling and responsibility review."),
            ("runtime_load_in_frame_code", bool(script["frame_methods"]) and bool(re.search(r"\b(?:load|GD\.Load)\s*[<(]", text)), len(re.findall(r"\b(?:load|GD\.Load)\s*[<(]", text)), "Runtime resource loading near frame callbacks may cause stalls."),
            ("tree_search", bool(re.search(r"\b(?:find_child|get_nodes_in_group|FindChild)\s*\(", text)), len(re.findall(r"\b(?:find_child|get_nodes_in_group|FindChild)\s*\(", text)), "Repeated scene-tree searches may be costly in hot paths."),
            ("dynamic_node_lookup", bool(re.search(r"\bget_node\s*\(|GetNode\s*<", text)), len(re.findall(r"\b(?:get_node|GetNode)\b", text)), "Repeated dynamic node lookup should be reviewed for caching."),
            ("manual_signal_connection", ".connect(" in text or ".Connect(" in text, len(re.findall(r"\.(?:connect|Connect)\s*\(", text)), "Manual signal connections require lifecycle and disconnection review."),
        ]
        for kind, matched, occurrences, rationale in candidates:
            if matched:
                signals.append({"type": kind, "path": script["path"], "occurrences": occurrences, "confidence": "medium", "severity": "review", "rationale": rationale})
    return signals


def gameplay_systems(paths: set[str], scripts: list[dict[str, Any]], scenes: list[dict[str, Any]], activity: dict[str, Any]) -> list[dict[str, Any]]:
    script_by_path = {item["path"]: item for item in scripts}
    results = []
    for name, keywords in SYSTEM_KEYWORDS.items():
        matched = []
        for path in paths:
            searchable = path.casefold().replace("_", " ").replace("-", " ")
            if any(re.search(rf"(?:^|[/ .]){re.escape(keyword)}(?:s)?(?:[/ .]|$)", searchable) for keyword in keywords):
                matched.append(path)
        matched_scripts = [path for path in matched if path in script_by_path]
        matched_scenes = [scene["path"] for scene in scenes if scene["path"] in matched or any(any(keyword in node["name"].casefold() for keyword in keywords) for node in scene["nodes"])]
        evidence_score = len(set(matched)) + len(matched_scripts) * 2 + len(matched_scenes) * 2
        if evidence_score < 2:
            continue
        directories = Counter(str(Path(path).parent) for path in matched if str(Path(path).parent) != ".")
        commit_touches = sum(sum(item.get("commits", 0) for item in activity.get(path, {}).values()) for path in set(matched))
        results.append({
            "name": name, "confidence": "high" if evidence_score >= 8 else "medium",
            "evidence_score": evidence_score, "file_count": len(set(matched)), "files": sorted(set(matched))[:100],
            "scripts": sorted(set(matched_scripts))[:100], "scenes": sorted(set(matched_scenes))[:100],
            "primary_directories": [directory for directory, _ in directories.most_common(5)],
            "git_commit_touches": commit_touches, "confirmation_required": True,
        })
    return sorted(results, key=lambda item: (-item["evidence_score"], item["name"]))


def empty_result(status: str = "not_godot") -> dict[str, Any]:
    return {"status": status, "summary": {}, "project": {}, "scenes": [], "scene_graph": {}, "scripts": [], "resources": [], "autoloads": [], "input_actions": [], "rendering": {}, "localization": {}, "plugins": [], "exports": [], "tests": {}, "native_extensions": [], "assets": {}, "gameplay_systems": [], "signals": [], "method": "", "limitations": []}


def analyze_godot(root: Path, files: list[dict[str, Any]], git_data: dict[str, Any]) -> dict[str, Any]:
    project_text = read(root / "project.godot")
    if not project_text:
        return empty_result()
    settings = parse_project_settings(project_text)
    paths = {item["path"] for item in files}
    activity = git_data.get("_file_author_activity", {})
    application = settings.get("application", {})
    feature_values = application.get("config/features", [])
    features = feature_values if isinstance(feature_values, list) else [str(feature_values)]
    version = next((value for value in features if re.match(r"^\d+\.\d+", value)), "Unknown")
    autoloads = [{"name": name, "path": _resource_path(str(value).lstrip("*")), "singleton": str(value).startswith("*")} for name, value in settings.get("autoload", {}).items()]
    input_actions = sorted(settings.get("input", {}))
    enabled_plugins = settings.get("editor_plugins", {}).get("enabled", [])
    enabled_plugins = enabled_plugins if isinstance(enabled_plugins, list) else [str(enabled_plugins)]
    scenes = [parse_scene(path, read(root / path)) for path in sorted(value for value in paths if value.endswith(".tscn"))]
    scripts = []
    for path in sorted(value for value in paths if value.endswith((".gd", ".cs"))):
        scripts.append(parse_gdscript(path, read(root / path), activity) if path.endswith(".gd") else parse_csharp(path, read(root / path), activity))
    resources = [parse_resource(path, read(root / path)) for path in sorted(value for value in paths if value.endswith(".tres"))]
    exports = parse_export_presets(read(root / "export_presets.cfg"))
    plugins = parse_plugins(root, paths, enabled_plugins)
    tests = {
        "files": sorted(path for path in paths if re.search(r"(^|/)(?:test|tests)(/|_)|(?:_test|\.test)\.(?:gd|cs)$", path, re.I)),
        "frameworks": sorted({name for name, marker in (("GUT", "addons/gut/"), ("GdUnit4", "addons/gdunit4/"), ("WAT", "addons/wat/")) if any(path.startswith(marker) for path in paths)}),
    }
    native = sorted(path for path in paths if Path(path).suffix.casefold() in NATIVE_EXTENSIONS)
    translations = settings.get("internationalization", {}).get("locale/translations", [])
    translations = translations if isinstance(translations, list) else [str(translations)] if translations else []
    renderer = settings.get("rendering", {}).get("renderer/rendering_method") or settings.get("rendering", {}).get("renderer/rendering_method.mobile") or "Unknown"
    dependencies = [{"source": scene["path"], "target": target, "kind": "scene_resource"} for scene in scenes for target in scene["dependencies"]]
    dependencies += [{"source": script["path"], "target": target, "kind": "script_resource"} for script in scripts for target in script["resource_loads"]]
    systems = gameplay_systems(paths, scripts, scenes, activity)
    signals = risk_signals(root, scripts)
    asset_counts = Counter(Path(path).suffix.casefold() for path in paths if Path(path).suffix.casefold() in MEDIA_EXTENSIONS | TEXT_ASSET_EXTENSIONS)
    return {
        "status": "assessed",
        "summary": {
            "scenes": len(scenes), "nodes": sum(item["node_count"] for item in scenes), "scene_connections": sum(item["connection_count"] for item in scenes),
            "scripts": len(scripts), "gdscript_files": sum(item["language"] == "GDScript" for item in scripts), "csharp_files": sum(item["language"] == "C#" for item in scripts),
            "resources": len(resources), "autoloads": len(autoloads), "input_actions": len(input_actions), "plugins": len(plugins),
            "export_presets": len(exports), "tests": len(tests["files"]), "native_extensions": len(native), "gameplay_systems": len(systems), "signals": len(signals),
        },
        "project": {
            "file": "project.godot", "config_version": settings.get("root", {}).get("config_version"),
            "name": application.get("config/name", root.name), "godot_version": version,
            "features": features, "main_scene": _resource_path(str(application.get("run/main_scene", ""))),
            "physics_ticks_per_second": settings.get("physics", {}).get("common/physics_ticks_per_second"),
            "display": settings.get("display", {}),
        },
        "scenes": scenes, "scene_graph": {"nodes": [scene["path"] for scene in scenes], "edges": dependencies, "edge_count": len(dependencies)},
        "scripts": scripts, "resources": resources, "autoloads": autoloads, "input_actions": input_actions,
        "rendering": {"method": renderer, "features": [value for value in features if value in {"Forward Plus", "Mobile", "GL Compatibility"}]},
        "localization": {"translations": [_resource_path(str(value)) for value in translations], "locale_fallback": settings.get("internationalization", {}).get("locale/fallback")},
        "plugins": plugins, "exports": exports, "tests": tests, "native_extensions": native,
        "assets": {"total": sum(asset_counts.values()), "by_extension": dict(sorted(asset_counts.items()))},
        "gameplay_systems": systems, "signals": signals,
        "method": "Static project.godot, scene, resource, script, plugin, export-preset, asset, and Git-activity evidence",
        "limitations": [
            "Static scene text cannot prove runtime-instantiated nodes, dynamic resources, or executed signal flows",
            "Imported binary assets and editor metadata are counted but not semantically inspected",
            "Gameplay systems and performance findings are review signals, not confirmed design ownership or bugs",
            "Export presets do not prove that a platform build succeeds",
        ],
    }
