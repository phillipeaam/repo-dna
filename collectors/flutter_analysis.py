"""Structured Flutter analysis based only on verified repository evidence."""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from android_analysis import gradle_block, read


STATE_PACKAGES = {
    "BLoC": ("bloc", "flutter_bloc", "hydrated_bloc"),
    "Provider": ("provider",),
    "Riverpod": ("riverpod", "flutter_riverpod", "hooks_riverpod"),
    "GetX": ("get", "getx"),
    "MobX": ("mobx", "flutter_mobx"),
    "Redux": ("redux", "flutter_redux"),
}


def pubspec_sections(text: str) -> dict[str, dict[str, str]]:
    result: dict[str, dict[str, str]] = {"dependencies": {}, "dev_dependencies": {}}
    current = ""
    for line in text.splitlines():
        heading = re.match(r"^([a-z_]+):\s*$", line)
        if heading: current = heading.group(1); continue
        if current in result:
            item = re.match(r"^\s{2}([A-Za-z0-9_.-]+):\s*(.*?)\s*$", line)
            if item: result[current][item.group(1)] = item.group(2) or "sdk/path/git declaration"
    return result


def assets_from_pubspec(text: str) -> list[str]:
    block = re.search(r"^\s{2}assets:\s*$([\s\S]*?)(?=^\s{2}[A-Za-z_][\w-]*:\s*$|\Z)", text, re.M)
    return re.findall(r"^\s*-\s+(.+?)\s*$", block.group(1), re.M) if block else []


def android_flavors(root: Path) -> list[str]:
    for relative in ("android/app/build.gradle", "android/app/build.gradle.kts"):
        text = read(root / relative)
        if not text: continue
        block = gradle_block(text, "productFlavors")
        values = []
        for created, named in re.findall(r"^\s*(?:create\s*\(\s*[\"']([^\"']+)[\"']\s*\)|([A-Za-z][\w-]*))\s*\{", block, re.M): values.append(created or named)
        return sorted(set(values))
    return []


def analyze_flutter(root: Path, files: list[dict[str, Any]], git_data: dict[str, Any]) -> dict[str, Any]:
    pubspec = read(root / "pubspec.yaml")
    if not pubspec or not re.search(r"^\s*flutter:\s*$|sdk:\s*flutter", pubspec, re.M):
        return {"status":"not_flutter","summary":{},"dependencies":{},"widgets":[],"screens":[],"routes":[],"state_management":[],"localization":{},"assets":[],"platform_channels":[],"native_bridges":{},"tests":{},"flavors":{}}
    paths = {item["path"] for item in files}; sections = pubspec_sections(pubspec)
    dependencies = {**sections["dependencies"], **sections["dev_dependencies"]}
    activity = git_data.get("_file_author_activity", {})
    widgets, screens, routes, channels = [], [], [], []
    state_evidence: dict[str, set[str]] = {name: set() for name in STATE_PACKAGES}
    for path in sorted(value for value in paths if value.endswith(".dart")):
        text = read(root / path)
        for name, base in re.findall(r"class\s+([A-Za-z_]\w*)\s+extends\s+(StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget|HookWidget|GetView|GetWidget)", text):
            row={"name":name,"base":base,"path":path,"git_commit_touches":sum(item.get("commits",0) for item in activity.get(path,{}).values())}
            widgets.append(row)
            if re.search(r"(?:screen|page|view)(?:\.dart|/|$)", path, re.I) or re.search(r"(?:Screen|Page|View)$", name): screens.append(row)
        route_values = re.findall(r"(?:GoRoute\s*\([^)]*?path\s*:|GetPage\s*\([^)]*?name\s*:|RouteSettings\s*\([^)]*?name\s*:|[\"']?)([\"']/[^\"']*[\"'])\s*[:),]", text, re.S)
        routes.extend({"route":value.strip("'\""),"path":path} for value in route_values)
        for channel_type, channel_name in re.findall(r"\b(MethodChannel|EventChannel|BasicMessageChannel)\s*\(\s*[\"']([^\"']+)", text):
            channels.append({"type":channel_type,"name":channel_name,"dart_path":path})
        for manager, packages in STATE_PACKAGES.items():
            if any(re.search(rf"package:{re.escape(package)}/", text) for package in packages): state_evidence[manager].add(path)
    native_paths = sorted(path for path in paths if re.search(r"^(android/.+\.(?:kt|java)|ios/.+\.(?:swift|m|mm))$", path, re.I))
    for channel in channels:
        channel["native_matches"] = [path for path in native_paths if channel["name"] in read(root / path)]
    arb = sorted(path for path in paths if path.endswith(".arb"))
    localization = {"arb_files":arb,"l10n_config":next((path for path in paths if Path(path).name=="l10n.yaml"),None),"packages":{name:version for name,version in dependencies.items() if name in {"flutter_localizations","intl","easy_localization","slang"}}}
    unit_tests=sorted(path for path in paths if path.startswith("test/") and path.endswith("_test.dart")); integration=sorted(path for path in paths if path.startswith("integration_test/") and path.endswith(".dart"))
    dart_flavors=sorted(path for path in paths if re.search(r"(^|/)main_[^/]+\.dart$",path)); ios_schemes=sorted(path for path in paths if path.endswith(".xcscheme"))
    state=[{"name":name,"packages":[package for package in packages if package in dependencies],"evidence_files":sorted(evidence),"confidence":"high" if any(package in dependencies for package in packages) and evidence else "medium"} for name,packages in STATE_PACKAGES.items() if (evidence:=state_evidence[name]) or any(package in dependencies for package in packages)]
    return {"status":"assessed","summary":{"dependencies":len(dependencies),"widgets":len(widgets),"screens":len(screens),"routes":len(routes),"state_management":len(state),"assets":len(assets_from_pubspec(pubspec)),"platform_channels":len(channels),"unit_tests":len(unit_tests),"integration_tests":len(integration)},"pubspec":"pubspec.yaml","dependencies":{"runtime":sections["dependencies"],"development":sections["dev_dependencies"]},"widgets":widgets,"screens":screens,"routes":routes,"state_management":state,"localization":localization,"assets":assets_from_pubspec(pubspec),"platform_channels":channels,"native_bridges":{"files":native_paths,"matched_channels":sum(bool(item["native_matches"]) for item in channels)},"tests":{"unit":unit_tests,"integration":integration},"flavors":{"android":android_flavors(root),"ios_schemes":ios_schemes,"dart_entrypoints":dart_flavors},"method":"Verified Flutter pubspec, Dart declarations, native bridge source, platform configuration, and Git activity","limitations":["Routes created dynamically may not be visible statically.","State-management package presence does not prove architectural consistency.","Flavors are approximated without executing Flutter, Gradle, or Xcode."]}
