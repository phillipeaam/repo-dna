"""Language-aware extraction over Tree-sitter concrete syntax trees."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from typing import Any

from .base import SourceAnalysis
from .tree_sitter_runtime import load


@dataclass(frozen=True)
class LanguageSpec:
    symbol_types: dict[str, str]
    function_types: frozenset[str]
    import_types: frozenset[str]
    call_types: frozenset[str]
    branch_types: frozenset[str]


ECMA_SYMBOLS = {
    "class_declaration": "class", "function_declaration": "function",
    "method_definition": "method", "generator_function_declaration": "function",
}

SPECS = {
    "JavaScript": LanguageSpec(
        ECMA_SYMBOLS,
        frozenset({"function_declaration", "generator_function_declaration", "method_definition", "arrow_function"}),
        frozenset({"import_statement"}), frozenset({"call_expression", "new_expression"}),
        frozenset({"if_statement", "for_statement", "for_in_statement", "while_statement", "do_statement", "catch_clause", "switch_case", "ternary_expression"}),
    ),
    "TypeScript": LanguageSpec(
        {**ECMA_SYMBOLS, "interface_declaration": "interface", "type_alias_declaration": "type", "enum_declaration": "enum", "abstract_class_declaration": "class"},
        frozenset({"function_declaration", "generator_function_declaration", "method_definition", "method_signature", "arrow_function"}),
        frozenset({"import_statement"}), frozenset({"call_expression", "new_expression"}),
        frozenset({"if_statement", "for_statement", "for_in_statement", "while_statement", "do_statement", "catch_clause", "switch_case", "ternary_expression"}),
    ),
    "C#": LanguageSpec(
        {
            "class_declaration": "class", "interface_declaration": "interface", "struct_declaration": "struct",
            "record_declaration": "record", "enum_declaration": "enum", "method_declaration": "method",
            "constructor_declaration": "constructor", "local_function_statement": "function",
        },
        frozenset({"method_declaration", "constructor_declaration", "local_function_statement", "lambda_expression", "anonymous_method_expression"}),
        frozenset({"using_directive"}), frozenset({"invocation_expression", "object_creation_expression"}),
        frozenset({"if_statement", "for_statement", "for_each_statement", "while_statement", "do_statement", "catch_clause", "switch_section", "conditional_expression"}),
    ),
}


def _text(node: Any, source: bytes) -> str:
    return source[node.start_byte:node.end_byte].decode("utf-8", errors="replace")


def _name(node: Any, source: bytes) -> str:
    named = node.child_by_field_name("name")
    if named is not None:
        return _text(named, source)
    parent = node.parent
    if node.type in {"arrow_function", "lambda_expression", "anonymous_method_expression"} and parent is not None:
        named = parent.child_by_field_name("name")
        if named is not None:
            return _text(named, source)
    return "<anonymous>"


def _parameters(node: Any) -> int:
    parameters = node.child_by_field_name("parameters") or node.child_by_field_name("parameter")
    if parameters is None:
        return 0
    parameter_nodes = [child for child in parameters.named_children if "parameter" in child.type]
    return len(parameter_nodes) if parameter_nodes else len(parameters.named_children)


def _target(node: Any, source: bytes) -> str:
    target = node.child_by_field_name("function") or node.child_by_field_name("type")
    if target is None and node.named_children:
        target = node.named_children[0]
    return _text(target, source) if target is not None else ""


def _import(node: Any, source: bytes) -> str:
    source_node = node.child_by_field_name("source")
    if source_node is not None:
        return _text(source_node, source).strip("'\"")
    value = _text(node, source).strip().rstrip(";")
    if value.startswith("using "):
        return value.removeprefix("using ").removeprefix("static ").strip()
    return value


def analyze(language: str, content: str) -> SourceAnalysis:
    parser, _, grammar_version = load(language)
    source = content.encode("utf-8")
    root = parser.parse(source).root_node
    spec = SPECS[language]
    symbols: list[dict[str, Any]] = []
    functions: list[dict[str, Any]] = []
    calls: list[dict[str, Any]] = []
    imports: set[str] = set()
    patterns: Counter[str] = Counter()
    architecture: set[str] = set()
    errors: list[str] = []
    total_decisions = 0

    def walk(node: Any, scope: tuple[str, ...] = ()) -> int:
        nonlocal total_decisions
        node_name = _name(node, source) if node.type in spec.symbol_types or node.type in spec.function_types else ""
        current_scope = scope
        if node.type in spec.symbol_types:
            qualified = ".".join((*scope, node_name))
            symbols.append({"name": node_name, "qualified_name": qualified, "kind": spec.symbol_types[node.type], "line": node.start_point.row + 1})
            lowered = node_name.casefold()
            for suffix, pattern in {"repository": "Repository", "factory": "Factory", "builder": "Builder", "strategy": "Strategy", "command": "Command", "controller": "MVC/MVVM", "viewmodel": "MVC/MVVM", "service": "Service layer"}.items():
                if lowered.endswith(suffix):
                    patterns[pattern] += 1
            if lowered.endswith(("controller", "service", "repository")):
                architecture.add("layered")
            if spec.symbol_types[node.type] in {"class", "interface", "struct", "record"}:
                current_scope = (*scope, node_name)
        if node.type in spec.import_types:
            imports.add(_import(node, source))
        if node.type in spec.call_types:
            target = _target(node, source)
            if target:
                calls.append({"target": target, "line": node.start_point.row + 1, "scope": ".".join(scope)})
        is_decision = int(node.type in spec.branch_types)
        total_decisions += is_decision
        decisions = is_decision
        for child in node.named_children:
            child_decisions = walk(child, current_scope)
            if child.type not in spec.function_types:
                decisions += child_decisions
        if node.type in spec.function_types:
            qualified = ".".join((*scope, node_name))
            functions.append({
                "name": qualified, "line": node.start_point.row + 1,
                "estimated_cyclomatic_complexity": 1 + decisions,
                "decision_points": decisions, "parameters": _parameters(node),
                "async": any(child.type == "async" for child in node.children),
            })
        if node.type == "ERROR" or node.is_missing:
            errors.append(f"line {node.start_point.row + 1}: {node.type}")
        return decisions

    walk(root)
    return SourceAnalysis(
        parser=f"tree-sitter-{language.casefold().replace('#', 'sharp').replace(' ', '-')}",
        parser_version=grammar_version, symbols=symbols, imports=sorted(imports), calls=calls,
        functions=functions, design_patterns=[
            {"name": name, "matches": count, "confidence": "medium", "basis": f"{language} Tree-sitter syntax tree and parsed symbol roles"}
            for name, count in patterns.most_common()
        ], architecture_signals=sorted(architecture), decision_points=total_decisions,
        parse_errors=errors[:100] if root.has_error else [],
    )
