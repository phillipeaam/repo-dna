"""Structured Android project analysis from Gradle, manifests, source, and resources."""

from __future__ import annotations

import re
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path
from typing import Any


ANDROID_NS = "{http://schemas.android.com/apk/res/android}"
COMPONENT_TAGS = {"activity": "Activity", "activity-alias": "ActivityAlias", "service": "Service", "receiver": "BroadcastReceiver", "provider": "ContentProvider"}
SOURCE_TYPES = {"Activity": r"(?:Activity|AppCompatActivity|ComponentActivity)$", "Fragment": r"Fragment$", "Service": r"Service$", "BroadcastReceiver": r"BroadcastReceiver$", "ContentProvider": r"ContentProvider$", "ViewModel": r"ViewModel$", "Repository": r"Repository$", "Adapter": r"Adapter$"}


def read(path: Path) -> str:
    try: return path.read_text(encoding="utf-8", errors="replace")[:2_000_000]
    except OSError: return ""


def gradle_block(text: str, name: str) -> str:
    match = re.search(rf"\b{re.escape(name)}\s*\{{", text)
    if not match: return ""
    depth, start = 1, match.end()
    for index in range(start, len(text)):
        if text[index] == "{": depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0: return text[start:index]
    return text[start:]


def manifest_data(root: Path, paths: set[str]) -> tuple[list[dict[str, Any]], list[str], list[str]]:
    components, permissions, manifests = [], [], sorted(path for path in paths if path.endswith("AndroidManifest.xml"))
    for path in manifests:
        try: tree = ET.parse(root / path)
        except (ET.ParseError, OSError): continue
        manifest = tree.getroot()
        permissions.extend(node.get(f"{ANDROID_NS}name", "") for node in manifest if node.tag.split("}")[-1].startswith("uses-permission"))
        application = next((node for node in manifest if node.tag.split("}")[-1] == "application"), None)
        if application is None: continue
        for node in application:
            tag = node.tag.split("}")[-1]
            if tag in COMPONENT_TAGS:
                components.append({"type": COMPONENT_TAGS[tag], "name": node.get(f"{ANDROID_NS}name", ""), "exported": node.get(f"{ANDROID_NS}exported"), "manifest": path, "intent_filters": sum(child.tag.split("}")[-1] == "intent-filter" for child in node)})
    return components, sorted(set(filter(None, permissions))), manifests


def gradle_data(root: Path, paths: set[str]) -> dict[str, Any]:
    files = sorted(path for path in paths if Path(path).name in {"build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts", "gradle.properties", "libs.versions.toml"})
    dependencies, plugins, build_types, flavors = [], [], set(), set()
    for path in files:
        text = read(root / path)
        dependencies.extend(re.findall(r"(?:implementation|api|compileOnly|runtimeOnly|testImplementation|androidTestImplementation|kapt|ksp)\s*\(?\s*[\"']([^\"']+)", text))
        plugins.extend(re.findall(r"(?:id\s*\(?\s*[\"']|alias\s*\(libs\.plugins\.)([A-Za-z0-9_.-]+)", text))
        for block_name, output in (("buildTypes", build_types), ("productFlavors", flavors)):
            block = gradle_block(text, block_name)
            for created, named in re.findall(r"^\s*(?:create\s*\(\s*[\"']([^\"']+)[\"']\s*\)|([A-Za-z][\w-]*))\s*\{", block, re.M): output.add(created or named)
    return {"files": files, "plugins": sorted(set(filter(None, plugins))), "dependencies": sorted(set(dependencies)), "build_types": sorted(build_types), "product_flavors": sorted(flavors), "build_variants": sorted(f"{flavor}{kind[:1].upper()}{kind[1:]}" for flavor in flavors for kind in build_types)}


