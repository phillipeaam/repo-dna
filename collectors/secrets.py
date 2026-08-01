#!/usr/bin/env python3
"""Bounded, parallel heuristic secret scan with redacted output only."""

from __future__ import annotations

import argparse
import fnmatch
import os
import re
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path


EXCLUDED_DIRECTORIES = {
    ".git", ".repodna", "node_modules", "vendor", "packages", "library",
    "logs", "temp", "obj", "bin", "build", "builds", "dist", ".venv",
    "venv", "__pycache__", ".next", ".nuxt", "coverage", "tests/fixtures",
}
ARCHIVE_SUFFIXES = (".zip", ".tar.gz", ".7z", ".rar")
PLACEHOLDER = re.compile(
    r"(^|[-_.])(example|sample|dummy|placeholder|changeme|replace.?me|redacted|"
    r"your.?[a-z]*|not.?set|none|null)([-_.]|$)|^x{6,}$|^\$\{[^}]+\}$|^<[^>]+>$",
    re.I,
)


@dataclass(frozen=True, order=True)
class Finding:
    path: str
    line: int
    kind: str
    severity: str
    preview: str


def positive_int(name: str, default: int, maximum: int | None = None) -> int:
    try:
        value = max(1, int(os.environ.get(name, str(default))))
    except ValueError:
        value = default
    return min(value, maximum) if maximum else value


def load_rules(path: Path | None) -> list[str]:
    if not path or not path.is_file():
        return []
    return [
        line.strip().removeprefix("./") for line in path.read_text(encoding="utf-8", errors="replace").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]


def ignored(relative: str, rules: list[str]) -> bool:
    for rule in rules:
        normalized = rule.replace("\\", "/")
        if normalized.endswith("/") and (relative == normalized[:-1] or relative.startswith(normalized)):
            return True
        if fnmatch.fnmatch(relative, normalized):
            return True
    return False


def load_allowlist(path: Path) -> list[tuple[str, str, str]]:
    rules = []
    for raw in load_rules(path):
        fields = raw.split("|", 2)
        if len(fields) == 3 and all(fields):
            rules.append(tuple(fields))
    return rules


def allowed(finding: Finding, rules: list[tuple[str, str, str]]) -> bool:
    return any(
        (path == "*" or fnmatch.fnmatch(finding.path, path))
        and (line == "*" or line == str(finding.line))
        and (kind == "*" or kind == finding.kind)
        for path, line, kind in rules
    )


def candidate(line: str) -> str:
    value = re.split(r"[:=]\s*", line, maxsplit=1)[-1].strip(" \t\"',;")
    return re.split(r"[\s,;]", value, maxsplit=1)[0].strip("\"'")


def preview(value: str) -> str:
    value = value.strip(" \t\"',;")
    if len(value) < 12:
        return "[REDACTED]"
    return f"{value[:3]}****{value[-4:]}"


def patterns(line: str, path: str) -> list[tuple[str, str, str]]:
    lower = line.casefold()
    value = candidate(line)
    matches: list[tuple[str, str, str]] = []
    private = re.search(r"-----BEGIN (?:RSA |OPENSSH |EC |DSA |PGP )?PRIVATE KEY-----", line)
    aws = re.search(r"(?:AKIA|ASIA)[A-Z0-9]{16}", line)
    bearer = re.search(r"bearer\s+([a-z0-9._~+/=-]{12,})", line, re.I)
    if private:
        matches.append(("private key", "Critical", "private-key-material"))
    if aws:
        matches.append(("AWS credential", "Critical", aws.group(0)))
    elif re.search(r"aws[_-]?secret[_-]?access[_-]?key\s*[:=]", lower):
        matches.append(("AWS credential", "Critical", value))
    if bearer:
        matches.append(("Bearer token", "High", bearer.group(1)))
    if re.search(r"(?:api[_-]?(?:key|token)|access[_-]?token|client[_-]?secret|_authtoken)[\"']?\s*[:=]\s*[\"']?[\w.~+/=-]{8,}", line, re.I):
        matches.append(("possible API token", "High", value))
    if re.search(r"(?:password|passwd|pwd)[\"']?\s*[:=]\s*[\"']?[^\s\"']{6,}", line, re.I):
        matches.append(("password", "High", value))
    if (re.search(r"(?:server|data source)\s*=.*;(?:user id|uid|password|pwd)\s*=", lower)
            or re.search(r"(?:mongodb(?:\+srv)?|postgres(?:ql)?|mysql|sqlserver|redis)://[^\s]+@", lower)):
        matches.append(("connection string", "High", value))
    if ("firebaseio.com" in lower or re.search(r"firebase[_-]?(?:api[_-]?key|private[_-]?key|database[_-]?url)", lower)
            or (Path(path).name in {"google-services.json", "GoogleService-Info.plist"} and re.search(r"current_key|mobilesdk_app_id|project_id|database_url", lower))):
        matches.append(("Firebase configuration", "Medium", value))
    if re.search(r"https?://[^/:\s]+:[^@\s]+@", lower):
        matches.append(("Git remote credential", "High", value))
    if re.search(r"https?://[^\s]*(?:hooks\.slack\.com|discord(?:app)?\.com/api/webhooks|webhook)[^\s]*", lower):
        matches.append(("webhook URL", "High", value))
    if re.search(r"(?:registry|index-url|extra-index-url|packagesource|npmregistryserver)\s*[:=]", lower) and re.search(r"https?://|_authtoken|username|password", lower):
        matches.append(("private package registry", "Medium", value))
    if re.search(r"(?:[a-z0-9-]+\.)+(?:internal|corp|local|lan)(?:[^a-z0-9-]|$)|(?:10\.\d{1,3}\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3}|172\.(?:1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3})", lower):
        matches.append(("internal domain or private network address", "Low", value))
    return [(kind, severity, found) for kind, severity, found in matches if found and not PLACEHOLDER.search(found)]


