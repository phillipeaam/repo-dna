"""Evidence-based static analysis for Unreal Engine repositories."""

from __future__ import annotations

import json
import re
from collections import Counter
from pathlib import Path
from typing import Any


SYSTEM_KEYWORDS = {
    "Combat": ("combat", "weapon", "damage", "health"), "Character": ("character", "player", "pawn"),
    "Movement": ("movement", "locomotion", "jump"), "Camera": ("camera",), "AI": ("ai", "enemy", "behavior", "navigation"),
    "Inventory": ("inventory", "item", "equipment"), "Abilities": ("ability", "abilities", "gameplayability", "skill"),
    "Quests": ("quest", "mission", "objective"), "Progression": ("progression", "experience", "upgrade"),
    "Save": ("save", "persistence", "checkpoint"), "Networking": ("network", "multiplayer", "replication", "server", "client"),
    "UI": ("ui", "hud", "menu", "widget", "umg"), "Audio": ("audio", "sound", "music"),
    "Animation": ("animation", "animinstance", "montage"), "Localization": ("localization", "locale", "culture"),
    "Analytics": ("analytics", "telemetry"), "Tools": ("editor", "tool", "commandlet"), "LiveOps": ("liveops", "remoteconfig", "season"),
}
ASSET_EXTENSIONS = {".uasset", ".umap", ".fbx", ".png", ".jpg", ".wav", ".mp3", ".ogg"}


def read(path: Path) -> str:
    try: return path.read_text(encoding="utf-8", errors="replace")
    except OSError: return ""


def read_json(path: Path) -> dict[str, Any]:
    try: return json.loads(read(path))
    except (json.JSONDecodeError, TypeError): return {}


def parse_descriptor(path: str, data: dict[str, Any]) -> dict[str, Any]:
    return {
        "path": path, "file_version": data.get("FileVersion"), "engine_association": data.get("EngineAssociation"),
        "category": data.get("Category"), "description": data.get("Description", ""),
        "modules": [{"name": item.get("Name"), "type": item.get("Type"), "loading_phase": item.get("LoadingPhase", "Default"), "platforms": item.get("PlatformAllowList", item.get("WhitelistPlatforms", []))} for item in data.get("Modules", [])],
        "plugins": [{"name": item.get("Name"), "enabled": item.get("Enabled", False), "platforms": item.get("PlatformAllowList", item.get("WhitelistPlatforms", []))} for item in data.get("Plugins", [])],
        "target_platforms": data.get("TargetPlatforms", []),
    }


def parse_build(path: str, text: str) -> dict[str, Any]:
    def names(property_name: str) -> list[str]:
        blocks = re.findall(rf"{property_name}\s*\.\s*AddRange\s*\([^;]+", text, re.S)
        blocks += re.findall(rf"{property_name}\s*\.\s*Add\s*\([^;]+", text, re.S)
        return sorted(set(value for block in blocks for value in re.findall(r'"([A-Za-z0-9_]+)"', block)))
    return {"path": path, "module": Path(path).name.removesuffix(".Build.cs"), "public_dependencies": names("PublicDependencyModuleNames"), "private_dependencies": names("PrivateDependencyModuleNames"), "dynamically_loaded": names("DynamicallyLoadedModuleNames"), "include_paths": names("PublicIncludePaths") + names("PrivateIncludePaths"), "pch_usage": (re.search(r"PCHUsage\s*=\s*([^;]+)", text) or [None, None])[1]}


def parse_target(path: str, text: str) -> dict[str, Any]:
    target_type = (re.search(r"Type\s*=\s*TargetType\.([A-Za-z]+)", text) or [None, "Unknown"])[1]
    modules = sorted(set(re.findall(r'ExtraModuleNames(?:\.AddRange)?\s*\([^;]*?"([A-Za-z0-9_]+)"', text, re.S)))
    return {"path": path, "name": Path(path).name.removesuffix(".Target.cs"), "type": target_type, "modules": modules}


