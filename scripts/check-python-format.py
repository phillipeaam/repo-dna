#!/usr/bin/env python3
"""Conservative, dependency-free Python source formatting gate."""

from __future__ import annotations

import ast
import sys
from pathlib import Path


def main() -> int:
    roots = [Path(value) for value in sys.argv[1:]] or [Path("collectors"), Path("renderers"), Path("src/reports"), Path("scripts")]
    failures: list[str] = []
    files = sorted(path for root in roots for path in ([root] if root.is_file() else root.rglob("*.py")))
    for path in files:
        text = path.read_text(encoding="utf-8")
        try:
            ast.parse(text, filename=str(path))
        except SyntaxError as error:
            failures.append(f"{path}:{error.lineno}: invalid Python syntax: {error.msg}")
        for number, line in enumerate(text.splitlines(), 1):
            if line != line.rstrip(): failures.append(f"{path}:{number}: trailing whitespace")
            if line.startswith("\t"): failures.append(f"{path}:{number}: tab indentation")
        if text and not text.endswith("\n"): failures.append(f"{path}: missing final newline")
    if failures:
        print("\n".join(failures), file=sys.stderr); return 1
    print(f"Python formatting contract passed for {len(files)} files")
    return 0


if __name__ == "__main__": raise SystemExit(main())
