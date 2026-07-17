"""Optional Tree-sitter runtime and grammar loading."""

from __future__ import annotations

from importlib import import_module
from importlib.metadata import PackageNotFoundError, version
from typing import Any, Callable
import warnings


GRAMMARS: dict[str, tuple[str, str, str]] = {
    "JavaScript": ("tree_sitter_javascript", "language", "tree-sitter-javascript"),
    "TypeScript": ("tree_sitter_typescript", "language_typescript", "tree-sitter-typescript"),
    "C#": ("tree_sitter_c_sharp", "language", "tree-sitter-c-sharp"),
    "Java": ("tree_sitter_java", "language", "tree-sitter-java"),
    "Kotlin": ("tree_sitter_kotlin", "language", "ts-kotlin"),
    "Dart": ("tree_sitter_dart", "language", "tree-sitter-dart"),
    "Go": ("tree_sitter_go", "language", "tree-sitter-go"),
    "Rust": ("tree_sitter_rust", "language", "tree-sitter-rust"),
}


def available(language: str) -> bool:
    try:
        load(language)
        return True
    except (ImportError, AttributeError, TypeError):
        return False


def load(language: str) -> tuple[Any, Any, str]:
    """Return a configured parser, Language instance and grammar version."""
    from tree_sitter import Language, Parser

    module_name, factory_name, distribution = GRAMMARS[language]
    grammar = import_module(module_name)
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", DeprecationWarning)
        tree_language = Language(getattr(grammar, factory_name)())
    try:
        parser = Parser(tree_language)
    except TypeError:  # Compatibility with the pre-0.25 Python binding.
        parser = Parser()
        parser.set_language(tree_language)
    try:
        grammar_version = version(distribution)
    except PackageNotFoundError:
        grammar_version = "unknown"
    return parser, tree_language, grammar_version


def analyzer_for(language: str) -> Callable[[str], Any]:
    from .tree_sitter_source import analyze

    return lambda content: analyze(language, content)
