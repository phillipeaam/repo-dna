"""Structured Unity configuration, gameplay, and heuristic signal analysis."""

from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


GAMEPLAY_PATTERNS = {
    "Combat": r"combat|weapon|attack|damage|health|hitbox|projectile",
    "Character": r"character|player|avatar|pawn",
    "Movement": r"movement|locomotion|motor|move|jump|dash",
    "Camera": r"camera|cinemachine",
    "AI": r"\bai\b|enemy|npc|behavior|behaviour|navmesh|pathfinding",
    "Inventory": r"inventory|item|equipment|loot",
    "Abilities": r"ability|abilities|skill|spell|buff|debuff",
    "Quests": r"quest|mission|objective|dialogue",
    "Progression": r"progress|level|experience|achievement|unlock",
    "Save": r"save|persistence|serialize|checkpoint|playerprefs",
    "Networking": r"network|multiplayer|photon|mirror|fusion|netcode|lobby|matchmaking",
    "UI": r"\bui\b|hud|menu|canvas|uitoolkit|visualelement",
    "Audio": r"audio|music|sound|fmod|wwise",
    "Animation": r"animation|animator|timeline|playable",
    "Localization": r"localization|localisation|locale|stringtable",
    "Analytics": r"analytics|telemetry|tracking|attribution",
    "Tools": r"editor|tool|inspector|propertydrawer|menuitem",
    "LiveOps": r"liveops|remoteconfig|featureflag|economy|iap|inapp|season|battlepass",
}


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")[:2_000_000]
    except OSError:
        return ""


def line_matches(text: str, pattern: str) -> list[int]:
    regex = re.compile(pattern)
    return [index for index, line in enumerate(text.splitlines(), 1) if regex.search(line)]


def package_manifest(root: Path) -> dict[str, str]:
    try:
        return json.loads(read(root / "Packages/manifest.json")).get("dependencies", {})
    except (json.JSONDecodeError, AttributeError):
        return {}


def setting_values(text: str, key: str) -> list[str]:
    return [value.strip().strip('"') for value in re.findall(rf"^\s*{re.escape(key)}:\s*(.+?)\s*$", text, re.M)]


def configuration(root: Path, files: list[dict[str, Any]]) -> dict[str, Any]:
    paths = {item["path"] for item in files}
    packages = package_manifest(root)
    player = read(root / "ProjectSettings/ProjectSettings.asset")
    quality = read(root / "ProjectSettings/QualitySettings.asset")
    graphics = read(root / "ProjectSettings/GraphicsSettings.asset")
    build = read(root / "ProjectSettings/EditorBuildSettings.asset")
    enabled_scenes, current_enabled = [], None
    for line in build.splitlines():
        enabled = re.search(r"enabled:\s*(\d+)", line)
        if enabled: current_enabled = enabled.group(1) == "1"
        scene = re.search(r"path:\s*(.+\.unity)", line)
        if scene and current_enabled:
            enabled_scenes.append(scene.group(1).strip())
    render_pipeline = "HDRP" if "com.unity.render-pipelines.high-definition" in packages else "URP" if "com.unity.render-pipelines.universal" in packages else "Built-in or custom"
    input_system = "New Input System" if "com.unity.inputsystem" in packages else "Legacy Input Manager or custom"
    active_input = setting_values(player, "activeInputHandler")
    if active_input:
        input_system = {0: "Legacy Input Manager", 1: "New Input System", 2: "Both"}.get(int(active_input[0]) if active_input[0].isdigit() else -1, input_system)
    addressable_files = sorted(path for path in paths if "AddressableAssetsData/AssetGroups/" in path and path.endswith(".asset"))
    addressable_groups = []
    for path in addressable_files[:100]:
        names = setting_values(read(root / path), "m_Name")
        if names: addressable_groups.append({"name": names[0], "path": path})
    test_assemblies, asmdefs = [], sorted(path for path in paths if path.endswith(".asmdef"))
    for path in asmdefs:
        content = read(root / path)
        if "TestAssemblies" in content or "UNITY_INCLUDE_TESTS" in content:
            test_assemblies.append(path)
    native = []
    for path in sorted(paths):
        if path.casefold().endswith((".dll", ".so", ".dylib", ".bundle", ".aar", ".jar")):
            platform = next((name for name in ("Android", "iOS", "Windows", "macOS", "Linux") if name.casefold() in path.casefold()), "unspecified")
            native.append({"path": path, "platform": platform})
    platform_code = [path for path in sorted(paths) if re.search(r"(^|/)(Editor|Android|iOS|Windows|macOS|Linux|WebGL)(/|$)", path, re.I)]
    define_symbols = setting_values(player, "scriptingDefineSymbols")
    return {
        "build": {"enabled_scenes": enabled_scenes, "enabled_scene_count": len(enabled_scenes)},
        "rendering": {"pipeline": render_pipeline, "graphics_settings_present": bool(graphics), "configured_pipeline_assets": setting_values(graphics, "m_CustomRenderPipeline") + setting_values(graphics, "m_RenderPipelineAsset")},
        "input": {"system": input_system, "package_version": packages.get("com.unity.inputsystem")},
        "player": {"scripting_backend": setting_values(player, "scriptingBackend"), "api_compatibility_level": setting_values(player, "apiCompatibilityLevelPerPlatform") or setting_values(player, "apiCompatibilityLevel"), "define_symbols": define_symbols},
        "platform_signals": sorted(set(re.findall(r"\b(Android|iPhone|iOS|Standalone|WebGL|Windows|Linux|OSX)\b", player))),
        "quality_levels": setting_values(quality, "name"),
        "packages": dict(sorted(packages.items())), "localization_package_version": packages.get("com.unity.localization"),
        "addressables": {"package_version": packages.get("com.unity.addressables"), "groups": addressable_groups},
        "assemblies": {"asmdef_count": len(asmdefs), "test_assemblies": test_assemblies},
        "native_plugins": native, "platform_specific_code": platform_code,
    }


