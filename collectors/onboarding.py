"""Collect safe, evidence-backed onboarding commands and repository landmarks."""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any


def _read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")[:500_000]
    except OSError:
        return ""


def collect_onboarding(root: Path, files: list[dict[str, Any]], dependencies: dict[str, Any]) -> dict[str, Any]:
    paths = {item["path"] for item in files}
    commands: list[dict[str, Any]] = []
    if "package.json" in paths:
        try:
            package = json.loads(_read(root / "package.json"))
            for name in package.get("scripts", {}):
                commands.append({"command": f"npm run {name}", "purpose": name, "source": "package.json", "classification": "declared", "confirmation_required": False})
        except (json.JSONDecodeError, AttributeError):
            pass
    if "pyproject.toml" in paths:
        try:
            import tomllib
            project = tomllib.loads(_read(root / "pyproject.toml"))
            scripts = {**project.get("project", {}).get("scripts", {}), **project.get("tool", {}).get("poetry", {}).get("scripts", {})}
            for name in scripts:
                commands.append({"command": name, "purpose": "project CLI entrypoint", "source": "pyproject.toml", "classification": "declared", "confirmation_required": False})
        except (ValueError, TypeError):
            pass
    makefile = next((name for name in ("Makefile", "makefile") if name in paths), None)
    if makefile:
        for target in re.findall(r"^([A-Za-z0-9][A-Za-z0-9_.-]*):(?:\s|$)", _read(root / makefile), re.M):
            if target not in {"all", ".PHONY"}:
                commands.append({"command": f"make {target}", "purpose": target, "source": makefile, "classification": "declared", "confirmation_required": False})

    manifest_names = {Path(item.get("path", "")).name for item in dependencies.get("manifests", [])}
    suggestions = []
    if "requirements.txt" in manifest_names or "pyproject.toml" in manifest_names:
        suggestions.append(("python -m pytest", "run Python tests", "Python manifest"))
    if "package.json" in manifest_names:
        suggestions.append(("npm install", "install Node dependencies", "package.json"))
    if "Cargo.toml" in manifest_names:
        suggestions.extend((("cargo build", "build Rust project", "Cargo.toml"), ("cargo test", "run Rust tests", "Cargo.toml")))
    if "go.mod" in manifest_names:
        suggestions.append(("go test ./...", "run Go tests", "go.mod"))
    if any(name.endswith((".sln", ".csproj")) for name in paths):
        suggestions.extend((("dotnet build", "build .NET project", ".NET project file"), ("dotnet test", "run .NET tests", ".NET project file")))
    if "gradlew" in paths:
        suggestions.append(("./gradlew build", "build Gradle project", "Gradle wrapper"))
    declared_commands = {item["command"] for item in commands}
    for command, purpose, source in suggestions:
        if command not in declared_commands:
            commands.append({"command": command, "purpose": purpose, "source": source, "classification": "suggested", "confirmation_required": True})
    return {
        "status": "collected", "commands": commands[:100],
        "summary": {"declared_commands": sum(item["classification"] == "declared" for item in commands), "suggested_commands": sum(item["classification"] == "suggested" for item in commands)},
        "method": "declared manifest targets plus ecosystem suggestions requiring confirmation",
        "limitations": ["Suggested commands were not executed.", "Command availability can depend on local tools, environment variables, services, and credentials."],
    }
