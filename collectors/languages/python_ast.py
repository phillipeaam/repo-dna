"""Python AST analyzer using the Python standard library."""

from __future__ import annotations

import ast
import sys
from collections import Counter
from typing import Any

from .base import SourceAnalysis


BRANCH_NODES = (ast.If, ast.For, ast.AsyncFor, ast.While, ast.IfExp, ast.ExceptHandler, ast.comprehension, ast.Match)


def dotted_name(node: ast.AST | None) -> str:
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        parent = dotted_name(node.value)
        return f"{parent}.{node.attr}" if parent else node.attr
    if isinstance(node, ast.Call):
        return dotted_name(node.func)
    if isinstance(node, ast.Subscript):
        return dotted_name(node.value)
    return ""


class PythonVisitor(ast.NodeVisitor):
    def __init__(self) -> None:
        self.scope: list[str] = []
        self.symbols: list[dict[str, Any]] = []
        self.imports: set[str] = set()
        self.calls: list[dict[str, Any]] = []
        self.functions: list[dict[str, Any]] = []
        self.patterns: Counter[str] = Counter()
        self.architecture_signals: set[str] = set()

    def qualified(self, name: str) -> str:
        return ".".join([*self.scope, name])

    def visit_Import(self, node: ast.Import) -> None:
        self.imports.update(alias.name for alias in node.names)

    def visit_ImportFrom(self, node: ast.ImportFrom) -> None:
        prefix = "." * node.level + (node.module or "")
        self.imports.add(prefix)

    def visit_ClassDef(self, node: ast.ClassDef) -> None:
        bases = [dotted_name(base) for base in node.bases if dotted_name(base)]
        decorators = [dotted_name(item) for item in node.decorator_list if dotted_name(item)]
        self.symbols.append({
            "name": node.name,
            "qualified_name": self.qualified(node.name),
            "kind": "class",
            "line": node.lineno,
            "bases": bases,
            "decorators": decorators,
        })
        lowered = node.name.casefold()
        for suffix, pattern in {
            "repository": "Repository",
            "factory": "Factory",
            "builder": "Builder",
            "strategy": "Strategy",
            "command": "Command",
            "controller": "MVC/MVVM",
            "viewmodel": "MVC/MVVM",
            "service": "Service layer",
        }.items():
            if lowered.endswith(suffix):
                self.patterns[pattern] += 1
        if any(base.endswith(("ABC", "Protocol")) for base in bases):
            self.architecture_signals.add("abstraction-oriented")
        if any(name.endswith(("Controller", "Service", "Repository")) for name in [node.name, *bases]):
            self.architecture_signals.add("layered")
        self.scope.append(node.name)
        self.generic_visit(node)
        self.scope.pop()

    def visit_FunctionDef(self, node: ast.FunctionDef) -> None:
        self._visit_function(node)

    def visit_AsyncFunctionDef(self, node: ast.AsyncFunctionDef) -> None:
        self._visit_function(node)

    def _visit_function(self, node: ast.FunctionDef | ast.AsyncFunctionDef) -> None:
        decorators = [dotted_name(item) for item in node.decorator_list if dotted_name(item)]
        args = [arg.arg for arg in [*node.args.posonlyargs, *node.args.args, *node.args.kwonlyargs]]
        decisions = sum(isinstance(item, BRANCH_NODES) for item in ast.walk(node))
        decisions += sum(isinstance(item, ast.BoolOp) and max(len(item.values) - 1, 0) for item in ast.walk(node))
        self.symbols.append({
            "name": node.name,
            "qualified_name": self.qualified(node.name),
            "kind": "async_function" if isinstance(node, ast.AsyncFunctionDef) else "function",
            "line": node.lineno,
            "decorators": decorators,
            "parameters": args,
        })
        self.functions.append({
            "name": self.qualified(node.name),
            "line": node.lineno,
            "estimated_cyclomatic_complexity": 1 + decisions,
            "decision_points": decisions,
            "parameters": len(args),
            "async": isinstance(node, ast.AsyncFunctionDef),
        })
        if node.name.casefold() in {"create", "create_instance", "build", "make"}:
            self.patterns["Factory"] += 1
        if decorators:
            self.architecture_signals.add("decorator-driven")
        self.scope.append(node.name)
        self.generic_visit(node)
        self.scope.pop()

    def visit_Call(self, node: ast.Call) -> None:
        name = dotted_name(node.func)
        if name:
            self.calls.append({"target": name, "line": node.lineno, "scope": ".".join(self.scope)})
        self.generic_visit(node)


def analyze(content: str) -> SourceAnalysis:
    try:
        tree = ast.parse(content)
    except SyntaxError as error:
        return SourceAnalysis(
            parser="python-ast",
            parser_version=f"{sys.version_info.major}.{sys.version_info.minor}",
            parse_errors=[f"line {error.lineno or 0}: {error.msg}"],
        )
    visitor = PythonVisitor()
    visitor.visit(tree)
    decisions = sum(item["decision_points"] for item in visitor.functions)
    return SourceAnalysis(
        parser="python-ast",
        parser_version=f"{sys.version_info.major}.{sys.version_info.minor}",
        symbols=visitor.symbols,
        imports=sorted(visitor.imports),
        calls=visitor.calls,
        functions=visitor.functions,
        design_patterns=[
            {"name": name, "matches": count, "confidence": "medium", "basis": "Python AST structure and parsed symbol roles"}
            for name, count in visitor.patterns.most_common()
        ],
        architecture_signals=sorted(visitor.architecture_signals),
        decision_points=decisions,
    )
