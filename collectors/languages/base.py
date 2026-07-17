"""Shared contracts for language-aware source analysis."""

from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any


@dataclass
class SourceAnalysis:
    parser: str
    parser_version: str
    symbols: list[dict[str, Any]] = field(default_factory=list)
    imports: list[str] = field(default_factory=list)
    calls: list[dict[str, Any]] = field(default_factory=list)
    functions: list[dict[str, Any]] = field(default_factory=list)
    design_patterns: list[dict[str, Any]] = field(default_factory=list)
    architecture_signals: list[str] = field(default_factory=list)
    decision_points: int = 0
    parse_errors: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