def parse_cpp(path: str, text: str, activity: dict[str, Any]) -> dict[str, Any]:
    reflected = []
    for kind, marker in (("class", "UCLASS"), ("struct", "USTRUCT"), ("enum", "UENUM")):
        pattern = rf"{marker}(?:\([^)]*\))?[\s\S]{{0,300}}?\b(?:class|struct|enum\s+class|enum)\s+(?:\w+_API\s+)?([A-Za-z_]\w*)"
        reflected += [{"name": name, "kind": kind, "reflection": marker} for name in re.findall(pattern, text)]
    base_classes = [{"name": name, "base": base} for name, base in re.findall(r"\bclass\s+(?:\w+_API\s+)?([A-Za-z_]\w*)\s*:\s*public\s+([A-Za-z_]\w*)", text)]
    return {
        "path": path, "lines": len(text.splitlines()), "reflected_types": reflected, "classes": base_classes,
        "ufunctions": len(re.findall(r"\bUFUNCTION\s*\(", text)), "uproperties": len(re.findall(r"\bUPROPERTY\s*\(", text)),
        "delegates": len(re.findall(r"DECLARE_(?:DYNAMIC_)?(?:MULTICAST_)?DELEGATE", text)),
        "replicated_properties": len(re.findall(r"\bReplicated(?:Using\s*=|\b)|DOREPLIFETIME", text)),
        "rpc_methods": len(re.findall(r"\b(?:Server|Client|NetMulticast)\b", text)),
        "tick": bool(re.search(r"\bTick\s*\(|PrimaryActorTick\.bCanEverTick\s*=\s*true", text)),
        "git_commit_touches": sum(item.get("commits", 0) for item in activity.get(path, {}).values()),
    }


def parse_ini(path: str, text: str) -> dict[str, Any]:
    sections, keys, section = [], [], "root"
    for line in text.splitlines():
        value = line.strip()
        if match := re.match(r"^\[([^]]+)]", value): section = match.group(1); sections.append(section)
        elif "=" in value and not value.startswith((";", "#")): keys.append({"section": section, "key": value.lstrip("+-").split("=", 1)[0].strip()})
    return {"path": path, "sections": sections, "keys": keys}


def risk_signals(root: Path, sources: list[dict[str, Any]]) -> list[dict[str, Any]]:
    results = []
    checks = (
        ("large_source_file", lambda item, text: item["lines"] >= 800, "Large source files may combine multiple responsibilities."),
        ("actor_iteration", lambda item, text: bool(re.search(r"TActorIterator|GetAllActorsOfClass", text)), "World-wide actor searches may be expensive in frequent paths."),
        ("synchronous_asset_load", lambda item, text: bool(re.search(r"LoadObject<|StaticLoadObject|LoadSynchronous\s*\(", text)), "Synchronous asset loading may cause runtime stalls."),
        ("tick_enabled", lambda item, text: item["tick"], "Per-frame Tick code deserves profiling and lifecycle review."),
        ("dynamic_object_lookup", lambda item, text: bool(re.search(r"FindObject<|FindComponentByClass|GetComponentByClass", text)), "Repeated dynamic lookup may deserve caching or narrower ownership."),
    )
    for item in sources:
        text = read(root / item["path"])
        for kind, predicate, rationale in checks:
            if predicate(item, text): results.append({"type": kind, "path": item["path"], "confidence": "medium", "severity": "review", "rationale": rationale})
    return results


def gameplay_systems(paths: set[str], activity: dict[str, Any]) -> list[dict[str, Any]]:
    results = []
    for name, keywords in SYSTEM_KEYWORDS.items():
        matched = sorted(path for path in paths if any(re.search(rf"(?:^|[/_. -]){re.escape(word)}s?(?:[/_. -]|$)", path.casefold()) for word in keywords))
        if len(matched) < 2: continue
        directories = Counter(str(Path(path).parent) for path in matched)
        touches = sum(sum(author.get("commits", 0) for author in activity.get(path, {}).values()) for path in matched)
        score = len(matched) + sum(Path(path).suffix.casefold() in {".cpp", ".h"} for path in matched) * 2
        results.append({"name": name, "confidence": "high" if score >= 8 else "medium", "evidence_score": score, "file_count": len(matched), "files": matched[:100], "primary_directories": [item[0] for item in directories.most_common(5)], "git_commit_touches": touches, "confirmation_required": True})
    return sorted(results, key=lambda item: (-item["evidence_score"], item["name"]))


