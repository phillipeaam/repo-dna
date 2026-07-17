#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PYTHONPATH="$SOURCE_ROOT/collectors" python - <<'PY'
from languages import analyze_source
from languages.registry import parser_status

source = '''
from abc import ABC
import collections

class UserRepository(ABC):
    def find(self, active):
        if active and self.enabled():
            return collections.defaultdict(list)
        return None

def create():
    return UserRepository()
'''

result = analyze_source("Python", source)
assert result is not None
assert result["parser"] == "python-ast"
assert not result["parse_errors"]
assert {"abc", "collections"} <= set(result["imports"])
assert any(item["name"] == "UserRepository" and item["kind"] == "class" for item in result["symbols"])
assert any(item["name"] == "find" and item["qualified_name"] == "UserRepository.find" for item in result["symbols"])
assert any(item["name"] == "Repository" for item in result["design_patterns"])
assert any(item["name"] == "Factory" for item in result["design_patterns"])
assert any(item["target"] == "collections.defaultdict" for item in result["calls"])
find = next(item for item in result["functions"] if item["name"] == "UserRepository.find")
assert find["estimated_cyclomatic_complexity"] >= 3

invalid = analyze_source("Python", "def broken(:\n")
assert invalid and invalid["parse_errors"]
assert analyze_source("TypeScript", "export class Sample {}") is None
assert parser_status("Python")["mode"] == "ast"
assert parser_status("TypeScript")["mode"] == "heuristic-fallback"
PY

printf '%s\n' 'AST analysis tests passed'