def analyze_android(root: Path, files: list[dict[str, Any]], code: dict[str, Any], git_data: dict[str, Any]) -> dict[str, Any]:
    paths = {item["path"] for item in files}
    if not any(path.endswith("AndroidManifest.xml") for path in paths):
        return {"status":"not_android","summary":{},"components":[],"screens":[],"data_layer":{},"networking":{},"resources":{},"gradle":{},"permissions":[]}
    manifest_components, permissions, manifests = manifest_data(root, paths)
    source_components = []
    activity = git_data.get("_file_author_activity", {})
    for symbol in code.get("symbols", []):
        if symbol.get("language") not in {"Java", "Kotlin"}: continue
        name = symbol.get("name", "").split(".")[-1]
        component_type = next((kind for kind, pattern in SOURCE_TYPES.items() if re.search(pattern, name)), None)
        if component_type:
            path = symbol.get("path", "")
            source_components.append({"type":component_type,"name":name,"path":path,"git_commit_touches":sum(value.get("commits",0) for value in activity.get(path,{}).values())})
    components = [dict(item) for item in manifest_components]
    for source in source_components:
        match = next((item for item in components if item["type"] == source["type"] and item["name"].split(".")[-1] == source["name"]), None)
        if match:
            match["path"] = source["path"]
            match["git_commit_touches"] = source["git_commit_touches"]
            match["evidence"] = ["AndroidManifest.xml", "Java/Kotlin symbol"]
        else:
            source["evidence"] = ["Java/Kotlin symbol naming"]
            components.append(source)
    layouts = sorted(path for path in paths if re.search(r"/res/layout(?:-[^/]+)?/.*\.xml$", path))
    navigation = sorted(path for path in paths if re.search(r"/res/navigation/.*\.xml$", path))
    resources = {kind: sorted(path for path in paths if f"/res/{kind}" in path) for kind in ("layout", "values", "drawable", "mipmap", "menu", "xml", "raw")}
    imports = "\n".join(" ".join(item.get("imports", [])) for item in code.get("imports", []))
    dependency_text = "\n".join(gradle_data(root, paths).get("dependencies", []))
    corpus = f"{imports}\n{dependency_text}"
    technologies = {
        "SQLite": bool(re.search(r"SQLite", corpus, re.I)), "Room": bool(re.search(r"androidx\.room|\broom-", corpus, re.I)),
        "Realm": bool(re.search(r"\brealm\b", corpus, re.I)), "Retrofit": bool(re.search(r"retrofit", corpus, re.I)),
        "OkHttp": bool(re.search(r"okhttp", corpus, re.I)), "JSON": bool(re.search(r"gson|moshi|kotlinx.serialization|org.json", corpus, re.I)),
        "XML": bool(layouts or navigation), "Google APIs": bool(re.search(r"com\.google|firebase|play-services", corpus, re.I)),
    }
    data_files = sorted(path for path in paths if re.search(r"repository|database|dao|entity|room|realm|sqlite|datasource", path, re.I))
    network_files = sorted(path for path in paths if re.search(r"network|api|retrofit|okhttp|service", path, re.I))
    gradle = gradle_data(root, paths)
    tests = {"unit": sorted(path for path in paths if "/src/test/" in path), "instrumented": sorted(path for path in paths if "/src/androidTest/" in path)}
    screens = sorted(({"type":item["type"],"name":item["name"],"path":item.get("path") or item.get("manifest"),"git_commit_touches":item.get("git_commit_touches",0)} for item in components if item["type"] in {"Activity","ActivityAlias","Fragment"}), key=lambda item:item["name"])
    counts = Counter(item["type"] for item in components)
    return {"status":"assessed","summary":{"components":len(components),"screens":len(screens),"permissions":len(permissions),"layouts":len(layouts),"dependencies":len(gradle["dependencies"]),"build_variants":len(gradle["build_variants"]),"unit_tests":len(tests["unit"]),"instrumented_tests":len(tests["instrumented"])},"manifests":manifests,"gradle":gradle,"components":components,"component_counts":dict(counts),"permissions":permissions,"screens":screens,"resources":{"layouts":layouts,"navigation":navigation,"by_type":resources},"data_layer":{"files":data_files,"technologies":{key:value for key,value in technologies.items() if key in {"SQLite","Room","Realm"}}},"networking":{"files":network_files,"technologies":{key:value for key,value in technologies.items() if key in {"Retrofit","OkHttp","JSON","XML","Google APIs"}}},"tests":tests,"method":"Android manifests, Gradle declarations, Java/Kotlin symbols and imports, XML resources, and Git activity","limitations":["Components inferred from naming require confirmation when inheritance could not be resolved.","Build variants are statically approximated and do not execute Gradle.","Technology presence does not prove active runtime use."]}