def empty_result(status: str = "not_unreal") -> dict[str, Any]:
    return {"status": status, "summary": {}, "project": {}, "modules": [], "targets": [], "plugins": [], "source": [], "blueprints_assets": {}, "maps": [], "configuration": [], "input": {}, "platforms": [], "tests": {}, "gameplay_systems": [], "signals": [], "method": "", "limitations": []}


def analyze_unreal(root: Path, files: list[dict[str, Any]], git_data: dict[str, Any]) -> dict[str, Any]:
    paths = {item["path"] for item in files}; projects = sorted(path for path in paths if path.endswith(".uproject"))
    if not projects: return empty_result()
    activity = git_data.get("_file_author_activity", {})
    descriptor = parse_descriptor(projects[0], read_json(root / projects[0]))
    builds = [parse_build(path, read(root / path)) for path in sorted(path for path in paths if path.endswith(".Build.cs"))]
    targets = [parse_target(path, read(root / path)) for path in sorted(path for path in paths if path.endswith(".Target.cs"))]
    source = [parse_cpp(path, read(root / path), activity) for path in sorted(path for path in paths if Path(path).suffix.casefold() in {".h", ".hpp", ".cpp", ".cc"})]
    plugin_files = sorted(path for path in paths if path.endswith(".uplugin"))
    plugins = [{**parse_descriptor(path, read_json(root / path)), "name": Path(path).stem, "enabled_by_default": read_json(root / path).get("EnabledByDefault", False)} for path in plugin_files]
    configs = [parse_ini(path, read(root / path)) for path in sorted(path for path in paths if path.startswith("Config/") and path.endswith(".ini"))]
    assets = sorted(path for path in paths if Path(path).suffix.casefold() == ".uasset"); maps = sorted(path for path in paths if Path(path).suffix.casefold() == ".umap")
    asset_types = Counter((Path(path).stem.split("_")[0] if "_" in Path(path).stem else "Unclassified") for path in assets)
    tests = sorted(path for path in paths if re.search(r"(^|/)(Tests?|Specs?)(/|_)|\bIMPLEMENT_(?:SIMPLE|COMPLEX)_AUTOMATION_TEST\b", path, re.I))
    for item in source:
        if re.search(r"IMPLEMENT_(?:SIMPLE|COMPLEX)_AUTOMATION_TEST|BEGIN_DEFINE_SPEC", read(root / item["path"])): tests.append(item["path"])
    tests = sorted(set(tests))
    input_keys = [key for config in configs for key in config["keys"] if "Input" in key["section"] or key["key"] in {"ActionMappings", "AxisMappings"}]
    platforms = sorted(set(descriptor["target_platforms"] + [platform for target in targets for platform in ([] if target["type"] == "Unknown" else [target["type"]])]))
    systems = gameplay_systems(paths, activity); signals = risk_signals(root, source)
    return {
        "status": "assessed", "summary": {"projects": len(projects), "modules": len(builds), "targets": len(targets), "plugins": len(plugins), "source_files": len(source), "reflected_types": sum(len(item["reflected_types"]) for item in source), "blueprint_assets": len(assets), "maps": len(maps), "configuration_files": len(configs), "tests": len(tests), "gameplay_systems": len(systems), "signals": len(signals)},
        "project": descriptor, "modules": builds, "targets": targets, "plugins": plugins, "source": source,
        "blueprints_assets": {"files": assets, "count": len(assets), "naming_prefixes": dict(sorted(asset_types.items()))}, "maps": maps,
        "configuration": configs, "input": {"declarations": input_keys, "count": len(input_keys)}, "platforms": platforms,
        "tests": {"files": tests, "automation_macros": sum(bool(re.search(r"IMPLEMENT_(?:SIMPLE|COMPLEX)_AUTOMATION_TEST|BEGIN_DEFINE_SPEC", read(root / path))) for path in tests if path in paths)},
        "gameplay_systems": systems, "signals": signals,
        "method": "Static .uproject/.uplugin descriptors, module and target rules, C++ reflection macros, config, Content assets, tests, and Git-activity evidence",
        "limitations": ["Binary .uasset and .umap contents are inventoried but not decoded", "Blueprint graphs, runtime object relationships, packaging success, and editor-only metadata require Unreal tooling", "Gameplay categories and review findings are signals requiring human confirmation", "Git activity does not prove formal ownership or product impact"],
    }
