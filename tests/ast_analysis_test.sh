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
assert parser_status("Python")["mode"] == "ast"

tree_sitter_samples = {
    "JavaScript": ('import api from "./api"; class UserRepository { find(id) { if (id) return api.get(id); } }', "./api", "UserRepository.find", "api.get"),
    "TypeScript": ('import { Client } from "./client"; interface Store { get(id: string): string; } class StoreService { load(id: string) { if (id) return Client.fetch(id); return null; } }', "./client", "StoreService.load", "Client.fetch"),
    "C#": ('using System.Net.Http; class UserRepository { int Get(int id) { if (id > 0) return Create(id); return 0; } }', "System.Net.Http", "UserRepository.Get", "Create"),
}
for language, (sample, imported, function, target) in tree_sitter_samples.items():
    parsed = analyze_source(language, sample)
    if parser_status(language)["mode"] == "heuristic-fallback":
        assert parsed is None
        continue
    assert parsed and parsed["parser"].startswith("tree-sitter-")
    assert not parsed["parse_errors"]
    assert imported in parsed["imports"]
    assert any(item["name"] == function for item in parsed["functions"])
    assert any(item["target"] == target for item in parsed["calls"])
    assert any(item["estimated_cyclomatic_complexity"] >= 2 for item in parsed["functions"])
PY

printf '%s\n' 'AST analysis tests passed'
