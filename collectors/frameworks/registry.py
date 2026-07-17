"""Specialized framework adapters evaluated over structured repository facts."""

from __future__ import annotations

import re
from collections import defaultdict
from typing import Any

from .base import FrameworkAdapter, Marker


def marker(source: str, pattern: str, concept: str, weight: int = 1) -> Marker:
    return Marker(source, pattern, concept, weight)


ADAPTERS = (
    FrameworkAdapter("Unity", "game engine", frozenset({"C#"}), (
        marker("import", r"^UnityEngine(?:\.|$)", "Unity runtime", 4),
        marker("import", r"^UnityEditor(?:\.|$)", "Editor tooling", 4),
        marker("path", r"(^|/)Assets/", "Unity asset tree", 3),
        marker("path", r"(^|/)ProjectSettings/", "Unity project settings", 4),
        marker("symbol", r"(?:MonoBehaviour|ScriptableObject|Editor|EditorWindow)$", "Unity component types", 2),
        marker("call", r"^(?:GetComponent|Instantiate|Destroy|SceneManager\.)", "Unity lifecycle/API usage", 1),
    )),
    FrameworkAdapter("ASP.NET Core", "web framework", frozenset({"C#"}), (
        marker("dependency", r"^Microsoft\.AspNetCore", "ASP.NET packages", 5),
        marker("import", r"^Microsoft\.AspNetCore(?:\.|$)", "ASP.NET namespaces", 4),
        marker("symbol", r"Controller$", "HTTP controllers", 2),
        marker("call", r"^(?:MapGet|MapPost|MapPut|MapDelete|AddControllers|UseRouting|UseEndpoints)$", "HTTP pipeline", 2),
        marker("path", r"(^|/)(Controllers|Middleware|Endpoints)/", "Web application structure", 1),
    )),
    FrameworkAdapter("Spring", "application framework", frozenset({"Java", "Kotlin"}), (
        marker("dependency", r"(?:^|[.-])spring(?:-boot)?(?:[.-]|$)", "Spring dependencies", 5),
        marker("import", r"^org\.springframework(?:\.|$)", "Spring namespaces", 4),
        marker("symbol", r"(?:Controller|Repository|Service|Configuration)$", "Spring stereotype roles", 2),
        marker("path", r"(^|/)(controller|repository|service|config)/", "Layered Spring structure", 1),
    )),
    FrameworkAdapter("Android", "application platform", frozenset({"Java", "Kotlin"}), (
        marker("dependency", r"^(?:androidx\.|com\.android\.|com\.google\.android)", "Android dependencies", 5),
        marker("import", r"^(?:android|androidx)(?:\.|$)", "Android namespaces", 4),
        marker("path", r"(^|/)AndroidManifest\.xml$", "Android manifest", 5),
        marker("path", r"(^|/)res/(?:layout|values|drawable)/", "Android resources", 2),
        marker("symbol", r"(?:Activity|Fragment|ViewModel|Application|Service)$", "Android components", 2),
        marker("call", r"^(?:setContentView|startActivity|setContent)$", "Android UI/lifecycle API", 1),
    )),
    FrameworkAdapter("Flutter", "UI framework", frozenset({"Dart"}), (
        marker("dependency", r"^flutter$", "Flutter SDK dependency", 6),
        marker("import", r"^package:flutter/", "Flutter libraries", 4),
        marker("symbol", r"(?:Widget|State|StatelessWidget|StatefulWidget)$", "Flutter widget types", 2),
        marker("call", r"^(?:runApp|setState|Navigator\.)", "Flutter runtime/navigation", 2),
        marker("path", r"(^|/)lib/(?:screens|widgets|pages)/", "Flutter UI structure", 1),
    )),
    FrameworkAdapter("React", "UI library", frozenset({"JavaScript", "TypeScript"}), (
        marker("dependency", r"^(?:react|react-dom)$", "React dependencies", 5),
        marker("import", r"^(?:react|react-dom)(?:/|$)", "React modules", 4),
        marker("call", r"^(?:React\.)?(?:useState|useEffect|useMemo|useCallback|createContext|createRoot)$", "React hooks/runtime", 2),
        marker("path", r"(^|/)(?:components|hooks)/", "React component structure", 1),
    )),
    FrameworkAdapter("Next.js", "web framework", frozenset({"JavaScript", "TypeScript"}), (
        marker("dependency", r"^next$", "Next.js dependency", 6),
        marker("import", r"^next(?:/|$)", "Next.js modules", 4),
        marker("path", r"(^|/)(?:app|pages)/(?:page|layout|route|_app|_document)\.[jt]sx?$", "Next.js routing convention", 4),
        marker("symbol", r"^(?:getServerSideProps|getStaticProps|getStaticPaths|generateMetadata)$", "Next.js data lifecycle", 2),
    )),
)


def _facts(files: list[dict[str, Any]], code: dict[str, Any], dependencies: dict[str, Any]) -> dict[str, list[dict[str, str]]]:
    facts: dict[str, list[dict[str, str]]] = defaultdict(list)
    for manifest in dependencies.get("manifests", []):
        for dependency in manifest.get("dependencies", []):
            facts["dependency"].append({"value": dependency, "path": manifest.get("path", "")})
    for item in code.get("imports", []):
        for imported in item.get("imports", []):
            facts["import"].append({"value": imported, "path": item.get("path", "")})
    for item in code.get("symbols", []):
        facts["symbol"].append({"value": item.get("name", ""), "path": item.get("path", "")})
    for item in code.get("calls", []):
        facts["call"].append({"value": item.get("target", ""), "path": item.get("path", "")})
    for item in files:
        facts["path"].append({"value": item.get("path", ""), "path": item.get("path", "")})
    return facts


def analyze_frameworks(files: list[dict[str, Any]], code: dict[str, Any], dependencies: dict[str, Any]) -> dict[str, Any]:
    facts = _facts(files, code, dependencies)
    repository_languages = set(code.get("languages_analyzed", []))
    detected: list[dict[str, Any]] = []
    for adapter in ADAPTERS:
        if adapter.languages.isdisjoint(repository_languages):
            continue
        evidence: list[dict[str, Any]] = []
        concepts: set[str] = set()
        score = 0
        matched_sources: set[str] = set()
        for rule in adapter.markers:
            matches = [fact for fact in facts[rule.source] if re.search(rule.pattern, fact["value"], re.I)]
            if not matches:
                continue
            score += rule.weight
            concepts.add(rule.concept)
            matched_sources.add(rule.source)
            evidence.extend({"source": rule.source, "value": fact["value"], "path": fact["path"], "concept": rule.concept} for fact in matches[:5])
        if score < 4:
            continue
        confidence = "high" if score >= 8 or (score >= 6 and len(matched_sources) >= 2) else "medium"
        detected.append({
            "name": adapter.name, "family": adapter.family, "confidence": confidence, "score": score,
            "languages": sorted(adapter.languages & repository_languages),
            "concepts": sorted(concepts), "evidence": evidence[:30],
            "files": sorted({item["path"] for item in evidence if item["path"]})[:50],
        })
    detected.sort(key=lambda item: (-item["score"], item["name"]))
    return {
        "detected": detected,
        "count": len(detected),
        "method": "Weighted dependency, import, syntax-symbol, call, and conventional-path evidence",
        "limitations": [
            "Framework detection identifies repository evidence, not runtime configuration or feature completeness.",
            "Medium-confidence findings should be reviewed when only one evidence category is available.",
        ],
    }
