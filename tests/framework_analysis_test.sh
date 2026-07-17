#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PYTHONPATH="$SOURCE_ROOT/collectors" python - <<'PY'
from frameworks import analyze_frameworks


def detect(language, *, dependencies=(), imports=(), symbols=(), calls=(), paths=()):
    code = {
        "languages_analyzed": [language],
        "imports": [{"path": "src/sample", "imports": list(imports)}],
        "symbols": [{"path": "src/sample", "name": value} for value in symbols],
        "calls": [{"path": "src/sample", "target": value} for value in calls],
    }
    manifests = [{"path": "manifest", "dependencies": list(dependencies)}]
    files = [{"path": path} for path in paths]
    return analyze_frameworks(files, code, {"manifests": manifests})["detected"]


cases = [
    ("Unity", detect("C#", imports=["UnityEngine"], paths=["Assets/Scripts/Player.cs"])),
    ("ASP.NET Core", detect("C#", dependencies=["Microsoft.AspNetCore.Mvc"], imports=["Microsoft.AspNetCore.Mvc"])),
    ("Spring", detect("Java", dependencies=["spring-boot-starter-web"], imports=["org.springframework.web.bind.annotation"])),
    ("Android", detect("Kotlin", imports=["androidx.activity.ComponentActivity"], paths=["app/src/main/AndroidManifest.xml"])),
    ("Flutter", detect("Dart", dependencies=["flutter"], imports=["package:flutter/material.dart"])),
    ("React", detect("TypeScript", dependencies=["react"], imports=["react"])),
    ("Next.js", detect("TypeScript", dependencies=["next"], paths=["app/page.tsx"])),
]
for expected, findings in cases:
    match = next((item for item in findings if item["name"] == expected), None)
    assert match, (expected, findings)
    assert match["confidence"] == "high", match
    assert match["evidence"], match
    assert match["concepts"], match

assert not detect("Go", symbols=["Controller"], paths=["src/controller/main.go"])
PY

printf '%s\n' 'framework analysis tests passed'
