"""Contracts for evidence-based framework adapters."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Marker:
    source: str
    pattern: str
    concept: str
    weight: int = 1


@dataclass(frozen=True)
class FrameworkAdapter:
    name: str
    family: str
    languages: frozenset[str]
    markers: tuple[Marker, ...]
