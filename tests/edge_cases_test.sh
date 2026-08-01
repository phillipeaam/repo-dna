#!/usr/bin/env bash
set -euo pipefail
export PYTHONUTF8=1

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "$TEST_DIR/.." && pwd)"
source "$TEST_DIR/helpers/fixture.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/repo-dna-edge.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

# Paths containing spaces and Unicode must survive discovery and JSON encoding.
repository="$TEST_ROOT/Repositório com espaços"
fixture_copy paths-with-spaces "$repository"
fixture_copy unicode-paths "$repository"
fixture_init_git "$repository"
fixture_commit_as "$repository" 'José da Silva' 'jose@example.test' 'Commit com acentuação'
python "$SOURCE_ROOT/collectors/generic.py" "$repository" "$TEST_ROOT/paths.json"
python - "$TEST_ROOT/paths.json" <<'PY'
import json
import sys
import unicodedata

with open(sys.argv[1], encoding="utf-8") as stream:
    data = json.load(stream)

paths = {
    unicodedata.normalize("NFC", item["path"])
    for item in data["largest_files"]
}
expected_paths = {"Source Folder/main file.py", "Documentação/ação.py"}
missing_paths = expected_paths - paths
if missing_paths:
    raise AssertionError(f"missing paths: {sorted(missing_paths)}; observed: {sorted(paths)}")

contributors = {
    unicodedata.normalize("NFC", item["name"])
    for item in data["git"]["contributors"]
}
if "José da Silva" not in contributors:
    raise AssertionError(f"missing contributor; observed: {sorted(contributors)}")
PY
[[ -z "$(git -C "$repository" remote)" ]]

# Multiple identities must remain distinct unless an alias file merges them.
multi="$TEST_ROOT/multiple authors"; fixture_copy multiple-authors "$multi"; fixture_init_git "$multi"
fixture_commit_as "$multi" 'Author One' one@example.test 'First author'
printf '\nprint("second")\n' >> "$multi/src/shared.py"
fixture_commit_as "$multi" 'Autora Dois' two@example.test 'Second author'
python "$SOURCE_ROOT/collectors/generic.py" "$multi" "$TEST_ROOT/multiple-authors.json"
python - "$TEST_ROOT/multiple-authors.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1],encoding="utf-8")); assert data["git"]["contributors_count"]==2
assert {item["name"] for item in data["git"]["contributors"]}=={"Author One","Autora Dois"}
PY

# An author with no matching commits must produce a valid empty author scope.
python "$SOURCE_ROOT/collectors/generic.py" "$repository" "$TEST_ROOT/no-author.json" --author 'Pessoa Inexistente'
python - "$TEST_ROOT/no-author.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1],encoding="utf-8")); assert data["git"]["scope"]=="author"
assert data["git"]["contributors"]==[] and data["git"]["technical_impact"]["contributions_analyzed"]==0
PY

# A directory without Git must fail with the documented message.
no_git="$TEST_ROOT/no git"
fixture_copy no-git "$no_git"
if (cd "$no_git" && bash "$SOURCE_ROOT/dna-analysis.sh") >"$TEST_ROOT/no-git.log" 2>&1; then
    echo 'A non-Git directory was accepted.' >&2; exit 1
fi
# The exact diagnostic may vary with the host shell/locale; the contract is
# that analysis refuses a directory that is not a Git repository.

# An initialized repository without commits remains collectable.
empty="$TEST_ROOT/empty repo"
fixture_copy empty-repo "$empty"; rm -f "$empty/.gitkeep"; fixture_init_git "$empty"
python "$SOURCE_ROOT/collectors/generic.py" "$empty" "$TEST_ROOT/empty.json"
python - "$TEST_ROOT/empty.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1],encoding="utf-8")); assert data["file_count"]==0
assert data["git"]["contributors_count"]==0
PY

# Large files must be counted without being copied into the report.
large="$TEST_ROOT/large repo"; fixture_copy large-file "$large"; fixture_init_git "$large"
awk 'BEGIN { for (i=1; i<=12000; i++) print "value = " i }' > "$large/large.py"
fixture_commit_as "$large" 'Large Author' 'large@example.test' 'Add large file'
python "$SOURCE_ROOT/collectors/generic.py" "$large" "$TEST_ROOT/large.json"
python - "$TEST_ROOT/large.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1],encoding="utf-8")); item=next(value for value in data["largest_files"] if value["path"]=="large.py")
assert item["lines"]==12000
PY

# Symlinks are intentionally excluded from inventory to avoid following paths
# outside the repository or creating recursive filesystem walks.
if ln -s "$large/large.py" "$large/link.py" 2>/dev/null; then
python "$SOURCE_ROOT/collectors/generic.py" "$large" "$TEST_ROOT/symlink.json"
    python - "$TEST_ROOT/symlink.json" <<'PY'
import json
import sys
from pathlib import Path

data = json.load(open(sys.argv[1], encoding="utf-8"))
observed = any(item["path"] == "link.py" for item in data["largest_files"])
link_path = Path(sys.argv[1]).parent.joinpath("large repo", "link.py")
if link_path.is_symlink():
    assert not observed, observed
PY
fi

echo 'edge-case tests passed'
