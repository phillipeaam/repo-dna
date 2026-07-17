"""Language-aware extraction over Tree-sitter concrete syntax trees."""

from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
import re
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
    "Java": LanguageSpec(
        {
            "class_declaration": "class", "interface_declaration": "interface", "record_declaration": "record",
            "enum_declaration": "enum", "annotation_type_declaration": "annotation", "method_declaration": "method",
            "constructor_declaration": "constructor",
        },
        frozenset({"method_declaration", "constructor_declaration", "lambda_expression"}),
        frozenset({"import_declaration"}), frozenset({"method_invocation", "object_creation_expression"}),
        frozenset({"if_statement", "for_statement", "enhanced_for_statement", "while_statement", "do_statement", "catch_clause", "switch_label", "ternary_expression"}),
    ),
    "Kotlin": LanguageSpec(
        {
            "class_declaration": "class", "object_declaration": "object", "companion_object": "object",
            "function_declaration": "function", "secondary_constructor": "constructor", "type_alias": "type",
            "property_declaration": "property",
        },
        frozenset({"function_declaration", "secondary_constructor", "lambda_literal", "anonymous_function"}),
        frozenset({"import_header"}), frozenset({"call_expression"}),
        frozenset({"if_expression", "for_statement", "while_statement", "do_while_statement", "catch_block", "when_entry", "elvis_expression"}),
    ),
    "Dart": LanguageSpec(
        {
            "class_definition": "class", "mixin_declaration": "mixin", "extension_declaration": "extension",
            "enum_declaration": "enum", "function_signature": "function", "getter_signature": "getter",
            "setter_signature": "setter", "factory_constructor_signature": "constructor", "constructor_signature": "constructor",
        },
        frozenset({"function_signature", "getter_signature", "setter_signature", "factory_constructor_signature", "constructor_signature", "function_expression"}),
        frozenset({"library_import"}), frozenset({"argument_part"}),
        frozenset({"if_statement", "for_statement", "while_statement", "do_statement", "catch_clause", "switch_case", "conditional_expression"}),
    ),
    "Go": LanguageSpec(
        {
            "type_spec": "type", "function_declaration": "function", "method_declaration": "method",
            "method_elem": "method",
        },
        frozenset({"function_declaration", "method_declaration", "method_elem", "func_literal"}),
        frozenset({"import_spec"}), frozenset({"call_expression"}),
        frozenset({"if_statement", "for_statement", "expression_case", "type_case", "select_case", "defer_statement"}),
    ),
    "Rust": LanguageSpec(
        {
            "struct_item": "struct", "enum_item": "enum", "trait_item": "trait", "union_item": "union",
            "type_item": "type", "mod_item": "module", "function_item": "function", "function_signature_item": "function",
        },
        frozenset({"function_item", "function_signature_item", "closure_expression"}),
        frozenset({"use_declaration"}), frozenset({"call_expression", "macro_invocation"}),
        frozenset({"if_expression", "for_expression", "while_expression", "loop_expression", "match_arm", "?"}),
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
    for child in node.named_children:
        nested = child.child_by_field_name("name")
        if nested is not None:
            return _text(nested, source)
        if child.type in {"identifier", "simple_identifier", "type_identifier"}:
            return _text(child, source)
    return "<anonymous>"


def _parameters(node: Any) -> int:
    parameters = node.child_by_field_name("parameters") or node.child_by_field_name("parameter")
    if parameters is None:
        parameters = next((child for child in node.named_children if "parameter" in child.type), None)
    if parameters is None:
        return 0
    parameter_nodes = [child for child in parameters.named_children if "parameter" in child.type]
    return len(parameter_nodes) if parameter_nodes else len(parameters.named_children)


def _target(node: Any, source: bytes) -> str:
    target = node.child_by_field_name("function") or node.child_by_field_name("type")
    if target is None and node.named_children:
        target = node.named_children[0]
    return _text(target, source) if target is not None else ""


def _dart_target(node: Any, source: bytes) -> str:
    selector = node.parent
    container = selector.parent if selector is not None else None
    if selector is None or container is None:
        return ""
    prefix = source[container.start_byte:selector.start_byte].decode("utf-8", errors="replace")
    match = re.search(r"([A-Za-z_$][\w$]*(?:\s*\.\s*[A-Za-z_$][\w$]*)*)\s*$", prefix)
    return re.sub(r"\s+", "", match.group(1)) if match else ""


def _import(node: Any, source: bytes) -> str:
    source_node = node.child_by_field_name("source") or node.child_by_field_name("path") or node.child_by_field_name("argument")
    if source_node is not None:
        return _text(source_node, source).strip("'\"")
    value = _text(node, source).strip().rstrip(";")
    if value.startswith("using "):
        return value.removeprefix("using ").removeprefix("static ").strip()
    if value.startswith("import "):
        return value.removeprefix("import ").removeprefix("static ").strip().strip("'\"")
    return value.strip("'\"")


def _symbol_kind(language: str, node: Any, source: bytes, default: str) -> str:
    if language == "Go" and node.type == "type_spec":
        declared_type = node.child_by_field_name("type")
        if declared_type is not None:
            return {"struct_type": "struct", "interface_type": "interface"}.get(declared_type.type, default)
    if language == "Dart" and node.type == "function_signature":
        return "method" if node.parent is not None and node.parent.parent is not None and node.parent.parent.type == "class_body" else default
    if language != "Kotlin" or node.type != "class_declaration":
        return default
    declaration = _text(node, source).lstrip()
    for keyword, kind in (("interface ", "interface"), ("enum class ", "enum"), ("annotation class ", "annotation"), ("object ", "object")):
        if declaration.startswith(keyword) or f" {keyword}" in declaration[:80]:
            return kind
    return default


def _scope_for_node(language: str, node: Any, source: bytes, scope: tuple[str, ...]) -> tuple[str, ...]:
    if language == "Rust" and node.type == "impl_item":
        implemented = node.child_by_field_name("type")
        if implemented is not None:
            return (*scope, _text(implemented, source))
    if language == "Go" and node.type == "method_declaration":
        receiver = node.child_by_field_name("receiver")
        if receiver is not None:
            identifiers = re.findall(r"[A-Za-z_]\w*", _text(receiver, source))
            if identifiers:
                return (*scope, identifiers[-1])
    return scope


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
        scope = _scope_for_node(language, node, source, scope)
        node_name = _name(node, source) if node.type in spec.symbol_types or node.type in spec.function_types else ""
        current_scope = scope
        if node.type in spec.symbol_types:
            qualified = ".".join((*scope, node_name))
            symbol_kind = _symbol_kind(language, node, source, spec.symbol_types[node.type])
            if language == "Kotlin" and symbol_kind == "function" and scope:
                symbol_kind = "method"
            symbols.append({"name": node_name, "qualified_name": qualified, "kind": symbol_kind, "line": node.start_point.row + 1})
            lowered = node_name.casefold()
            for suffix, pattern in {"repository": "Repository", "factory": "Factory", "builder": "Builder", "strategy": "Strategy", "command": "Command", "controller": "MVC/MVVM", "viewmodel": "MVC/MVVM", "service": "Service layer"}.items():
                if lowered.endswith(suffix):
                    patterns[pattern] += 1
            if lowered.endswith(("controller", "service", "repository")):
                architecture.add("layered")
            if symbol_kind in {"class", "interface", "struct", "record", "enum", "object", "annotation", "trait", "union", "module"}:
                current_scope = (*scope, node_name)
        if node.type in spec.import_types:
            imports.add(_import(node, source))
        if node.type in spec.call_types:
            target = _dart_target(node, source) if language == "Dart" else _target(node, source)
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
            if language == "Dart" and node.parent is not None and node.parent.next_named_sibling is not None and node.parent.next_named_sibling.type == "function_body":
                decisions += sum(1 for descendant in _descendants(node.parent.next_named_sibling) if descendant.type in spec.branch_types)
            qualified = ".".join((*scope, node_name))
            functions.append({
                "name": qualified, "line": node.start_point.row + 1,
                "estimated_cyclomatic_complexity": 1 + decisions,
                "decision_points": decisions, "parameters": _parameters(node),
                "async": any(child.type == "async" for child in node.children),
            })
        if node.type == "ERROR" or (node.is_missing and node.type != "_automatic_semicolon"):
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


def _descendants(node: Any) -> list[Any]:
    result: list[Any] = []
    pending = list(node.named_children)
    while pending:
        current = pending.pop()
        result.append(current)
        pending.extend(current.named_children)
    return result