def scan_file(item: tuple[Path, str], max_bytes: int) -> list[Finding]:
    path, relative = item
    try:
        if path.stat().st_size > max_bytes:
            return []
        with path.open("rb") as stream:
            head = stream.read(8192)
            if b"\0" in head:
                return []
            stream.seek(0)
            findings = []
            for number, raw in enumerate(stream, 1):
                line = raw.decode("utf-8", errors="replace")
                for kind, severity, value in patterns(line, relative):
                    findings.append(Finding(relative, number, kind, severity, preview(value)))
            return findings
    except (OSError, PermissionError):
        return []


def discover(root: Path, report_name: str, ignore_rules: list[str]) -> list[tuple[Path, str]]:
    files: list[tuple[Path, str]] = []
    for current, directories, names in os.walk(root, followlinks=False):
        current_path = Path(current)
        relative_dir = current_path.relative_to(root).as_posix()
        directories[:] = [
            name for name in directories
            if name.casefold() not in EXCLUDED_DIRECTORIES
            and f"{relative_dir}/{name}".lstrip("./") not in EXCLUDED_DIRECTORIES
            and name != report_name
            and not ignored(f"{relative_dir}/{name}/".lstrip("./"), ignore_rules)
        ]
        for name in names:
            path = current_path / name
            relative = path.relative_to(root).as_posix()
            if path.is_symlink() or relative.endswith(ARCHIVE_SUFFIXES) or ignored(relative, ignore_rules):
                continue
            files.append((path, relative))
    git_config = root / ".git/config"
    if git_config.is_file():
        files.append((git_config, ".git/config"))
    return files


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--report-name", default="")
    parser.add_argument("--ignore-file", type=Path)
    args = parser.parse_args()
    root = args.root.resolve()
    ignore_file = args.ignore_file or root / ".repodna-ignore"
    ignore_rules = load_rules(ignore_file)
    allowlist = load_allowlist(root / ".repodna-secrets-allowlist")
    max_bytes = positive_int("REPODNA_SECRET_MAX_FILE_BYTES", 10 * 1024 * 1024)
    workers = positive_int("REPODNA_SCAN_WORKERS", min(8, os.cpu_count() or 4), 16)
    files = discover(root, args.report_name, ignore_rules)
    findings: set[Finding] = set()
    with ThreadPoolExecutor(max_workers=workers, thread_name_prefix="repodna-secret") as pool:
        for result in pool.map(lambda item: scan_file(item, max_bytes), files):
            findings.update(item for item in result if not allowed(item, allowlist))
    ordered = sorted(findings)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="utf-8", newline="\n") as output:
        output.write("Potential secrets report\n========================\n")
        output.write("RepoDNA performs heuristic secret detection and is not a replacement for a dedicated security scanner.\n\n")
        output.write("Matched values are masked before leaving the scanner and are never included in full.\n\n")
        if not ordered:
            output.write("No configured sensitive-data pattern was detected.\n")
        for item in ordered:
            output.write(f"Potential {item.kind}\nSeverity: {item.severity}\nFile: {item.path}\nLine: {item.line}\nPreview: {item.preview}\n\n")
    print(len(ordered))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
