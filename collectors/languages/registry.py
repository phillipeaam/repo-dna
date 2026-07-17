"""Select the strongest available analyzer for each source language."""

from __future__ import annotations

from typing import Any

from .python_ast import analyze as analyze_python
from .tree_sitter_runtime import GRAMMARS, analyzer_for, available


AST_ANALYZERS = {
    "Python": analyze_python,
}

PRIORITY_LANGUAGES = (
    "Python", "JavaScript", "TypeScript", "C#", "Java", "Kotlin", "Dart", "Go", "Rust",
)


def analyze_source(language: str, content: str) -> dict[str, Any] | None:
    analyzer = AST_ANALYZERS.get(language)
    if analyzer is None and language in GRAMMARS and available(language):
        analyzer = analyzer_for(language)
    return analyzer(content).to_dict() if analyzer else None


def parser_status(language: str) -> dict[str, str]:
    if language in AST_ANALYZERS:
        return {"language": language, "mode": "ast", "parser": "python-ast"}
    if language in GRAMMARS:
        parser = f"tree-sitter-{language.casefold().replace('#', 'sharp').replace(' ', '-')}"
        return {"language": language, "mode": "ast" if available(language) else "heuristic-fallback", "parser": parser}
    if language in PRIORITY_LANGUAGES:
        return {"language": language, "mode": "heuristic-fallback", "parser": "planned-tree-sitter"}
    return {"language": language, "mode": "heuristic-fallback", "parser": "regex"}
