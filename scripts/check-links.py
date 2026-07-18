#!/usr/bin/env python3
"""Verify repository Markdown links and generated local HTML links."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit

MARKDOWN_LINK = re.compile(r"(?<!!)\[[^]]+\]\(([^)]+)\)")
HTML_LINK = re.compile(r"\bhref=[\"']([^\"']+)[\"']", re.I)


def local_target(source: Path, value: str) -> Path | None:
    value = value.strip().strip("<>")
    parsed = urlsplit(value)
    if parsed.scheme or value.startswith(("#", "mailto:")): return None
    return (source.parent / unquote(parsed.path)).resolve()


def main() -> int:
    inputs = [Path(value) for value in sys.argv[1:]]
    files = sorted(path for item in inputs for path in ([item] if item.is_file() else item.rglob("*")) if path.suffix.lower() in {".md", ".html"})
    failures=[]
    for source in files:
        text=source.read_text(encoding="utf-8", errors="replace")
        links=MARKDOWN_LINK.findall(text) if source.suffix.lower()==".md" else HTML_LINK.findall(text)
        for value in links:
            target=local_target(source,value)
            if target is not None and not target.exists(): failures.append(f"{source}: broken local link: {value}")
    if failures: print("\n".join(failures),file=sys.stderr); return 1
    print(f"Local link verification passed for {len(files)} documents")
    return 0


if __name__ == "__main__": raise SystemExit(main())
