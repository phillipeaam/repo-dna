#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d -p "$ROOT" .dependency-test.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/Packages" "$TMP/yarn" "$TMP/pnpm" "$TMP/python" "$TMP/pipenv" "$TMP/go" "$TMP/php" "$TMP/gradle"
cat > "$TMP/package-lock.json" <<'JSON'
{"lockfileVersion":3,"packages":{"":{"dependencies":{"react":"18.3.1"}},"node_modules/react":{"version":"18.3.1","dependencies":{"loose-envify":"1.4.0"}},"node_modules/loose-envify":{"version":"1.4.0"}}}
JSON
cat > "$TMP/packages.lock.json" <<'JSON'
{"version":1,"dependencies":{"net8.0":{"Newtonsoft.Json":{"type":"Direct","requested":"[13.0.3, )","resolved":"13.0.3","dependencies":{"System.Runtime":"4.3.1"}},"System.Runtime":{"type":"Transitive","resolved":"4.3.1"}}}}
JSON
cat > "$TMP/pubspec.lock" <<'YAML'
packages:
  collection:
    dependency: transitive
    version: "1.19.0"
  http:
    dependency: "direct main"
    version: "1.2.2"
YAML
cat > "$TMP/Cargo.lock" <<'TOML'
version = 3
[[package]]
name = "serde"
version = "1.0.210"
dependencies = ["serde_derive"]
[[package]]
name = "serde_derive"
version = "1.0.210"
TOML
cat > "$TMP/Packages/packages-lock.json" <<'JSON'
{"dependencies":{"com.unity.inputsystem":{"version":"1.11.2","depth":0,"dependencies":{"com.unity.modules.uielements":"1.0.0"}},"com.unity.modules.uielements":{"version":"1.0.0","depth":1}}}
JSON
cat > "$TMP/yarn/yarn.lock" <<'LOCK'
left-pad@^1.3.0:
  version "1.3.0"
LOCK
cat > "$TMP/pnpm/pnpm-lock.yaml" <<'YAML'
lockfileVersion: '9.0'
packages:
  is-number@7.0.0:
    resolution: {integrity: fixture}
YAML
cat > "$TMP/python/poetry.lock" <<'TOML'
[[package]]
name = "requests"
version = "2.32.3"
TOML
cat > "$TMP/pipenv/Pipfile.lock" <<'JSON'
{"default":{"flask":{"version":"==3.0.3"}},"develop":{}}
JSON
printf '%s\n' 'golang.org/x/text v0.18.0 h1:fixture' > "$TMP/go/go.sum"
cat > "$TMP/php/composer.lock" <<'JSON'
{"packages":[{"name":"monolog/monolog","version":"3.7.0","require":{}}],"packages-dev":[]}
JSON
printf '%s\n' 'com.squareup.okhttp3:okhttp:4.12.0=runtimeClasspath' > "$TMP/gradle/gradle.lockfile"

PYTHONPATH="$ROOT/collectors" python - "$TMP" "$ROOT" <<'PY'
import json, sys
from pathlib import Path
from dependency_inventory import collect_dependency_inventory
from quality.importers import import_quality_results

root, source = Path(sys.argv[1]), Path(sys.argv[2])
declared = {"manifests": [{"path":"package.json","dependencies":["react"]},{"path":"demo.csproj","dependencies":["Newtonsoft.Json"]},{"path":"Cargo.toml","dependencies":["serde"]}]}
inventory = collect_dependency_inventory(root, declared)
assert inventory["status"] == "resolved", inventory
assert inventory["summary"] == {"lockfiles":12,"parsed_lockfiles":12,"components":17,"direct_components":6,"transitive_components":11,"ecosystems":9}, inventory["summary"]
components = {(item["ecosystem"], item["name"]):item for item in inventory["components"]}
assert components[("npm","react")]["version"] == "18.3.1" and components[("npm","react")]["direct"]
assert not components[("npm","loose-envify")]["direct"]
assert components[("NuGet","Newtonsoft.Json")]["version"] == "13.0.3" and components[("NuGet","Newtonsoft.Json")]["direct"]
assert components[("Pub","http")]["direct"] and not components[("Pub","collection")]["direct"]
assert components[("Cargo","serde")]["direct"]
assert components[("npm","left-pad")]["version"] == "1.3.0"
assert components[("npm","is-number")]["version"] == "7.0.0"
assert components[("PyPI","requests")]["version"] == "2.32.3"
assert components[("PyPI","flask")]["version"] == "3.0.3" and components[("PyPI","flask")]["direct"]
assert components[("Go","golang.org/x/text")]["version"] == "0.18.0"
assert components[("Composer","monolog/monolog")]["version"] == "3.7.0"
assert components[("Maven","com.squareup.okhttp3:okhttp")]["version"] == "4.12.0"
assert inventory["sbom"]["bomFormat"] == "CycloneDX" and inventory["sbom"]["specVersion"] == "1.6"
assert len({item["bom-ref"] for item in inventory["sbom"]["components"]}) == 17
quality = import_quality_results(root, declared, inventory)
resolved = {item["name"]: item for item in quality["dependency_resolution"]["dependencies"]}
assert resolved["react"]["versions"] == ["18.3.1"]

report = {"generic_analysis":{"analysis":{"dependency_inventory":inventory}}}
(root / "report.json").write_text(json.dumps(report), encoding="utf-8")
PY

python "$ROOT/renderers/sbom.py" "$TMP/report.json" "$TMP/sbom"
python - "$TMP/sbom/bom.json" <<'PY'
import json, sys
data=json.load(open(sys.argv[1],encoding="utf-8")); assert data["bomFormat"]=="CycloneDX" and len(data["components"])==17
PY
grep -q 'Software bill of materials' "$TMP/sbom/index.html"
grep -q 'pkg:npm/react@18.3.1' "$TMP/sbom/index.html"

printf 'dependency inventory and SBOM tests passed\n'