def gameplay_systems(files: list[dict[str, Any]], code: dict[str, Any], git_data: dict[str, Any]) -> list[dict[str, Any]]:
    source_paths = [item["path"] for item in files if item.get("language") == "C#"]
    symbol_text = defaultdict(list)
    for symbol in code.get("symbols", []): symbol_text[symbol.get("path", "")].append(symbol.get("name", ""))
    import_text = {item.get("path", ""): " ".join(item.get("imports", [])) for item in code.get("imports", [])}
    activity = git_data.get("_file_author_activity", {})
    changed = {item["path"]: item["commits"] for item in git_data.get("most_changed_files", [])}
    results = []
    for category, pattern in GAMEPLAY_PATTERNS.items():
        regex = re.compile(pattern, re.I); evidence_files, score = [], 0
        for path in source_paths:
            path_hit = bool(regex.search(path)); symbol_hit = bool(regex.search(" ".join(symbol_text[path]))); import_hit = bool(regex.search(import_text.get(path, "")))
            if path_hit or symbol_hit or import_hit:
                evidence_files.append(path); score += path_hit * 2 + symbol_hit * 2 + import_hit
        if not evidence_files: continue
        dirs = Counter(path.rsplit("/", 1)[0] if "/" in path else "[root]" for path in evidence_files)
        commit_touches = sum(metrics.get("commits", 0) for path in evidence_files for metrics in activity.get(path, {}).values())
        frequent = [{"path": path, "commits": changed[path]} for path in evidence_files if changed.get(path, 0) >= 2]
        confidence = "high" if len(evidence_files) >= 5 and score >= 10 else "medium" if len(evidence_files) >= 2 or score >= 4 else "low"
        results.append({"name": category, "confidence": confidence, "score": score, "file_count": len(evidence_files), "files": evidence_files[:100], "primary_directories": [name for name, _ in dirs.most_common(5)], "git": {"matching_commit_touches": commit_touches, "frequently_changed_files": frequent[:20]}, "evidence_basis": ["path tokens", "AST symbols", "imports"], "confirmation_required": True})
    return sorted(results, key=lambda item: (-item["score"], item["name"]))


