#!/usr/bin/env python3
"""Validate one RepoDNA JSON artifact against a versioned JSON Schema."""
from __future__ import annotations
import argparse, json
from pathlib import Path

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("document", type=Path); parser.add_argument("schema", type=Path)
    args = parser.parse_args()
    try:
        from jsonschema import Draft202012Validator
    except ImportError as error:
        raise SystemExit("JSON validation requires: pip install -r requirements-reporting.txt") from error
    document = json.loads(args.document.read_text(encoding="utf-8"))
    schema = json.loads(args.schema.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    try:
        from referencing import Registry, Resource
        registry = Registry()
        for candidate in args.schema.parent.glob("*.schema.json"):
            contents = json.loads(candidate.read_text(encoding="utf-8"))
            if identifier := contents.get("$id"):
                registry = registry.with_resource(identifier, Resource.from_contents(contents))
            registry = registry.with_resource(candidate.name, Resource.from_contents(contents))
        validator = Draft202012Validator(schema, registry=registry)
    except ImportError:
        validator = Draft202012Validator(schema)
    errors = sorted(validator.iter_errors(document), key=lambda item: list(item.absolute_path))
    if errors:
        details = []
        for error in errors[:30]:
            location = "/" + "/".join(map(str, error.absolute_path)) if error.absolute_path else "/"
            details.append(f"- {location}: {error.message}")
        raise SystemExit(f"{args.document.name} violates {args.schema.name}:\n" + "\n".join(details))
    return 0
if __name__ == "__main__": raise SystemExit(main())