def performance_signals(root: Path, files: list[dict[str, Any]], graphs: dict[str, Any], asmdef_count: int) -> list[dict[str, Any]]:
    definitions = [
        ("frequent_object_lookup", r"\b(?:FindObjectOfType|FindObjectsOfType|GameObject\.Find)\s*\(", "Repeated scene-wide lookup can be costly when used frequently."),
        ("resources_load", r"\bResources\.Load(?:Async)?\s*<|\bResources\.Load(?:Async)?\s*\(", "Resources loading can create synchronous loading or lifecycle pressure."),
        ("instantiate_destroy", r"\b(?:Instantiate|Destroy)\s*\(", "Runtime object creation/destruction can contribute to frame spikes or allocations."),
        ("possible_allocation", r"\bnew\s+(?:List|Dictionary|HashSet|Queue|Stack|WaitForSeconds)\b|\.ToList\s*\(|\.ToArray\s*\(", "Allocation-like APIs in frequently executed code merit profiling."),
    ]
    signals = []
    for item in files:
        if item.get("language") != "C#": continue
        path, text = item["path"], read(root / item["path"])
        for signal_type, pattern, rationale in definitions:
            lines = line_matches(text, pattern)
            if lines:
                signals.append({"type": signal_type, "severity": "review", "confidence": "medium", "path": path, "occurrences": len(lines), "lines": lines[:20], "rationale": rationale})
        frame_match = re.search(r"\b(?:void\s+)?(Update|FixedUpdate|LateUpdate)\s*\([^)]*\)\s*\{([\s\S]{0,5000})", text)
        if frame_match:
            frame_body = frame_match.group(2)[:2000]
            if re.search(r"\.(?:Where|Select|OrderBy|GroupBy|ToList|ToArray)\s*\(", frame_body):
                signals.append({"type":"linq_in_frame_method","severity":"review","confidence":"medium","path":path,"occurrences":1,"lines":[],"rationale":"LINQ inside a frame method can allocate; verify with profiling."})
            if frame_body.count("\n") >= 80:
                signals.append({"type":"large_frame_method","severity":"review","confidence":"medium","path":path,"occurrences":1,"lines":[],"rationale":"Large frame methods can hide expensive or tightly coupled work."})
            component_lookups = len(re.findall(r"\bGetComponent(?:InChildren|InParent)?\s*<", frame_body))
            if component_lookups:
                signals.append({"type":"get_component_in_frame_method","severity":"review","confidence":"medium","path":path,"occurrences":component_lookups,"lines":[],"rationale":"Component lookup inside a frame method can be repeated every frame; consider caching after profiling."})
        loop_allocations = len(re.findall(r"\b(?:for|foreach|while)\s*\([^)]*\)[\s\S]{0,1000}?\b(?:Instantiate|Destroy)\s*\(", text))
        if loop_allocations:
            signals.append({"type":"instantiate_destroy_in_loop","severity":"review","confidence":"medium","path":path,"occurrences":loop_allocations,"lines":[],"rationale":"Instantiate or Destroy appears near a loop body and can create spikes; confirm control flow and profile."})
        if "StartCoroutine" in text and not re.search(r"StopCoroutine|StopAllCoroutines|OnDisable|OnDestroy", text):
            signals.append({"type":"coroutine_lifecycle","severity":"review","confidence":"low","path":path,"occurrences":text.count("StartCoroutine"),"lines":[],"rationale":"Coroutine start calls were found without obvious lifecycle cancellation in the same file."})
        if re.search(r"(?:AddListener|\+=)", text) and not re.search(r"(?:RemoveListener|-=)", text):
            signals.append({"type":"event_listener_lifecycle","severity":"review","confidence":"low","path":path,"occurrences":1,"lines":[],"rationale":"Listener subscription was found without an obvious removal in the same file."})
        if item.get("lines", 0) >= 1000:
            signals.append({"type":"large_csharp_file","severity":"review","confidence":"high","path":path,"occurrences":1,"lines":[],"rationale":"The C# file exceeds 1,000 lines and may contain a large class or multiple responsibilities."})
    if not asmdef_count:
        signals.append({"type":"missing_assembly_definitions","severity":"review","confidence":"high","path":"Assets","occurrences":1,"lines":[],"rationale":"No asmdef files were detected; compile boundaries and dependency rules may be implicit."})
    for cycle in graphs.get("module_graph", {}).get("cycles", []):
        signals.append({"type":"approximate_dependency_cycle","severity":"review","confidence":"medium","path":" -> ".join(cycle),"occurrences":1,"lines":[],"rationale":"The approximate module graph contains a dependency cycle."})
    return signals[:500]


def analyze_unity(root: Path, files: list[dict[str, Any]], code: dict[str, Any], git_data: dict[str, Any], graphs: dict[str, Any]) -> dict[str, Any]:
    if not (root / "Assets").is_dir() or not (root / "ProjectSettings/ProjectVersion.txt").is_file():
        return {"status": "not_unity", "configuration": {}, "gameplay_systems": [], "signals": [], "summary": {}}
    config = configuration(root, files)
    gameplay = gameplay_systems(files, code, git_data)
    signals = performance_signals(root, files, graphs, config["assemblies"]["asmdef_count"])
    return {"status":"assessed","configuration":config,"gameplay_systems":gameplay,"signals":signals,"summary":{"gameplay_systems":len(gameplay),"high_confidence_systems":sum(item["confidence"]=="high" for item in gameplay),"performance_and_risk_signals":len(signals)},"method":"Unity serialized settings, package manifests, AST/code evidence, Git activity, and explicit heuristics","limitations":["Signals are review candidates, not confirmed bugs.","Serialized Unity settings vary across editor versions.","Gameplay categories are inferred and require confirmation."]}
